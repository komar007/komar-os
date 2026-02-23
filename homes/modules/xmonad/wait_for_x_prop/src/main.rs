use clap::Parser;
use miette::{Context, IntoDiagnostic, Result};
use x11rb::{
    connection::Connection,
    protocol::{
        Event,
        xproto::{AtomEnum, ChangeWindowAttributesAux, ConnectionExt as _, EventMask},
    },
    rust_connection::RustConnection,
};

#[derive(Parser)]
#[command(about = "Wait until an X root window property equals the given string value")]
struct Args {
    /// root window property name to watch.
    property: String,
    /// exact string value that satisfies the wait.
    value: String,
}

fn intern_atom(conn: &RustConnection, name: &[u8]) -> Result<u32> {
    conn.intern_atom(false, name)
        .into_diagnostic()
        .with_context(|| format!("interning X atom {}", String::from_utf8_lossy(name)))?
        .reply()
        .into_diagnostic()
        .with_context(|| format!("reading X atom reply for {}", String::from_utf8_lossy(name)))
        .map(|reply| reply.atom)
}

fn property_is_ready(
    conn: &RustConnection,
    win: u32,
    prop_atom: u32,
    expected_value: &[u8],
) -> Result<bool> {
    let reply = conn
        .get_property(false, win, prop_atom, AtomEnum::ANY, 0, 1024)
        .into_diagnostic()
        .context("querying X property value")?
        .reply()
        .into_diagnostic()
        .context("reading X property reply")?;
    Ok(reply.format == 8 && reply.value == expected_value)
}

fn wait_for_property_value(
    conn: &RustConnection,
    win: u32,
    name: &[u8],
    value: &[u8],
) -> Result<()> {
    let prop_atom = intern_atom(conn, name)?;

    if property_is_ready(conn, win, prop_atom, value)? {
        return Ok(());
    }

    conn.change_window_attributes(
        win,
        &ChangeWindowAttributesAux::new().event_mask(EventMask::PROPERTY_CHANGE),
    )
    .into_diagnostic()
    .context("subscribing to X property change events")?;
    conn.flush()
        .into_diagnostic()
        .context("flushing X property change subscription")?;

    loop {
        let event = conn
            .wait_for_event()
            .into_diagnostic()
            .context("waiting for X event")?;
        if let Event::PropertyNotify(ev) = event
            && ev.window == win
            && ev.atom == prop_atom
            && property_is_ready(conn, win, prop_atom, value)?
        {
            return Ok(());
        }
    }
}

fn main() {
    if let Err(error) = run() {
        eprint!("Error:\n{error:?}");
        std::process::exit(1);
    }
}

fn run() -> Result<()> {
    let args = Args::parse();

    let (conn, screen_num) = x11rb::connect(None)
        .into_diagnostic()
        .context("connecting to the X server")?;
    let root = conn.setup().roots[screen_num].root;
    wait_for_property_value(&conn, root, args.property.as_bytes(), args.value.as_bytes())?;
    Ok(())
}
