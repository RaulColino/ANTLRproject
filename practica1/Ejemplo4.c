int FuncDConWhile ( void ) {
	int a,b,c;
	a = 0;

    while (a < 10){
        b = a + 1;
        c = b;
        a = a + 1;
    }

	return a;
}


float ProcAConParam ( void ) {
	float a;
    int b;
    b = 3;
    a = 2.0;

    do{
        int b;
        b = b + 1;
    }
    until (b < 10)

    return a;
}
