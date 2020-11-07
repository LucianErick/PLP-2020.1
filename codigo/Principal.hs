import System.IO 
import Control.Exception
import System.IO.Error 
import System.Process
import Control.Monad (when)
import Text.Printf

-----------------------------------------------------------------------------------------------------
import Produto
--import Funcionario
import Cliente
--import Venda
import Util
-----------------------------------------------------------------------------------------------------

getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where getKey' chars = do
          char <- getChar
          more <- hReady stdin
          (if more then getKey' else return) (char:chars)

showSimpleScreen :: [String] -> Integer -> Integer -> IO()
showSimpleScreen [] cursor contador = return ()
showSimpleScreen (o:os) cursor contador = do
   if contador == cursor
      then 
      putStrLn("->" ++ o)
   else
      putStrLn("  " ++ o)
   showSimpleScreen os cursor (contador+1)

lerEntradaString :: IO String
lerEntradaString = do
         hSetBuffering stdin LineBuffering
         hSetEcho stdin True
         x <- getLine
         return x

lerEntradaInt :: IO Int
lerEntradaInt = do
         hSetBuffering stdin LineBuffering
         hSetEcho stdin True
         x <- readLn
         return x

lerEntradaDouble :: IO Double
lerEntradaDouble = do
         hSetBuffering stdin LineBuffering
         hSetEcho stdin True
         x <- readLn
         return x
-----------------------------------------------------------------------------------------------------

opcoesTelaInicial :: [String]
opcoesTelaInicial = ["Entrar como gestor", "Entrar como funcionário", "Entrar como cliente", "Sair"]

doTelaInicial :: Integer -> [Char] -> IO ()
doTelaInicial cursor action | action == "\ESC[B" = telaInicial ((cursor+1) `mod` 4)
                                                    | action == "\ESC[A" && cursor /= 0 = telaInicial (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = telaInicial 3
                                                    | action == "\ESC[C" = mudarTelaInicial cursor
                                                    | action == "\ESC[D" = putStrLn("Sair")
                                                    | otherwise = telaInicial cursor

mudarTelaInicial :: Integer -> IO()
mudarTelaInicial cursor                          | cursor == 0 = do telaOpcoesGestor 0
                                                 | cursor == 1 = do telaOpcoesFuncionario 0            
                                                 | cursor == 2 = do telaOpcoesCliente 0
                                                 | cursor == 3 = do telaSair


telaInicial :: Integer -> IO ()
telaInicial cursor = do
   
   system "clear"
   putStrLn("Bem-vindo à farmácia Corona Pharm!")
   putStrLn("Como desejas acessar?\n")
   putStrLn("\n|| Utilize os direcionais do teclado para mover o cursor ||\n")
   showSimpleScreen opcoesTelaInicial cursor 0
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doTelaInicial cursor action

-------------------------------------------------------------------------------------
-- Tela do gestor

opcoesTelaGestor :: [String]
opcoesTelaGestor = ["Cadastrar produto", "Cadastrar funcionário", "Atualizar preço", "Visualizar produtos", "Visualizar clientes", "Visualizar vendas"]

mudarTelaOpcoesGestor :: Integer -> IO ()
mudarTelaOpcoesGestor cursor
   | cursor == 0 = cadastroProdutosTela
   | cursor == 1 = cadastroFuncionarioTela
   | cursor == 2 = return()
   | cursor == 3 = telaOpcoesVisualizarProdutos 0
   | cursor == 4 = return()
   | cursor == 5 = return()

-- Ajeitar isso, nao sei se funciona normalmente se colocar uma opcao a mais
doOpcoesGestor :: Integer -> [Char] -> IO ()
doOpcoesGestor cursor action | action == "\ESC[B" = telaOpcoesGestor ((cursor+1) `mod` 6)
                                                    | action == "\ESC[A" && cursor /= 0 = telaOpcoesGestor (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = telaOpcoesGestor 5
                                                    | action == "\ESC[C" = mudarTelaOpcoesGestor cursor
                                                    | action == "\ESC[D" = telaInicial 0
                                                    | otherwise = telaOpcoesGestor cursor


telaOpcoesGestor :: Integer -> IO ()
telaOpcoesGestor cursor = do
   
   system "clear"
   putStrLn ("Bem vindo, GESTOR! \n\n|| Aperte (Seta Direita) para escolher qual opcão acessar e (Seta Esquerda) para voltar à tela anterior. ||\n")
   showSimpleScreen opcoesTelaGestor cursor 0
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doOpcoesGestor cursor action

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cadastrar produto
cadastroProdutosTela :: IO () -- Falta colocar todos os parâmetros p realmente ser funcional
cadastroProdutosTela = do
   system "clear"

   putStrLn ("Digite o id do produto:")
   id <- lerEntradaInt -- tem que ajeitar isso

   putStrLn ("\nDigite o nome do produto:")
   nome <- lerEntradaString

   putStrLn ("\nDigite o preço do produto:")
   preco <- lerEntradaDouble

   putStrLn ("\nDigite os sintomas do produto (separados por ','):")
   sintomas <- lerEntradaString
   let listaSintomas = split sintomas ','

   putStrLn ("\nDigite a validade do produto (com '/'):")
   validade <- lerEntradaString

   let produto = Produto id nome preco listaSintomas validade 

   let listaProdutos = [produto]
   let adicionarProduto = listaProdutos
   escreverArquivo adicionarProduto
   
   putStrLn("\nO produto foi cadastrado com sucesso!\n(Mas não se preocupe, ele pode ser modificado futuramente!)")
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey -- acho que n precisa disso
   telaInicial 0 -- Ajeitar isso aqui, ao invés de sair por si só da aplicação, tentar imprimir algo p saber se tem mais alguma alteração

-- Cadastrar funcionario

listaVendasInicialFuncionario:: [String]
listaVendasInicialFuncionario = []

cadastroFuncionarioTela :: IO () -- Falta colocar todos os parâmetros p realmente ser funcional
cadastroFuncionarioTela = do
   system "clear"

   putStrLn ("Digite o nome do funcionário:")
   nomeFuncionario <- lerEntradaString

   putStrLn ("\nDigite o cpf do funcionário:")
   cpfFuncionario <- lerEntradaString -- tem que ajeitar isso

   putStrLn ("\nDigite a data de admissão do funcionário (usando '/'):")
   dataAdmissao <- lerEntradaString

   putStrLn ("\nDigite o salário do funcionário:")
   salario <- lerEntradaDouble

   putStrLn("\nO funcionário foi cadastrado com sucesso!\n(Mas não se preocupe, ele pode ser modificado futuramente!)")
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False

   -- let funcionario = Funcionario nomeFuncionario cpfFuncionario dataAdmissao listaVendasInicialFuncionario salario 

   -- let listaFuncionarios = [funcionario]
   -- let adicionarFuncionario = listaFuncionarios
   -- escreverArquivo adicionarFuncionario
   -- -- action <- getKey -- mudar isso
   -- putStrLn(" ") -- mudar isso, colocar p voltar p tela inicial

-- Atualizar Preço
mudarPrecoProdutoTela :: [Produto] -> IO () -- Falta colocar todos os parâmetros p realmente ser funcional
mudarPrecoProdutoTela produtos = do
   system "clear"

   putStrLn ("\nDigite o id do produto que você deseja alterar:")
   idAtual <- lerEntradaInt

   putStrLn ("\nDigite o novo preço do produto:")
   novoPreco <- lerEntradaDouble
   
   setPreco produtos idAtual novoPreco

   putStrLn("\nO preço do produto foi atualizado com sucesso!\n")
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False


-- Visualizar Clientes 

--------------------------------------------------------------------------------------












--Tela funcionario

opcoesTelaFuncionario :: [String]
opcoesTelaFuncionario = ["Cadastrar cliente", "Cadastrar venda", "Visualizar clientes", "Visualizar produtos", "Visualizar lista de suas vendas"]

mudarTelaOpcoesFuncionario :: Integer -> IO ()
mudarTelaOpcoesFuncionario cursor
   | cursor == 0 = cadastroClienteTela--
   | cursor == 1 = cadastroVendaTela--
   | cursor == 2 = return()--
   | cursor == 3 = telaOpcoesVisualizarProdutos 0--
   | cursor == 4 = return()--

-- Ajeitar isso, nao sei se funciona normalmente se colocar uma opcao a mais
doOpcoesFuncionario :: Integer -> [Char] -> IO ()
doOpcoesFuncionario cursor action | action == "\ESC[B" = telaOpcoesFuncionario ((cursor+1) `mod` 5)
                                                    | action == "\ESC[A" && cursor /= 0 = telaOpcoesFuncionario (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = telaOpcoesFuncionario 4
                                                    | action == "\ESC[C" = mudarTelaOpcoesFuncionario cursor
                                                    | action == "\ESC[D" = telaInicial 0
                                                    | otherwise = telaOpcoesFuncionario cursor


telaOpcoesFuncionario :: Integer -> IO ()
telaOpcoesFuncionario cursor = do
   
   system "clear"
   putStrLn ("Bem vindo, FUNCIONÁRIO! \n\n|| Aperte (Seta Direita) para escolher qual opcão acessar e (Seta Esquerda) para voltar à tela anterior. ||\n")
   showSimpleScreen opcoesTelaFuncionario cursor 0
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doOpcoesFuncionario cursor action









-- Cadastrar Cliente
listaComprasInicialCliente:: [Produto]
listaComprasInicialCliente = []


cadastroClienteTela :: IO () -- Falta colocar todos os parâmetros p realmente ser funcional
cadastroClienteTela = do
   system "clear"

   putStrLn ("Digite o nome do cliente:")
   nomeCliente <- lerEntradaString

   putStrLn ("\nDigite o cpf do cliente:")
   cpfCliente <- lerEntradaString -- tem que ajeitar isso

   putStrLn ("\nDigite a data de cadastro do cliente (usando '/'):")
   dataCadastro <- lerEntradaString

   putStrLn ("\nDigite os sintomas do cliente:")
   sintomasCliente <- lerEntradaString
   let listaSintomasCliente = split sintomasCliente ','

   putStrLn("\nO cliente foi cadastrado com sucesso!\n(Mas não se preocupe, ele pode ser modificado futuramente!)")
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False

   let cliente = Cliente nomeCliente cpfCliente dataCadastro listaComprasInicialCliente listaSintomasCliente

   let listaCliente = [cliente]
   let adicionarCliente = listaCliente
   escreverArquivoCliente adicionarCliente
   
   -- action <- getKey -- acho que n precisa disso

   -- telaInicial (produtos++[(Produto idProduto nomeProduto sintomas validade)]) 0
   telaInicial 0

-- Cadastrar Venda

cadastroVendaTela :: IO () -- Falta colocar todos os parâmetros p realmente ser funcional
cadastroVendaTela = do
   system "clear"

   putStrLn ("Digite o id da venda:")
   idVenda <- lerEntradaInt

   putStrLn ("\nDigite o cpf do cliente:")
   cpfCliente <- lerEntradaString -- tem que ajeitar isso
   
   putStrLn ("\nDigite o cpf do funcionário:")
   cpfFuncionario <- lerEntradaString -- tem que ajeitar isso

   putStrLn ("\nDigite a data de cadastro da venda (usando '/'):")
   dataVenda <- lerEntradaString

   putStrLn ("\nDigite os ids dos produtos (separados por ','):")
   produtosVendidos <- lerEntradaString

   putStrLn("\nA venda foi cadastrada com sucesso!\n")

   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   -- action <- getKey -- acho que n precisa disso

   -- telaInicial (produtos++[(Produto idProduto nomeProduto sintomas validade)]) 0
   putStrLn(" ")

-- Visualizar Clientes
-- Visualizar Lista de Suas vendas

-------------------------------------------------------------------------------------------------------











-- Tela cliente

opcoesTelaCliente :: [String]
opcoesTelaCliente = ["Visualizar produtos", "Comprar produto"]

mudarTelaOpcoesCliente :: Integer -> IO ()
mudarTelaOpcoesCliente cursor
   | cursor == 0 = telaOpcoesVisualizarProdutos 0--
   | cursor == 1 = return()--

-- Ajeitar isso, nao sei se funciona normalmente se colocar uma opcao a mais
doOpcoesCliente :: Integer -> [Char] -> IO ()
doOpcoesCliente cursor action | action == "\ESC[B" = telaOpcoesCliente ((cursor+1) `mod` 2)
                                                    | action == "\ESC[A" && cursor /= 0 = telaOpcoesCliente (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = telaOpcoesCliente 1
                                                    | action == "\ESC[C" = mudarTelaOpcoesCliente cursor
                                                    | action == "\ESC[D" = telaInicial 0
                                                    | otherwise = telaOpcoesCliente cursor


telaOpcoesCliente :: Integer -> IO ()
telaOpcoesCliente cursor = do
   
   system "clear"
   putStrLn ("Bem vindo, CLIENTE \n\n| Aperte (Seta Direita) para escolher qual opcão acessar e (Seta Esquerda) para voltar à tela anterior. ||\n")
   showSimpleScreen opcoesTelaCliente cursor 0
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doOpcoesCliente cursor action

-- Comprar produto

-----------------------------------------------------------------------------------------------------------
-- Tela visualizar produtos

opcoesTelaVisualizarProdutos :: [String]
opcoesTelaVisualizarProdutos = ["Visualizar por sintoma", "Visualizar por existentes no estoque"]

mudarTelaOpcoesVisualizarProdutos :: Integer -> IO ()
mudarTelaOpcoesVisualizarProdutos cursor
   | cursor == 0 = return()--
   | cursor == 1 = return()--

doOpcoesVisualizarProdutos :: Integer -> [Char] -> IO ()
doOpcoesVisualizarProdutos cursor action | action == "\ESC[B" = telaOpcoesVisualizarProdutos ((cursor+1) `mod` 2)
                                                    | action == "\ESC[A" && cursor /= 0 = telaOpcoesVisualizarProdutos (cursor-1)
                                                    | action == "\ESC[A" && cursor == 0 = telaOpcoesVisualizarProdutos 1
                                                    | action == "\ESC[C" = mudarTelaOpcoesVisualizarProdutos cursor
                                                    | action == "\ESC[D" = telaInicial 0 -- n sei se eh tela Inicial mesmo
                                                    | otherwise = telaOpcoesVisualizarProdutos cursor

telaOpcoesVisualizarProdutos :: Integer -> IO ()
telaOpcoesVisualizarProdutos cursor = do
   
   system "clear"
   putStrLn ("Bem vindo à seção de visualzação de produtos!\n\n|| Aperte (Seta Direita) para escolher qual opcão acessar e (Seta Esquerda) para voltar à tela inicial. ||\n")

   showSimpleScreen opcoesTelaVisualizarProdutos cursor 0
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doOpcoesVisualizarProdutos cursor action
-----------------------------------------------------------------------------------------------------------

doTelaSair :: String -> IO ()
doTelaSair action    | action == "s" = return() 
                     | otherwise = telaInicial 0
    
telaSair :: IO ()
telaSair = do
   system "clear"
   putStrLn("Digite (s) para encerrar a execucao ou (Outra tecla) para voltar para o menu");
   
   hSetBuffering stdin NoBuffering
   hSetEcho stdin False
   action <- getKey
   doTelaSair action

-----------------------------------------------------------------------------------------------------------
run :: IO ()
run = do
   {catch (iniciar) error;}
   where
      iniciar = do
      {
         telaInicial 0;
         return ()
      }
      error = ioError 

main :: IO ()
main = do
   run