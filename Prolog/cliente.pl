setup_bd :-
	consult('./data/bd_clientes.pl').

arquivo_vazio :-
	\+(predicate_property(cliente(_,_,_,_,_), dynamic)).

adicionaCliente :-
	setup_bd,
	tell('./data/bd_clientes.pl'), nl,
	listing(cliente/5),
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
	nl, writeln("Insira saldo inicial: "),
	read_line_to_string(user_input, Saldo),
	nl,
	(get_cpf_clientes(Cpfs), member(Cpf, Cpfs) -> nl, writeln("Cpf já cadastrado."), nl;
	assertz(cliente(Nome, Cpf, Senha, Telefone, Saldo)),
	adicionaCliente,
	writeln("Cliente cadastrado com sucesso!"),nl),
	fimMetodo.

get_cpf_clientes(Cpfs) :- 
	findall(Cpf, cliente(_,Cpf,_,_,_), Cpfs).

loginCliente(Cpf) :-
	nl,
	writeln("Insira seu CPF: "),
	read_line_to_string(user_input, Cpf),
	writeln("Insira sua senha: "),
	read_line_to_string(user_input, Senha),
	(cliente(_, Cpf, Senha, _,_) -> nl, writeln("Login realizado com sucesso!"), nl;
	writeln("Senha incorreta."), nl, false).

login_cliente(Cpf) :-
	setup_bd,
	arquivo_vazio -> writeln("Cliente não cadastrado."), nl, false;
	(cliente(_, _, _, _, _) -> loginCliente(Cpf);
	writeln("Cliente não cadastrado."), nl, false),
	fimMetodo.

consultaConta(Cpf) :-
	setup_bd_cliente,
	bagof(Nome, cliente(Nome, Cpf, _, _, _), ClienteName),
	bagof(Cpf, cliente(_, Cpf, _, _, _), ClienteCpf),
	bagof(Telefone, cliente(_, Cpf, _, Telefone, _), ClienteTelefone),
	bagof(Saldo, cliente(_, Cpf, _, _, Saldo), ClienteSaldo),
	writeln("Dados da conta: "),
	exibeNomeCliente(ClienteName),
	exibeCpfCliente(ClienteCpf),
	exibeTelefoneCliente(ClienteTelefone),
	exibeSaldoCliente(ClienteSaldo),
	told, nl, printLine.


fimMetodo:-
	writeln("Clique em enter para continuar: "),
	read_line_to_string(user_input, _).

	
