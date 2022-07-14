{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
{-# HLINT ignore "Use newtype instead of data" #-}
{-# OPTIONS_GHC -Wno-overlapping-patterns #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

import Data.Char (isDigit, toLower)
import qualified Distribution.Compat.CharParsing as DisponibilidadeHotelzinho
import System.Directory (doesFileExist, removeFile)
import System.IO
  ( IO,
    IOMode (ReadMode, ReadWriteMode, WriteMode),
    getLine,
    hClose,
    hFlush,
    hGetContents,
    hGetLine,
    hPutStr,
    hPutStrLn,
    openFile,
    putStrLn,
  )
import System.IO.Error ()
import Prelude hiding (catch)

data Gerente = Gerente
  { nomeGerente :: String,
    senhaGerente :: String,
    telefoneGerente :: String
  }
  deriving (Read, Show)

data Cliente = Cliente
  { nomeCliente :: String,
    cpf :: String,
    senha :: String,
    telefone :: String,
    saldo :: String
  }
  deriving (Read, Show)


printLine :: IO ()
printLine = putStrLn "\n------------------------------------------"

main :: IO ()
main = do
  printLine
  putStr "Boas vindas! Sistema Bancário"
  showMenu

showMenu :: IO ()
showMenu = do
  printLine
  putStrLn "\nSelecione uma das opções abaixo:\n"

  putStrLn "1 - Sou Gerente"
  putStrLn "2 - Sou Cliente"
  putStrLn "3 - Sair"
  printLine

  putStr "Opção: "
  opcao <- getLine
  menus opcao

menus :: String -> IO ()
menus x
  | x == "1" = acessoGerente
  | x == "2" = menuCliente
  | x == "3" = encerrarSessao
  | otherwise = invalidOption showMenu

menuGerente :: IO ()
menuGerente = do
  printLine
  putStrLn "\nSelecione uma das opções abaixo:\n"
  putStrLn "1 - Ver usuários cadastrados no sistema"
  putStrLn "2 - Remover usuários"
  putStrLn "3 - Atualizar contato Gerente"
  putStrLn "4 - Editar dados de um Cliente"
  putStrLn "0 - Voltar"
  printLine
  putStr "Opção: "
  opcao <- getLine
  opcaoGerente opcao

opcaoGerente :: String -> IO ()
opcaoGerente x
  | x == "1" = verClientesCadastrados
  | x == "2" = removerCliente
  | x == "3" = atualizarContatoGerente
  -- | x == "4" = editarCliente
  | x == "0" = showMenu
  | otherwise = invalidOption menuGerente

menuCliente :: IO ()
menuCliente = do
  printLine
  putStrLn "\nSelecione uma das opções abaixo:\n"
  putStrLn "1 - Criar uma conta"
  putStrLn "2 - Logar no sistema como cliente"
  putStrLn "3 - Ver contato do gerente"
  putStrLn "0 - Voltar ao menu principal"
  printLine
  putStr "Opção: "
  opcao <- getLine
  opcaoCliente opcao

opcaoCliente :: String -> IO ()
opcaoCliente x
  | x == "1" = cadastrarComoCliente
  | x == "2" = logarComoCliente
  | x == "3" = verContatoDoGerente
  | x == "0" = showMenu
  | otherwise = invalidOption menuCliente

segundoMenuCliente :: String -> IO ()
segundoMenuCliente cpf = do
  printLine
  putStrLn "\nSelecione o que deseja como cliente\n"
  putStrLn "1 - Consultar dados da minha conta"
  putStrLn "2 - Realizar saque"
  putStrLn "3 - Realizar depósito"
  putStrLn "4 - Realizar empréstimo"
  putStrLn "5 - Realizar investimento"
  putStrLn "0 - Retornar para o menu"
  printLine
  putStr "Opção: "
  opcao <- getLine
  segundaTelaCliente opcao cpf

segundaTelaCliente :: String -> String -> IO ()
segundaTelaCliente x cpf
  -- | x == "1" = consultarDados cpf
  -- | x == "2" = realizarSaque cpf
  -- | x == "3" = realizarDeposito cpf
  -- | x == "4" = realizarEmprestimo cpf
  -- | x == "5" = realizarInvestimento cpf
  | x == "0" = menuCliente
  | otherwise = invalidOption (segundoMenuCliente cpf)

atualizarContatoGerente :: IO ()
atualizarContatoGerente = do
  printLine
  putStrLn "\nTem certeza que deseja atualizar o contato do Gerente?"
  putStrLn "\n--Aperte 1 para continuar--"
  printLine
  opcao <- getLine
  opcaoContato opcao

opcaoContato :: String -> IO ()
opcaoContato x
  | x == "1" = mudaContato
  | otherwise = invalidOption menuGerente

encerrarSessao :: IO ()
encerrarSessao = do
  printLine
  putStrLn "Saindo... Até a próxima!"
  printLine

invalidOption :: IO () -> IO ()
invalidOption function = do
  putStrLn "\nSelecione uma alternativa válida"
  function

------- Metodos Admnistrador -------

imprimeClientesCadastrados :: [Cliente] -> Int -> IO ()
imprimeClientesCadastrados [] 0 = putStrLn "\nNenhum cliente cadastrado"
imprimeClientesCadastrados [] _ = putStrLn "\nClientes listados com sucesso"
imprimeClientesCadastrados (x : xs) n = do
  putStrLn (show n ++ " - nome: " ++ obterNomes x ++ " - cpf: " ++ obterCpf x ++ " - telefone: " ++ obterTelefone x ++ " - saldo: R$ " ++ obterSaldo x)
  imprimeClientesCadastrados xs (n + 1)

verClientesCadastrados :: IO ()
verClientesCadastrados = do
  arquivoExiste <- doesFileExist "clientes.txt"

  if arquivoExiste then do
    file <- openFile "clientes.txt" ReadMode
    contents <- hGetContents file
    let clientes = lines contents

    printLine
    imprimeClientesCadastrados [read x :: Cliente | x <- clientes] 0
  else do
    putStrLn "\nNão há clientes cadastrados."
  menuGerente


removerCliente :: IO ()
removerCliente = do
  clientesCadastrados <- doesFileExist "clientes.txt"
  if not clientesCadastrados
    then do
      putStrLn "Não há clientes cadastrados!"
    else do
      putStr "\nInsira o cpf do cliente a ser removido: "
      cpf <- getLine

      file <- openFile "clientes.txt" ReadMode
      clientesContent <- hGetContents file
      let clientes = lines clientesContent
      let hasCliente = encontraCliente [read x :: Cliente | x <- clientes] cpf ""

      if not hasCliente
        then do
          putStrLn ("\nCliente com cpf: '" ++ cpf ++ "' não existe!")
        else do
          removeFile "clientes.txt"
          let novaListaDeClientes = [read x :: Cliente | x <- clientes, obterCpf (read x :: Cliente) /= cpf]
          atualizaClientes novaListaDeClientes
          putStrLn "Cliente removido com sucesso!"

  menuGerente

atualizaClientes :: [Cliente] -> IO ()
atualizaClientes [] = putStrLn "Cliente removido com sucesso!\n"
atualizaClientes (x : xs) = do
  clientesCadastrados <- doesFileExist "clientes.txt"
  if not clientesCadastrados
    then do
      file <- openFile "clientes.txt" WriteMode
      hPutStr file (show x)
      hFlush file
      hClose file
    else appendFile "clientes.txt" ("\n" ++ show x)
  atualizaClientes xs

acessoGerente :: IO ()
acessoGerente = do
  printLine
  putStrLn "\nFaça acesso como gerente"
  putStr "Senha gerente: "
  senha <- getLine

  gerenteDados <- readFile "gerente.txt"
  let gerente = read gerenteDados :: Gerente

  if obterGerente gerente "senha" == senha
    then do
      menuGerente
    else do
      printLine
      putStrLn "Senha inválida!"
      putStr "Deseja tentar fazer login como gerente novamente! (s/n): "
      opcao <- getChar

      if toLower opcao == 's'
        then do
          acessoGerente
        else showMenu



mudaContato :: IO ()
mudaContato = do
  gerenteContent <- readFile "gerente.txt"
  let gerenteDados = read gerenteContent :: Gerente

  putStr "\nInsira o novo número de contato: "
  novoNumero <- getLine

  removeFile "gerente.txt"
  gerenteFile <- openFile "gerente.txt" WriteMode

  let gerente =
        Gerente
          { nomeGerente = obterGerente gerenteDados "nome",
            senhaGerente = obterGerente gerenteDados "senha",
            telefoneGerente = novoNumero
          }

  hPutStr gerenteFile (show gerente)
  hFlush gerenteFile
  hClose gerenteFile

  putStrLn "\nContato atualizado com sucesso!"
  menuGerente
------------------------------------

--------- Metodos Clientes ---------
cadastrarComoCliente :: IO ()
cadastrarComoCliente = do
  putStr "\nInsira seu nome: "
  nome <- getLine

  putStr "Insira seu cpf: "
  cpf <- getLine

  putStr "Insira sua senha: "
  senha <- getLine

  putStr "Insira seu telefone: "
  telefone <- getLine

  putStr "Insira seu saldo inicial: "
  saldo <- getLine


  putStrLn ""

  fileExists <- doesFileExist "clientes.txt"
  if fileExists
    then do
      file <- openFile "clientes.txt" ReadMode
      contents <- hGetContents file
      let clientes = lines contents
      let hasThisClient = encontraCliente ([read x :: Cliente | x <- clientes]) cpf ""

      if hasThisClient
        then do
          putStrLn "Usuario ja existente"
          menuCliente
        else do
          criarCliente nome cpf senha telefone saldo
    else do
      criarCliente nome cpf senha telefone saldo

criarCliente :: String -> String -> String -> String -> String -> IO ()
criarCliente nome cpf senha telefone saldo = do
  let cliente = Cliente {nomeCliente = nome, cpf = cpf, senha = senha, telefone = telefone, saldo = saldo}

  clientesCadastrados <- doesFileExist "clientes.txt"

  if clientesCadastrados
    then do
      file <- appendFile "clientes.txt" ("\n" ++ show cliente)
      putStrLn "Cliente cadastrado com sucesso!"
      menuCliente
    else do
      file <- appendFile "clientes.txt" (show cliente)
      menuCliente

logarComoCliente :: IO ()
logarComoCliente = do
  printLine
  putStr "Insira seu cpf: "
  cpf <- getLine
  fileExists <- doesFileExist "clientes.txt"

  if fileExists
    then do
      putStr "Insira sua senha: "
      senha <- getLine
      file <- openFile "clientes.txt" ReadMode
      contents <- hGetContents file
      let clientes = lines contents
      let hasCliente = encontraCliente [read x :: Cliente | x <- clientes] cpf senha

      if hasCliente
        then do
          putStrLn "\nLogin realizado com sucesso"
          segundoMenuCliente cpf
        else do
          putStrLn "\nNome ou senha incorretos"
          menuCliente
      hClose file
    else do
      putStrLn "Nenhum cliente não cadastrado. Por favor, cadastre-se"
      cadastrarComoCliente

verContatoDoGerente :: IO ()
verContatoDoGerente= do
  gerenteContent <- readFile "gerente.txt"
  let gerente = read gerenteContent :: Gerente
  putStr "\nContato: "
  putStrLn (obterGerente gerente "telefone")

  menuCliente

------------------------------------

-------- Metodos auxiliares --------

obterCliente :: Cliente -> String -> String
obterCliente Cliente {nomeCliente = n, cpf = e, senha = s, telefone = t, saldo = sa} prop
  | prop == "nomeCliente" = n
  | prop == "cpf" = e
  | prop == "senha" = s
  | prop == "telefone" = t
  | prop == "saldo" = sa

-- editCliente :: Cliente -> Animal -> Cliente
-- editCliente Cliente {nomeCliente = n, email = e, senha = s, telefone = t} a = Cliente {nomeCliente = n, email = e, senha = s, telefone = t}


obterGerente :: Gerente -> String -> String
obterGerente Gerente {nomeGerente = n, senhaGerente = s, telefoneGerente = t} prop
  | prop == "nome" = n
  | prop == "senha" = s
  | prop == "telefone" = t

 

indexCliente :: [Cliente] -> String -> Int -> Int
indexCliente (c : cs) cpf i
  | obterCliente c "cpf" == cpf = i
  | obterCliente c "cpf" /= cpf = next
  where
    next = indexCliente cs cpf (i + 1)




toStringListCliente :: [Cliente] -> String
toStringListCliente (x : xs) = show x ++ "\n" ++ toStringListCliente xs
toStringListCliente [] = ""

toCliente :: String -> Cliente
toCliente c = read c :: Cliente

toObjListCliente :: [String] -> [Cliente]
toObjListCliente = map toCliente

obterCpf :: Cliente -> String
obterCpf Cliente {nomeCliente = c, cpf = e, senha = s, telefone = t, saldo = sa} = e

obterSenha :: Cliente -> String
obterSenha (Cliente _ _ senha _ _) = senha

obterNomes :: Cliente -> String
obterNomes (Cliente nomeCliente _ _ _ _) = nomeCliente

obterTelefone :: Cliente -> String
obterTelefone (Cliente _ _ _ telefone _) = telefone

obterSaldo :: Cliente -> String
obterSaldo (Cliente _ _ _ _ saldo) = saldo

encontraCliente :: [Cliente] -> String -> String -> Bool
encontraCliente [] cpf senha = False
-- Procura Cliente somente verificando o cpf
encontraCliente (c : cs) cpf ""
  | obterCliente c "cpf" == cpf = True
  | obterCliente c "cpf" /= cpf = encontrar
  where
    encontrar = encontraCliente cs cpf ""
-- Procura Cliente verificando o cpf e a senha
encontraCliente (c : cs) cpf senha
  | obterCliente c "cpf" == cpf && obterCliente c "senha" == senha = True
  | obterCliente c "cpf" /= cpf || obterCliente c "senha" /= senha = encontrar
  where
    encontrar = encontraCliente cs cpf senha

