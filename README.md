# Ant Colony

Uma demo interativa de supervisão em Elixir/OTP. A colônia começa com 50 formigas andando pelo tabuleiro. Cada formiga é um processo `GenServer`, e um `Supervisor` decide quais processos reiniciar quando uma delas falha.

## Como rodar

Com Elixir e Erlang/OTP instalados, rode o script abaixo na raiz do projeto.

```bash
elixir ant_colony.exs
```

Na primeira execução, o script baixa a biblioteca Owl via `Mix.install/1`. Para usar o ambiente pronto com Elixir 1.19 e OTP 28, abra a pasta no VS Code com Docker e a extensão Dev Containers, selecione **Dev Containers: Reopen in Container** e execute o mesmo comando no terminal do contêiner.

## Controles

Digite um comando e pressione Enter.

| Tecla | Ação |
| --- | --- |
| `a` | Adiciona 10 formigas. |
| `f` | Provoca uma falha na formiga de demonstração, a F50. |
| `1` | Seleciona `one_for_one`. Só a formiga que falhou reinicia. |
| `2` | Seleciona `one_for_all`. Todas as formigas reiniciam. |
| `3` | Seleciona `rest_for_one`. Reiniciam a formiga que falhou e as que foram iniciadas depois dela. |
| `q` | Encerra a demo. |

O painel mostra quantas formigas estão ativas, quantas falhas foram provocadas e quantos processos reiniciaram. Depois de uma falha, o painel também exibe os IDs das formigas reiniciadas e a troca de PID da F50. Com a atualização ao vivo do terminal, as formigas reiniciadas aparecem como losangos que piscam em vermelho e branco por três segundos.

## Experimente

1. Pressione `f` com a estratégia inicial, `one_for_one`. Só a F50 reinicia.
2. Pressione `2` e depois `f`. As 50 formigas reiniciam.
3. Pressione `a`, depois `3` e por fim `f`. Reiniciam 11 formigas, da F50 à F60.

## Código

- [`ant_colony.exs`](ant_colony.exs) instala a dependência e inicia a demo.
- [`lib/ant_colony.ex`](lib/ant_colony.ex) configura o supervisor e identifica os reinícios comparando os PIDs antes e depois da falha.
- [`lib/ant_colony/ant.ex`](lib/ant_colony/ant.ex) implementa o movimento de cada formiga.
- [`lib/ant_colony/terminal.ex`](lib/ant_colony/terminal.ex) coordena os comandos e a atualização da interface.
