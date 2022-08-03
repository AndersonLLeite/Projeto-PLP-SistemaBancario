:- consult('./data/bd_clientes.pl').



setup_bd_cliente :-
	consult('./data/bd_clientes.pl').

setup_bd_emprestimos :-
	consult('./data/bd_emprestimos.pl').

setup_bd_login :-
	consult('./data/bd_gerente.pl').

arquivo_vazio_adm :-
	\+(predicate_property(gerente(_,_,_), dynamic)).

loginGerente :-
	nl,
	writeln("Faça acesso como gerente:"),
	writeln("Insira seu CPF: "),
	read_line_to_string(user_input, Cpf),
	writeln("Insira sua senha: "),
	read_line_to_string(user_input, Senha),
	(gerente(Cpf, Senha, _) -> nl, writeln("Login realizado com sucesso!"), nl;
	writeln("Senha incorreta."), nl, false).

login_gerente :-
	setup_bd_login,
	arquivo_vazio_adm -> writeln("Gerente não cadastrado."), nl, false;
	(gerente(_, _, _)) -> loginGerente;
	writeln("Gerente não cadastrado."), nl, false.

listaClientes :- 
	setup_bd_cliente,
	findall(C, cliente(_, C, _, _,_), ListaClientes),
	printLine,
	writeln("Clientes cadastrados: "),
	printLine,
	exibeClientes(ListaClientes),
	told, nl.

exibeClientes([]) :-
	nl,
	writeln("Nenhum usuário cadastrado.").

exibeClientes([H]) :-
	write("- "),
	consultaConta(H),
	fimMetodoAdm.

exibeClientes([H|T]) :-
	write("- "),
	consultaConta(H),
	exibeClientes(T).

exibeNomeCliente([Nome]) :-
	write("Nome: "),
	writeln(Nome).

exibeCpfCliente([Cpf]) :-
	write("CPF: "),
	writeln(Cpf).

exibeTelefoneCliente([Telefone]) :-
	write("Telefone: "),
	writeln(Telefone).

exibeSaldoCliente([Saldo]) :-
	write("Saldo: "),
	writeln(Saldo).

add_clientes([]).
add_clientes([[Nome,Cpf,Senha,Telefone, Saldo]|T]) :- 
	add_cliente(Nome,Cpf,Senha,Telefone, Saldo), add_clientes(T).

add_cliente(Nome,Cpf,Senha,Telefone, Saldo) :- 
	assertz(cliente(Nome,Cpf,Senha,Telefone, Saldo)).

list_clientes(C) :- 
	findall([Nome,Cpf,Senha,Telefone, Saldo], cliente(Nome,Cpf,Senha,Telefone, Saldo), C).

remove_cliente :- 
	nl,
	writeln("Insira o CPF da conta a ser excluida: "),
	read_line_to_string(user_input, Cpf),
    list_clientes(C),
    retractall(cliente(_,_,_,_,_)),
    remove_cliente_aux(C, Cpf, C_att),
    add_clientes(C_att),
    tell('./data/bd_clientes.pl'), nl,
    listing(cliente/5),
    told, nl,
    fimMetodoAdm.

remove_cliente_apos_operacao(Cpf) :- 
    list_clientes(C),
    retractall(cliente(_,_,_,_,_)),
    remove_cliente_aux(C, Cpf, C_att),
    add_clientes(C_att),
    tell('./data/bd_clientes.pl'), nl,
    listing(cliente/5),
    told, nl.

remove_cliente_aux([],_,[]) :-
	nl,
	writeln("Usuário inexistente"), nl.
remove_cliente_aux([H|T], Cpf, T) :- member(Cpf, H).
remove_cliente_aux([H|T], Cpf, [H|Out]) :- remove_cliente_aux(T, Cpf, Out).


fimMetodoAdm:-
	writeln("Clique em enter para continuar: "),
	read_line_to_string(user_input, _).
	
editar_contato_gerente :-
	setup_bd_login,
	writeln("Confirme o CPF do gerente"),
	read_line_to_string(user_input, Cpf),
	writeln("Confirme a senha do gerente"),
	read_line_to_string(user_input, Senha),

	(gerente(Cpf, Senha, _) -> nl, 
		writeln("insira o número do contato a ser atualizado."),
		read_line_to_string(user_input, Contato), nl, 
		retract(gerente(Cpf, Senha, _)),
		assert(gerente(Cpf,Senha,Contato)),	
		tell('./data/bd_adm.pl'), nl,
		listing(gerente/3),
		told, 
		tty_clear,
		writeln("Contato atualizado com sucesso."),
		writeln("Pressione qualquer tecla para retornar ao menu."),
		read_line_to_string(user_input, _),
		tty_clear;
	writeln("Senha incorreta."), nl, false).
	

