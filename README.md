# Dockerizando SaudeSimples

- Necessário ter o `docker` e `docker compose`
- Para instalação docker e docker compose acesse: [DOCKER](https://docs.docker.com/engine/install/ubuntu/), [POST-INSTALL](https://docs.docker.com/engine/install/linux-postinstall/), [DOCKER COMPOSE](https://docs.docker.com/compose/)
- `docker compose version # Docker Compose version v2.12.2` versão que foi relaizado a primeira configuração

## Files

- Cone o projeto saudesimples
- Na `root` run `https://github.com/OM30/saudesimples`

- Copie e cole na raiz do projeto a chave pública e privada que tens acesso aos repositórios (NÂO COMMIT ELAS JAMAIS!!!)
- Renomei para `id_ecdsa` e `id_ecdsa.pub`

## RUN in container

 - A depender da versão do `docker compose` rode `docker compose` or ` `docker-compose`
 - Run `docker compose build`

 ![Se tudo der certo no build](docs/images/docker-sucess.png)

 - Run `docker compose run app bash`. Dentro do container siga os passos a seguir
 - Run `echo '{ "allow_root": true }' > /root/.bowerrc`
 - Run `rake bower:install`
 - Se aparecer as questões sobre Jquery escolha a opção `1`: `1.8.0`

 ![Jquery-Answer](docs/images/jquery-ask.png)

## Data base

 - Ainda tem o gargalo de necessitar restaurar o dump do banco atual (Migrations with trouble)

 - Abaixo o exemplo de importação de uma dump `.gz`. Existem outras formas.

 - Com o dump do banco em mãos
 - Copie o dump para o container do postgres Exemplo: `docker cp saudesimples_development.sql.gz <ID_CONTAINER>:/tmp/`
 - Para obter o id do container rode docker ps
 - Depois de copiado

 - Run ` docker exec -it <ID_CONTAINER> bash`. Dentro do container siga os passos a seguir
 - Crie uma ROLE no postgres:
 - Acesse o psql `su - postgres`, `psql`: `CREATE ROLE om30 WITH SUPERUSER;`
 - Crie DATABASE:
 - Acesse o psql `su - postgres`, `psql`: `CREATE DATABASE saudesimples_development;`
 - Saia do PSQL
 - Import o banco: `gunzip -c /tmp/saudesimples_development.sql.gz | psql -U postgres saudesimples_development`

 - Crie o arquivo `saudesimples/config/database.yml` com o conteúdo a seguir:

```ruby
defaults: &defaults
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch("DB_DATABASE") { 'db' } %>
  username: <%= ENV.fetch("DB_USERNAME") { 'postgres' } %>
  password: <%= ENV.fetch("DB_PASSWORD") { 'postgres' } %>
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 30 } %>

development:
  <<: *defaults
  database: saudesimples_development

test:
  <<: *defaults
  database: saudesimples_test

production:
  <<: *defaults
  database: saudesimples_production
```

 - ### Audits

 - É uma boa pratica gerar o dump sem a tabela de auditorias, pois fica bem menor e mais rápido o processamento.

 - É necessário criar a tabela de auditoria de forma separada, mesmo com o dump. Siga os procedimentos previstos [aqui](https://github.com/OM30/saudesimples/wiki/Criar-tabela-Audits)

 ```ruby
 ActiveRecord::Migration.create_table :audits, :force => true do |t|
  t.column :auditable_id, :bigint
  t.column :auditable_type, :string
  t.column :associated_id, :bigint
  t.column :associated_type, :string
  t.column :user_id, :bigint
  t.column :user_type, :string
  t.column :username, :string
  t.column :action, :string
  t.column :audited_changes, :text
  t.column :version, :bigint, :default => 0
  t.column :comment, :string
  t.column :remote_address, :string
  t.column :created_at, :datetime
end
ActiveRecord::Migration.add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
ActiveRecord::Migration.add_index :audits, [:associated_id, :associated_type], :name => 'associated_index'
ActiveRecord::Migration.add_index :audits, [:user_id, :user_type], :name => 'user_index'
ActiveRecord::Migration.add_index :audits, :created_at
ActiveRecord::Migration.add_column :audits, :request_uuid, :string
ActiveRecord::Migration.add_index :audits, :request_uuid
 ```

 - Rode as última migrations: `bundle exec rake db:migrate`

## RUN APP

 - Rode os containers:
 - Run: `docker compose up`
 - ### Elastichsearch

 - `cp saudesimples/config/initializers/elasticsearch.rb.example saudesimples/config/initializers/elasticsearch.rb`
 - Altere `ENV['ELASTICSEARCH_URL'] = 'http://localhost:9200'` para: `ENV['ELASTICSEARCH_URL'] = 'http://elasticsearch:9200'`
 - Para indexar as buscar no elasticsearch após a criação do banco rode a task `rake searchkick:reindex:all`

 ## Tela de acesso

 - Acesso `http://localhost:4000/` e verá como abaixo a tela de login:
 - Acesse `rails c` e altere a senha de produtos `Usuario.where(login: 'produtos').first.update_attribute(:password, 'admin')` ou de outro `Usuário` para ter acesso ao app

 ![Sucesso ao acessar](docs/images/login-success.png)
