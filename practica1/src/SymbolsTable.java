package TypeChecker.src;

import Types.ExpType;

public class SymbolsTable {

    private Environment environment;

    public Environment newEnvironment(String name) {
        if (this.environment == null) {
            this.environment = new Environment(name);
        } else {
            this.environment = new Environment(name, this.environment);
        }
        return this.environment;
    }

    public Environment newEnvironment() {
        this.environment = new Environment(this.environment);
        return this.environment;
    }

    public void exitEnvironment() {
        if (this.environment.getFatherEnvironment() != null) {
            this.environment = this.environment.getFatherEnvironment();
        }
    }

    public Symbol insertID(String id) {
        Symbol symbol = this.environment.insertID(id);
        return symbol;

    }

    public boolean checkNull(Symbol symbol){
        return symbol==null;
    }

    public Symbol insertFunctionID(String id, Environment functionEnvironment){
        Symbol result = this.environment.insertFunctionID(id, functionEnvironment.getFatherEnvironment());
        return result;
    }
    public Symbol searchID(String id){
        return this.environment.searchID(id);
    }

    public void insertType(Symbol symbol, ExpType expType){
        symbol.setType(expType);
        Environment e = this.environment;
        String s = "";
        while(e != null){
            if (e.getName() != null)
                s = "<" + e.getName() + "> " + s;
            else
                s = "<> " + s;
            e = e.getFatherEnvironment();
        }
        switch (expType.getType()) {
            case "BasicType":
                System.out.println("BasicType : " + expType.getFullName() + "  " + symbol.getId());
                break;
                //BasicType : int a
            case "ComplexType":
                System.out.println("ComplexType : "  + expType.getName() + " : " + expType.getFullName() + "  " + symbol.getId());
                break;
                //ComplexType : Function : (int) -> void FuncASinParam
        }
    }

    public ExpType getType(Symbol symbol){
        return symbol.getType();
    }

    public boolean isFunction ( ExpType t ) {
        return (t.getName().equals("Function")) ? true : false;
    }

    public ExpType getParamType(ExpType ftype){
        if(isFunction(ftype)){
            return ftype.getParamType();
        } else {
            throw new RuntimeException("Llamada a getParamType() con elemento de tipo: "+ftype+" en vez de tipo funcion.");
        }
    }

    public ExpType getReturnType(ExpType ftype) {
        if(isFunction(ftype)){
            return ftype.getReturnType();
        } else {
            throw new RuntimeException("Llamada a getReturnType() con elemento de tipo: "+ftype+" en vez de tipo funcion.");
        }
    }

    public void notifyError(String id, String error){

        Environment e = this.environment;
        String s = "";

        int cont = 0;

        while(e.getFatherEnvironment() != null && cont < 1) {
            if (e.getName() != null) {
                s = "<" + e.getName() + "> " + s;
                cont++;
            }
            else
                s = "<> " + s;
            e = e.getFatherEnvironment();
        }
        System.out.println(s + "ID " + id + ": " + error);
    }

}
