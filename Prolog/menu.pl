:- include('./cliente.pl').
:- include('./gerente.pl').
	                                                        

main :- 
	tty_clear, 
	mostraMenu, nl.

printLine() :- write('-----------------------------------------------'), nl.

mostraMenu :-
	printLine,
	writeln("--- Bem-vindo ao Sistema Bancário SBHaskell ---"), nl, 
	printLine,
	writeln("Selecione uma das opções abaixo:"),
	writeln("1 - Sou Gerente"),
	writeln("2 - Sou Cliente"),
	writeln("3 - Sair"), nl,
	printLine,

	read_line_to_string(user_input, Option),
	(Option == "1" -> tty_clear, login_gerente -> tty_clear, menuGerente;
	Option == "2" -> tty_clear, menuCliente;
	Option == "3" -> tty_clear, sair;
	opcaoInvalida,
	mostraMenu, nl, halt).

menuGerente :-
	writeln("Selecione uma das opções abaixo:"), nl,
	writeln("1 - Ver clientes cadastrados no sistema"),
	writeln("2 - Remover clientes"),
	writeln("3 - Atualizar contato do gerente"),
	writeln("4 - Ver empréstimos"),
	writeln("5 - Ver Investimentos"),
	writeln("0 - Voltar"),
	printLine,
	read_line_to_string(user_input, Option),
	(Option == "1" -> tty_clear, listaClientes, tty_clear, menuGerente;
	Option == "2" -> tty_clear, remove_cliente, menuGerente;
	Option == "3" -> tty_clear, editar_contato_gerente, menuGerente;
	Option == "0" -> tty_clear, mostraMenu;
	opcaoInvalida,
	menuGerente).

menuCliente :-
	writeln("Selecione uma das opções abaixo:"),
	writeln("1 - Criar uma conta"),
	writeln("2 - Logar no sistema como cliente"),
	writeln("3 - Ver contato do gerente"),
	writeln("0 - Retornar ao menu principal"),
	read_line_to_string(user_input, Option),
	(Option == "1" -> tty_clear, cadastraCliente, tty_clear, menuCliente;
	Option == "2" -> (tty_clear, login_cliente(Cpf) -> tty_clear, segundoMenuCliente(Cpf) ; tty_clear, mostraMenu);
	Option == "3" -> (tty_clear, exibir_contato_gerente, tty_clear, menuCliente);
	Option == "0" -> tty_clear, mostraMenu;
	opcaoInvalida,
	menuCliente).

segundoMenuCliente(Cpf) :-
	writeln("Selecione uma das opções abaixo:"), nl,
	writeln("1 - Consultar dados da minha conta"),
	writeln("2 - Realizar Saque"),
	writeln("3 - Realizar Depósito"),
	writeln("4 - Realizar Empréstimo"),
	writeln("5 - Realizar Investimento"),
	writeln("0 - Retornar para o menu principal"),
	printLine,
	read_line_to_string(user_input, Option),
	(Option == "0" -> tty_clear, mostraMenu;
	opcaoInvalida,
	segundoMenuCliente(Cpf)).

exibir_contato_gerente:- nl,
	consult('./data/bd_gerente.pl'),
	gerente("123",_,Contato),
	writeln(Contato),

	writeln("pressione qualquer tecla para voltar ao menu"),
	read_line_to_string(user_input, _).

sair :- halt.

opcaoInvalida :-
	 writeln("Opcao invalida!"), nl.