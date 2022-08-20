package TypeChecker.src;

import Princ.ImperativeParadigm;

import java.util.ArrayList;

public class Sintesis {
	private ArrayList<String> errores;
	private int numErrores;
	private SymbolsTable symbolsTable;
	private ImperativeParadigm pI;

	public Sintesis() {
		errores = new ArrayList<>();
		numErrores = 0;
		symbolsTable = new SymbolsTable();
		pI = new ImperativeParadigm();
	}
	
	public void addError ( String str ) {
		errores.add(str);
		numErrores++;
	}
	
	public void informe() {
		if(numErrores == 0) System.out.println("Sin errores.");
		else {
		    for (String i : errores) {
		        System.out.println(i);
		    }
		}
	}

	public SymbolsTable getSymbolsTable() {
		return symbolsTable;
	}

	public void setSymbolsTable(SymbolsTable symbolsTable) {
		this.symbolsTable = symbolsTable;
	}

	public ImperativeParadigm getImperativeParadigm() {
		return pI;
	}

	public void setImperativeParadigm(ImperativeParadigm pI) {
		this.pI = pI;
	}
}
