grammar SEMV;

@header {

import TypeChecker.src.Sintesis;
import TypeChecker.src.SymbolsTable;
import TypeChecker.src.Symbol;
import Princ.ImperativeParadigm;
import Types.ExpType;

}

@parser::members {
    private Sintesis myinfo;
    private SymbolsTable st;
    private ImperativeParadigm pI;

    public SEMVParser ( TokenStream input, Sintesis theinfo )  {
        this(input) ;
        myinfo = theinfo;
        st = myinfo.getSymbolsTable();
        pI = myinfo.getImperativeParadigm();
    }
}

/*
* Parser Rules

axioma : operation '{'myinfo.popall '('  ')' ';''}' ';'
operation  : NUMBER '+' operation '{'myinfo.push '(' new String '(' $NUMBER.text + " + " ')'  ')' ';''}'
    | NUMBER '{'myinfo.push '(' $NUMBER.text ')' ';''}'
';'

*/

axioma : {st.newEnvironment();} program {st.exitEnvironment();} ;
program : part program | part ;

part : type IDENT {Symbol symbol = st.insertFunctionID($IDENT.text, st.newEnvironment($IDENT.text));} '(' fparams ')' { //Esto es una funcion y abrimos su entorno

        if (st.checkNull(symbol)) {
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Function '" + $IDENT.text +"' is already defined in the scope");
        } else {
            ExpType fType = pI.createFunction($fparams.t, $type.t); //pI.createFunction(<inputParamsType>, <outputType>)
            st.insertType(symbol, fType);
        }
    } blq {
        //check return type of "blq"
        if (!pI.compareTypes($blq.blqReturned, $type.t)) {
            if ($blq.blqReturned.getFullName() != "error"){
                System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
                st.notifyError($IDENT.text, "Returned type " + $blq.blqReturned.getFullName() + " when method '" + $IDENT.text + "' should return type " + $type.t.getFullName());
            }
        }

        st.exitEnvironment(); //Aqui cerramos el entorno de la funcion
    };
fparams returns [ExpType t] :
    'void' { $t = pI.createBasic("void"); }
    | flistparam { $t = $flistparam.t; }
    ;

blq returns [ExpType t, ExpType blqReturned] : '{' sentlist '}'{
    $t = $sentlist.t;
    $blqReturned = $sentlist.blqReturned;
} ;

flistparam returns [ExpType t] : type IDENT {//esto es la lista de parametros de una funcion

        Symbol symbol = st.insertID($IDENT.text);

        if (st.checkNull(symbol)){
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, $IDENT.text +"' is already defined in the scope");
        }
        else {
            st.insertType(symbol, $type.t);
        }
    }

    flistparam1 {
        if ($flistparam1.t.getFullName() == "void") $t = $type.t;
        else                        $t = pI.createTuple ($type.t, $flistparam1.t);
    }
    ;

flistparam1 returns [ExpType t] : ',' type IDENT {

    Symbol symbol = st.insertID($IDENT.text);

    if (st.checkNull(symbol)){
        System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
        st.notifyError($IDENT.text, $IDENT.text +"' is already defined in the scope");
    }
    else {
        st.insertType(symbol, $type.t);
    }
    } flistparam1 {
        if ($flistparam1.t.getFullName() == "void") $t = $type.t;
        else                        $t = pI.createTuple ($type.t, $flistparam1.t);
    }
    | { $t = pI.createBasic("void");};
type returns [ExpType t] :
    'void' {$t = pI.createBasic("void");}
    | 'int' {$t = pI.createBasic("int");}
    | 'float' {$t = pI.createBasic("float");}
    ;
sentlist returns [ExpType t, ExpType blqReturned] : sent sentlist {
        if ($sent.t.getFullName() == "error" || $sentlist.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else {
            $t = pI.createBasic("void");
        }
        if ($sent.blqReturned.getFullName() == "void" && $sentlist.blqReturned.getFullName() == "void") {
            $blqReturned = pI.createBasic("void");
        } else if ($sent.blqReturned.getFullName() != "void" && $sentlist.blqReturned.getFullName() != "void" && $sent.blqReturned.getFullName() != "error" && $sentlist.blqReturned.getFullName() != "error") {
            $blqReturned = pI.createBasic("error");
            System.out.print("ERROR --> ");
            st.notifyError("", "Two return statements found");
        } else if($sent.blqReturned.getFullName() != "void"){
            $blqReturned = $sent.blqReturned;
        } else {
            $blqReturned = $sentlist.blqReturned;
        }
    }
    | sent {
        $t = $sent.t;
        $blqReturned = $sent.blqReturned;
    };

sent returns [ExpType t, ExpType blqReturned] : type IDENT vlid[$type.t] ';' /*variable/s declaration*/{
        Symbol symbol = st.insertID($IDENT.text); //if ok returns a Symbol
        if (st.checkNull(symbol)) {
            $t = pI.createBasic("error");
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Variable '" + $IDENT.text +"' is already defined in the scope");
        } else {
            st.insertType(symbol, $type.t); // insert type of IDENT
            $t = $vlid.t; // $vlid.t can be type "void" or "error"
        }
        $blqReturned = pI.createBasic("void");
    }
    //Queda por hacer: completar lo de abajo *****
    | IDENT {
            Symbol symbol = st.searchID($IDENT.text);
            if(st.checkNull(symbol)){
                System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
                st.notifyError($IDENT.text, "Cannot resolve symbol '" + $IDENT.text + "'");
                $t = pI.createBasic("error");
            }
            else{
                $t = symbol.getType();
            }
        }
    restsent[$t,$IDENT.text, $IDENT.getLine(), $IDENT.getCharPositionInLine()]{
        $t = $restsent.t;
        $blqReturned = pI.createBasic("void");
    }
    | 'return' exp ';'{
        $t = $exp.t;
        $blqReturned =  $exp.t;
    }

    // Sentencias de control de flujo de ejecución
    | 'if' '(' lcond ')' 'then' {st.newEnvironment();} blq1=blq {st.exitEnvironment();} 'else' {st.newEnvironment();} blq2=blq {
        st.exitEnvironment();

        if ($lcond.t.getFullName()=="error" || $blq1.t.getFullName()=="error" || $blq2.t.getFullName()=="error"){
            $t =  pI.createBasic("error");
        }
        else{
            $t = pI.createBasic("void");
        }

        if ($blq1.blqReturned.getFullName() == "void" && $blq2.blqReturned.getFullName() == "void") {
            $blqReturned = pI.createBasic("void");
        }
        else if ($blq1.blqReturned.getFullName() != "void" && $blq2.blqReturned.getFullName() != "void" && $blq1.blqReturned.getFullName() != "error" && $blq2.blqReturned.getFullName() != "error") {
            if (pI.compareTypes($blq1.blqReturned, $blq2.blqReturned)){
                $blqReturned = $blq1.blqReturned;
            }
            else{
                System.out.print("ERROR --> ");
                st.notifyError("", "Return error: Two different returns type statement found");
                $blqReturned = pI.createBasic("void");
            }
        } else if($blq1.blqReturned.getFullName() != "void"){
            $blqReturned = $blq1.t;
        } else {
             $blqReturned = $blq2.t;
       }
    }
    | 'for' '(' IDENT {if(st.checkNull(st.searchID($IDENT.text))){
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Cannot resolve symbol '" + $IDENT.text + "'");
        };} '=' exp ';' lcond ';' IDENT {
        if(st.checkNull(st.searchID($IDENT.text))){
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Cannot resolve symbol '" + $IDENT.text + "'");
        };} '=' exp ')' {st.newEnvironment();} blq {
        st.exitEnvironment();

        if ($lcond.t.getFullName()=="error" || $blq.t.getFullName()=="error"){
            $t =  pI.createBasic("error");
        }
        else{
            $t = pI.createBasic("void");
        }

        $blqReturned = $blq.blqReturned;
    }
    | 'while' '(' lcond ')' {st.newEnvironment();} blq {
        st.exitEnvironment();

        if ($lcond.t.getFullName()=="error" || $blq.t.getFullName()=="error"){
            $t =  pI.createBasic("error");
        }
        else{
            $t = pI.createBasic("void");
        }

        $blqReturned = $blq.blqReturned;
    }
    | 'do' {st.newEnvironment();} blq {st.exitEnvironment();} 'until' '(' lcond ')' {
        if(($lcond.t.getFullName() == "error") || ($blq.t.getFullName() == "error")) {
            $t = pI.createBasic("error");
        }
        else {
            $t = pI.createBasic("void");
        }

        $blqReturned = $blq.blqReturned;
    };

lcond returns [ExpType t]: lcondt 'or' lcond {

    if(($lcondt.t.getFullName() == "error") || ($lcond.t.getFullName() == "error")) {
        $t = pI.createBasic("error");
    }
    else {
        $t = pI.createBasic("void");
    }
}
    | lcondt {
        if($lcondt.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else {
            $t = pI.createBasic("void");
        }
    };

lcondt  returns [ExpType t]: lcondf 'and' lcondt{
    if(($lcondf.t.getFullName() == "error") || ($lcondt.t.getFullName() == "error")) {
        $t = pI.createBasic("error");
    }
    else {
        $t = pI.createBasic("void");
    }

}
    | lcondf {
     if($lcondf.t.getFullName() == "error") {
         $t = pI.createBasic("error");
     }
     else {
         $t = pI.createBasic("void");
     }
};


lcondf returns [ExpType t]: cond{
    if($cond.t.getFullName() == "error") {
        $t = pI.createBasic("error");
    }
    else {
        $t = pI.createBasic("void");
    }

}
    | 'not' cond {
    if($cond.t.getFullName() == "error") {
         $t = pI.createBasic("error");
     }
     else {
         $t = pI.createBasic("void");
     }

 };
 //MODIFICO exp opr exp -> exp opr cond -> cond: exp
cond returns [ExpType t]: expp1=exp opr expp2=exp {
  if($exp.t.getFullName() == "error") {
       $t = pI.createBasic("error");
   }
   else {
     if(pI.compareTypes($expp1.t, $expp2.t)) { //if parameter types are compatible...
        $t = $expp1.t;
    } else {
        $t = pI.createBasic("error");
    }
   }
};
opr : '=='
    | '<'
    | '>'
    | '>='
    | '<=' ;
// ********************

restsent [ExpType varT, String ident, int line, int column] returns [ExpType t] : '=' exp ';'{
    if($exp.t.getFullName() == "error") {
        $t = pI.createBasic("error");
    }
    else {
        if(pI.compareTypes($exp.t, $varT)) { //if types are compatible...
            $t = pI.createBasic("void");
        } else {
            System.out.print("ERROR Line:" + $line + " Column:" + $column + " --> ");
            if ($varT.getFullName() == "error"){
                st.notifyError($ident, "Cannot resolve symbol '" + $ident + "'");
            }else{
                st.notifyError($ident, "Can't assign type " + $exp.t.getFullName() + " to variable '" + $ident + "' of type " + $varT.getFullName());
            }
            $t = pI.createBasic("error");
        }
    }
}
    | '(' params ')' ';' {

        Symbol symbol = st.searchID($ident); //if ok returns a Symbol
        if (st.checkNull(symbol)) {
            $t = pI.createBasic("error");
        } else {
            ExpType identType = symbol.getType();
            if (identType.getName() == "Function"){
                if(pI.compareTypes(identType.getParamType(), $params.t)){
                    $t = pI.createBasic("void");
                }
                else{
                    System.out.print("ERROR Line:" + $line + " Column:" + $column + " --> ");
                    st.notifyError($ident, "Change parameters of method '" + $ident + "' from '" + $params.t.getFullName() + "' to '" + identType.getFullName() + "'");
                    $t = pI.createBasic("error");
                }
            }
        }
    };

vlid[ExpType varT] returns [ExpType t] : ',' IDENT vlid[$varT] {
        Symbol symbol = st.insertID($IDENT.text); //if ok returns a Symbol
        if (st.checkNull(symbol)) {
            $t = pI.createBasic("error");
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Variable '" + $IDENT.text +"' is already defined in the scope");
        } else {
            st.insertType(symbol, $varT); // insert type of IDENT
            $t = $vlid.t; // $vlid.t can be type "void" or "error"
        }
    }
    | { $t = pI.createBasic("void"); }
    ;
params returns [ExpType t] : factor aparams {
        if($factor.t.getFullName() == "error" || $aparams.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else{
             if($aparams.t.getFullName() == "void") {
                $t = $factor.t;
             }
             else{
                $t = pI.createTuple($factor.t, $aparams.t);
             }
        }
    }
    | {$t = pI.createBasic("void");};

aparams returns [ExpType t]: ',' factor aparams {
        if($factor.t.getFullName() == "error" || $aparams.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else{
             if($aparams.t.getFullName() == "void") {
                $t = $factor.t;
             }
             else{
                $t = pI.createTuple($factor.t, $aparams.t);
             }
        }
    }
    | {$t = pI.createBasic("void");};

/*********/
exp returns [ExpType t] : expt exp1 {
    if($expt.t.getFullName() == "error" || $exp1.t.getFullName() == "error") {
        $t = pI.createBasic("error");
    }
    else {
        if($exp1.t.getFullName() == "void") {
            $t = $expt.t;
        }else{
            if(pI.compareTypes($expt.t, $exp1.t)) {
                $t = $expt.t;
            }
            else {
                $t = pI.createBasic("error");
                System.out.print("ERROR --> ");
                st.notifyError("", $expt.t.getFullName() +" is not compatible with type " + $exp1.t.getFullName());
            }
        }
    }
};

exp1 returns [ExpType t] : '+' expt exp1 {
        if($expt.t.getFullName() == "error" || $exp1.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else {
            if($exp1.t.getFullName() == "void") {
                $t = $expt.t;
            }else{
                if(pI.compareTypes($expt.t, $exp1.t)) {
                    $t = $expt.t;
                }
                else {
                    $t = pI.createBasic("error");
                    System.out.print("ERROR --> ");
                    st.notifyError("", $expt.t.getFullName() +" is not compatible with type " + $exp1.t.getFullName());
                }
            }
        }
    }
    | '-' expt exp1 {
       if($expt.t.getFullName() == "error" || $exp1.t.getFullName() == "error") {
           $t = pI.createBasic("error");
       }
       else {
           if($exp1.t.getFullName() == "void") {
               $t = $expt.t;
           }else{
               if(pI.compareTypes($expt.t, $exp1.t)) {
                   $t = $expt.t;
               }
               else {
                   $t = pI.createBasic("error");
                   System.out.print("ERROR --> ");
                   st.notifyError("", $expt.t.getFullName() +" is not compatible with type " + $exp1.t.getFullName());
               }
           }
       }
   }
   | {$t = pI.createBasic("void");};

expt returns [ExpType t] : factor expt1 {
    if($factor.t.getFullName() == "error" || $expt1.t.getFullName() == "error") {
        $t = pI.createBasic("error");
    }
    else {
        if($expt1.t.getFullName() == "void") {
            $t = $factor.t;
        }else{
            if(pI.compareTypes($factor.t, $expt1.t)) {
                $t = $factor.t;
            }
            else {
                System.out.print("ERROR --> ");
                st.notifyError("", $factor.t.getFullName() +" is not compatible with type " + $expt1.t.getFullName());
            }
        }
    }
};

expt1 returns [ExpType t] :
    '*' factor expt1 {
         if($factor.t.getFullName() == "error" || $expt1.t.getFullName() == "error") {
             $t = pI.createBasic("error");
         }
         else {
             if($expt1.t.getFullName() == "void") {
                 $t = $factor.t;
             }else{
                 if(pI.compareTypes($factor.t, $expt1.t)) {
                     $t = $factor.t;
                 }
                 else {
                     $t = pI.createBasic("error");
                     System.out.print("ERROR --> ");
                     st.notifyError("", $factor.t.getFullName() +" is not compatible with type " + $expt1.t.getFullName());
                 }
             }
         }
     }
    | '/' factor expt1 {
        if($factor.t.getFullName() == "error" || $expt1.t.getFullName() == "error") {
            $t = pI.createBasic("error");
        }
        else {
            if($expt1.t.getFullName() == "void") {
                $t = $factor.t;
            }else{
                if(pI.compareTypes($factor.t, $expt1.t)) {
                    $t = $factor.t;
                }
                else {
                    $t = pI.createBasic("error");
                    System.out.print("ERROR --> ");
                    st.notifyError("", $factor.t.getFullName() +" is not compatible with type " + $expt1.t.getFullName());
                }
            }
        }
    }
    | {$t = pI.createBasic("void");};

factor returns [ExpType t] : //Esto es una linea en la que puede haber llamadas a funciones, uso de variables y uso de constantes
    IDENT '(' params ')' {
        Symbol symbol = st.searchID($IDENT.text);
        if(st.checkNull(symbol)){
            $t = pI.createBasic("error");
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Cannot resolve method '" + $IDENT.text + "'");
        } else {
            ExpType ftype = st.getType(symbol);
            if( st.isFunction(ftype) ){ //if its a function...
                if(pI.compareTypes(st.getParamType(ftype), $params.t)) { //if parameter types are compatible...
                    $t = st.getReturnType(ftype);
                } else {
                    $t = pI.createBasic("error");
                    System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
                    st.notifyError($IDENT.text, "Change parameters of method '" + $IDENT.text + "' from '" + st.getParamType(ftype).getFullName() + "' to '" + $params.t.getFullName() + "'");
                }
            } else {
                System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
                st.notifyError($IDENT.text, "Method call expected, '" + $IDENT.text + "' is not a function");
                $t = pI.createBasic("error");
            }
        }
    }
    |  '('  exp  ')' { $t = $exp.t; }
    | IDENT {
        Symbol symbol = st.searchID($IDENT.text);
        if(st.checkNull(symbol)){
            $t = pI.createBasic("error");
            System.out.print("ERROR Line:" + $IDENT.getLine() + " Column:" + $IDENT.getCharPositionInLine() + " --> ");
            st.notifyError($IDENT.text, "Cannot resolve symbol '" + $IDENT.text + "'");
        } else {
            $t = st.getType(symbol);
        }
    }
    | CONSTINT { $t = pI.createBasic("int"); }
    | CONSTFLOAT { $t = pI.createBasic("float"); }
    ;

/*
* Lexer Rules
*/
IDENT : [a-zA-Z]+ ;
CONSTINT : [0-9]+ ;
CONSTFLOAT : [0-9]+ '.' [0-9]+ ;
WHITESPACE : [ \n\t\r]+ -> skip ;