typedef enum { typeCon, typeFloat, typeDouble, typeId, typeOpr, dumy } nodeEnum;


/* constants */
typedef struct {
 int value; /* value of constant */
} conNodeType;


/* floats */
typedef struct{
	float value; /* value of float */
} fNodeType;


/* identifiers */
typedef struct {
	char i[30]; /* subscript to sym array */
} idNodeType;


/* operators */
typedef struct {
 int oper; /* operator */
 int nops; /* number of operands */
 struct nodeTypeTag **op; /* operands */
} oprNodeType;


typedef struct nodeTypeTag {
	 nodeEnum type; /* type of node */
	 union {
		 conNodeType con; /* constants */
		 fNodeType fnum;  /* floats */
		 idNodeType id; /* identifiers */
		 oprNodeType opr; /* operators */
	 };
} nodeType;

typedef struct {
	nodeEnum type;
	union {
		int i;
		float f;
		double d;
	};
}sym_tab;

typedef struct symbols_struct{
	char name[30];
	int ind;
}symbols;
