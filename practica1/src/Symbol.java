package TypeChecker.src;

import Princ.ImperativeParadigm;
import Types.ExpType;

public class Symbol {

    private String id;
    private ExpType type;

    private Environment environment;

    public Symbol(Environment environment, String id) {
        this.id = id;
        this.type = null;
        this.environment = environment;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Environment getEnvironment() {
        return environment;
    }

    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    public ExpType getType() {
        return type;
    }

    public void setType(ExpType expType) {
        this.type = expType;
    }
}
