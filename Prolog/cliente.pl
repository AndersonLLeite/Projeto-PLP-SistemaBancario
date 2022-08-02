setup_bd :-
	consult('./data/bd_clientes.pl').

arquivo_vazio :-
	\+(predicate_property(cliente(_,_,_,_), dynamic)).

adicionaCliente :-
	setup_bd,
	tell('./data/bd_clientes.pl'), nl,
	listing(cliente/4),
	told.

cadastraCliente :-
	setup_bd,
	nl, writeln("Insira seu nome: "),
	read_line_to_string(user_input, Nome),
	nl, writeln("Insira seu CPF: "),
	read_line_to_string(user_input, Cpf),
	nl, writeln("Insira sua senha: "),
	read_line_to_string(user_input, Senha),
	nl, writeln("Insira seu telefone: "),
	read_line_to_string(user_input, Telefone),
	nl,
	(get_emails_clientes(Emails), member(Cpf, Emails) -> nl, writeln("Cpf já cadastrado."), nl;
	assertz(cliente(Nome, Cpf, Senha, Telefone)),
	adicionaCliente,
	writeln("Cliente cadastrado com sucesso!"),nl),
	fimMetodo.

get_emails_clientes(Emails) :- 
	findall(Cpf, cliente(_,Cpf,_,_), Emails).

loginCliente(Cpf) :-
	nl,
	writeln("Insira seu CPF: "),
	read_line_to_string(user_input, Cpf),
	writeln("Insira sua senha: "),
	read_line_to_string(user_input, Senha),
	(cliente(_, Cpf, Senha, _) -> nl, writeln("Login realizado com sucesso!"), nl;
	writeln("Senha incorreta."), nl, false).

login_cliente(Cpf) :-
	setup_bd,
	arquivo_vazio -> writeln("Cliente não cadastrado."), nl, false;
	(cliente(_, _, _, _) -> loginCliente(Cpf);
	writeln("Cliente não cadastrado."), nl, false),
	fimMetodo.

fimMetodo:-
	writeln("Clique em enter para continuar: "),
	read_line_to_string(user_input, _).

	
