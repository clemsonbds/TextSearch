
IMPORT Std;
ds := DATASET([{'2 A.B.C'},
               {'3 C.C.D'},
               {'4 D.D'}],{STRING indata});
ValRec := RECORD
  unicode val;
END;   
DNrec := RECORD
  UNSIGNED4 RecID;
  DATASET(ValRec) Values;
END;

DNrec XF(ds L) := TRANSFORM
  SpacePos    := Std.Str.Find(L.indata,' ',1);
  SetStrVals  := Std.Str.SplitWords(L.indata[SpacePos+1..],'.');
  ValuesDS    := DATASET(SetStrVals,{STRING StrVal});
  SELF.RecID  := (UNSIGNED4)L.indata[1..SpacePos];
  SELF.Values := PROJECT(ValuesDS,
                         TRANSFORM(ValRec,
                                   SELF.val := (unicode)Left.StrVal));
END;
NestedDS := PROJECT(ds,XF(LEFT));   
NestedDS;

OutRec := RECORD
  UNSIGNED RecID;
  unicode val;
END;

NORMALIZE(NestedDS,COUNT(LEFT.Values),
          TRANSFORM(OutRec,
                    SELF.val := LEFT.Values[COUNTER].val,
                    SELF := LEFT));
										
