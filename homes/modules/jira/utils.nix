{ ... }:
{
  task = id: name: {
    id = toString id;
    name = name;
    handle = "";
    subtask = false;
  };
  subtask = id: name: {
    id = toString id;
    name = name;
    handle = "";
    subtask = true;
  };
}
