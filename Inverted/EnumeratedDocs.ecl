IMPORT TextSearch2.Common;
IMPORT TextSearch2.Inverted;
IMPORT TextSearch2.Inverted.Layouts;
IMPORT Std.system.Thorlib;

EXPORT DATASET(Layouts.Document)
       EnumeratedDocs(Common.FileName_Info info,
                      DATASET(Layouts.DocumentIngest) docs) := FUNCTION
  startNo := Inverted.HighestUsedNumber(info) + 1;

  Layouts.Document enumDocs(Layouts.DocumentIngest docIn, INTEGER c) := TRANSFORM
    SELF.id := startNo + (c-1)*Thorlib.Nodes() + Thorlib.Node();
    SELF := docIn;
  END;
  rslt := PROJECT(docs, enumDocs(LEFT, COUNTER), LOCAL);
  RETURN rslt;
END;
