package TypeChecker.src;

import java.util.HashMap;

public class Environment {

    private String name;
    private Environment fatherEnvironment;
    private HashMap<String, Symbol> symbols;

    public Environment(String name) {
        this.name = name;
        this.symbols = new HashMap<>();
    }

    public Environment(String name, Environment fatherEnvironment) {
        this.name = name;
        this.fatherEnvironment = fatherEnvironment;
        this.symbols = new HashMap<>();
    }

    public Environment(Environment fatherEnvironment) {
        this.fatherEnvironment = fatherEnvironment;
        this.symbols = new HashMap<>();
    }

    public Symbol insertID(String id) {
        if(this.symbols.containsKey(id)) {
            return null;
        }
        else{
            Symbol symbol = new Symbol(this, id);
            this.symbols.put(symbol.getId(), symbol);
            return symbol;
        }
    }

    public Symbol insertFunctionID(String id, Environment functionEnvironment) {
        if(this.symbols.containsKey(id)){
            return null;
        }
        else{
            Symbol symbol = new Symbol(functionEnvironment, id);
            functionEnvironment.symbols.put(symbol.getId(), symbol);
            return symbol;
        }
    }

    public Symbol searchID(String id){
        if(this.symbols.containsKey(id)){
            return this.symbols.get(id);
        }
        else{
            if (this.fatherEnvironment != null){
                return this.fatherEnvironment.searchID(id);
            }
            else{
                return null;
            }
        }
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Environment getFatherEnvironment() {
        return fatherEnvironment;
    }

    public void setFatherEnvironment(Environment fatherEnvironment) {
        this.fatherEnvironment = fatherEnvironment;
    }

    public HashMap<String, Symbol> getSymbols() {
        return symbols;
    }

    public void setSymbols(HashMap<String, Symbol> symbols) {
        this.symbols = symbols;
    }
}
