package TypeChecker.src;//package TypeChecker;

import TypeChecker.SEMVLexer;
import TypeChecker.SEMVParser;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.IOException;

//import org.antlr.v4.runtime.CharStream;
//import org.antlr.v4.runtime.CharStreams;

/*
El nombre Principal es arbitrario, escoge el que prefieras
*/

public class SEMVPrincipal {

	public static void main(String[] args) {
		try{
			// Preparar el fichero de entrada para asignarlo al analizador l�xico
			CharStream input = CharStreams.fromFileName(args[0]);
			// Crear el objeto correspondiente al analizador l�xico con el fichero de entrada
			SEMVLexer analex = new SEMVLexer(input);
			
			// Identificar al analizador l�xico como fuente de tokens para el sintactico
			CommonTokenStream tokens = new CommonTokenStream(analex);
			// Crear el objeto correspondiente al analizador sint�ctico con el objeto sintesis
			SEMVParser anasint = new SEMVParser(tokens, new Sintesis());
			/*
			Comenzar el an�lisis llamando al axioma de la gram�tica
			Atenci�n, sustituye "axioma" por el nombre del axioma de tu gram�tica
			*/
			anasint.axioma();
			System.out.println("Fin del análisis");
		} catch (org.antlr.v4.runtime.RecognitionException e) { 
			System.err.println("REC " + e.getMessage());
			//e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.err.println("IO " + e.getMessage());
			//e.printStackTrace();
		} catch (java.lang.RuntimeException e) {
			System.err.println("RUN " + e.getMessage());
			//e.printStackTrace();
		}		
	} 
}