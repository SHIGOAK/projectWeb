{-----------------------}
program Cradle;

{-----------------------}
{ Constant Declarations}

const TAB = ^I;

{-----------------------}
{ Variable Declarations}

var Look: char;			{ Lookahead Character}

{-----------------------}
{ Read New Character From Input Stream}

procedure GetChar;
begin
	Read(Look);
end;

{-----------------------}

procedure Error (s: string);
begin
	WriteLn;
	WriteLn(^G, 'Error: ', s, '.');
end;

{-----------------------}

procedure Abort(s: string);
begin
	Error(s);
	Halt;
end;
{-----------------------}

{Report what was expected}

procedure Expected (s: string);
begin
	Abort (s + 'Expected');
end;

{-----------------------------------}

{Match a Specific Input Character}

procedure Match(x: char);
begin
	if Look = x then GetChar
	else Expected('''' + x + '''');
end;

{-----------------------------------}

{Recognize an Alpha Characters}

function IsAlpha(c: char): boolean;
begin
	IsAlpha := upcase(c) in ['A'..'Z'];
end;
{-----------------------------------}

{ Recognize a Decimal Digit }

function IsDigit(c: char): boolean;
begin
	IsDigit := c in ['0'..'9'];
end;
{-----------------------------------}

{ Get an Identifier}

function GetName: char;
begin
	if not IsAlpha(Look) then Expected('Name');
	GetName := UpCase(Look);
	GetChar;
end;
{-----------------------------------}

{Get a Number}

function GetNum: char;
begin
	if not IsDigit(Look) then Expected('Integer');
	GetNum := Look;
	GetChar;
end;

{-----------------------------------}

{Output a String with Tab}

procedure Emit(s: string);
begin
	Write(TAB, s);
end;
{-----------------------------------}

{Output a String with Tab and CRLF}


procedure EmitLn(s: string);
begin
	Emit(s);
	WriteLn;
end;
{-----------------------------------}

{Recognize the Term Expression}

procedure Term;
begin
	EmitLn('MOVE #' + GetNum +',D0');
end;
{-----------------------------------}


{Recognise and Translate an Add}

procedure Add;
begin
	Match('+');
	Term;
	EmitLn('ADD (SP)+,D0');
end;

{-----------------------------------}

{Recognise and Translate an Subtract}

procedure Subtract;
begin
	Match('-');
	Term;
	EmitLn('SUB (SP)+,D0');
end;

{-----------------------------------}

{Recognise and Translate a Subtract}

procedure Subtraction;
begin
	Match('-');
	Term;
	EmitLn('SUB D1,D0');
	EmitLn('NEG D0');
end;
{-----------------------------------}


{Parse and Translate a Math Factor}
procedure Expression; Forward;
procedure Factor;
begin
	if Look = '(' then begin
	Match('(');
	Expression;
	Match(')');
	end
  else
     EmitLn('MOVE #' + GetNum + ',D0');
end;

{-----------------------------------}

{Recognise and Translate a Multiply}

procedure Multiply;
begin
	Match('*');
	Factor;
	EmitLn('MULS (SP)+,D0');
end;

{-----------------------------------}

{Recognise and Translate a Divide}
procedure Divide;
begin
	Match('/');
	Factor;
	EmitLn('MOVE (SP)+,D1');
	EmitLn('DIVS D1,D0');
end;

{-----------------------------------}

{Recognise and Translate a Math Generals}

procedure Generals;
begin
	Factor;
	while Look in ['*', '/'] do begin
	    EmitLn('MOVE D0,-(SP)');
	    case Look of
	      '*': Multiply;
	      '/': Divide;
	      else expected('Mulop');
	      end;
	end;
end;

{-----------------------------------}

{Recognise an Addop}

function isAddop(c: char): boolean;
begin
	isAddop := c in ['+', '-'];
end;

{-----------------------------------} 

{ Parse and translate Math Expression}

procedure Expression;
begin
	if isAddop(Look) then
	   EmitLn('CLR D0')
    else
	    Term;
	while isAddop(Look) do begin
	EmitLn('MOVE D0,-(SP)');
	case Look of
	'+': Add;
	'-': Subtract;
	else Expected('Addop');
	end;
	end;
end;
{-----------------------------------}

{Initialize}

procedure init;
begin
	GetChar;
end;
{-----------------------------------}

{Main Program}
begin
	Init;
	Expression;
end.
{-----------------------------------}