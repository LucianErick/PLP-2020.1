:-use_module(library(csv)).
:-include('Arquivos.pl').

cadastraProduto(Id, Nome, Preco, Validade) :-
    open('../arquivos/Produtos.csv', append, File),
    writeln(File, (Id, Nome, Preco, Validade)),
    close(File).

cadastraSintomaProduto(Id, Sintomas) :-
    open('../arquivos/SintomasProdutos.csv', append, File),
    sintomasEmLista(Sintomas, ListaSintomas),
    writeln(File, (Id, ListaSintomas)),
    close(File).

sintomasEmLista(StringSintomas, ListaSintomas) :-
    split_string(StringSintomas, '', ',', ListaSintomas).
%--------------------------------------------------------------------------------