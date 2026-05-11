# SisGESC — Sistema de Gestão Escolar

> Projeto de Banco de Dados para gerenciamento acadêmico e financeiro de instituições de ensino.

---

## Sobre o Projeto

O **SisGESC** é um sistema de gestão escolar desenvolvido para organizar e integrar as informações acadêmicas e financeiras de uma instituição de ensino. O objetivo é facilitar o controle de alunos, professores, disciplinas, turmas, contratos e pagamentos, trazendo mais eficiência e reduzindo erros no dia a dia.

**Funcionalidades principais:**

- Cadastro de alunos, professores e disciplinas
- Criação de turmas e realização de matrículas
- Registro de notas e faltas por aluno
- Geração automática de mensalidades a partir de contratos educacionais
- Registro e controle de pagamentos
- Consulta de histórico acadêmico e situação financeira

---

## Estrutura do Repositório

```
erp-gestao-escolar/
│
├── README.md                  ← Este arquivo
├── run_all.sql                ← Script principal (executa tudo em ordem)
│
├── scripts/
│   ├── 01_create_database.sql ← Criação do banco de dados
│   ├── 02_create_tables.sql   ← Criação das tabelas
│   └── 03_insert_data.sql     ← Inserção de dados de exemplo
│
├── der.png                    ← Diagrama Entidade-Relacionamento
└── dicionario_dados.pdf       ← Dicionário de Dados completo
```

---

## Como Executar

### Pre-requisitos

- MySQL 8.0 ou superior
- MySQL Workbench (recomendado) ou outro cliente SQL

### Passo a passo

1. Clone o repositório:

```bash
git clone http://github.com/moreiragustavo/erp-gestao-escolar
cd erp-gestao-escolar
```

2. Abra o MySQL Workbench e conecte-se ao seu servidor local.

3. Execute o script principal:

```sql
SOURCE run_all.sql;
```

> Isso criará o banco, todas as tabelas e inserirá os dados de exemplo automaticamente.

4. Verifique o banco criado:

```sql
USE sisgesc;
SHOW TABLES;
```

---

## Diagrama do Banco de Dados

- DER interativo: https://dbdiagram.io/d/69bf0ee578c6c4bc7a393ab7
- Arquivo local: `der.png`

O banco possui dois modelos:

- **Modelo Relacional (OLTP)** — para operações do dia a dia
- **Modelo Estrela (OLAP)** — para análise e relatórios gerenciais

---

## Tabelas do Banco

| Tabela | Descricao |
|---|---|
| `tb_alunos` | Cadastro de alunos |
| `tb_cursos` | Cursos disponíveis |
| `tb_disciplinas` | Disciplinas vinculadas a cursos |
| `tb_turmas` | Turmas por disciplina e semestre |
| `tb_matriculas` | Matrículas de alunos em turmas |
| `tb_notas` | Notas por aluno, turma e tipo de avaliação |
| `tb_faltas` | Controle de faltas por aluno e turma |
| `tb_funcionarios` | Cadastro geral de funcionários |
| `tb_professores` | Dados específicos dos professores |
| `tb_professor_especialidades` | Especialidades de cada professor |
| `tb_vinculos_professor_disciplina` | Relação professor e disciplina |
| `tb_contratos_educacionais` | Contratos financeiros por aluno |
| `tb_mensalidades` | Mensalidades geradas por contrato |
| `tb_pagamentos` | Pagamentos realizados |
| `tb_folha_pagamento` | Folha de pagamento dos funcionários |

---

## Regras de Negocio

- Um aluno pode estar em várias turmas, mas cada matrícula pertence a **um único aluno e uma única turma**
- Cada turma está ligada a **uma disciplina**; uma disciplina pode ter várias turmas
- Professores e disciplinas possuem relação de **muitos para muitos**
- Um professor pode ter **múltiplas especializações**, registradas individualmente
- Contratos pertencem a um único aluno, mas um aluno pode ter **vários contratos** ao longo do tempo
- Cada contrato gera mensalidades; cada mensalidade pode ter **no máximo um pagamento**
- Notas devem estar **entre 0 e 10**
- Status das mensalidades: `PENDENTE`, `PAGO` ou `ATRASADO`
- **Pagamentos só podem ser feitos se houver contrato ativo**
- Não é permitido pagamento duplicado, notas fora do padrão ou matrícula sem vínculo válido

---

## Requisitos Nao Funcionais

- Acesso via **navegador web** com autenticação de usuário
- Suporte a **múltiplos usuários simultâneos**
- Interface **simples e responsiva**
- Dados armazenados com **segurança e integridade**
- **Alta disponibilidade** e baixa latência nas consultas

---

## Integrantes

| Nome |
|---|
| Eduardo Santana Silva | — |
| Elias Augusto Segura | — |
| Felipe Rocha Amorim | — |
| Giovanni Araujo Campos  | — |
| Gustavo Cavalcante Moreira | — |
| Kauã Luka Sousa Fernandes  | — |
| Victor Hugo dos Santos Oliveira | — |
| João Pedro da Silva Costa | — |


---

## Links

- Repositório: http://github.com/moreiragustavo/erp-gestao-escolar
- DER Online: https://dbdiagram.io/d/69bf0ee578c6c4bc7a393ab7
