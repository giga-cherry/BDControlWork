-- Задание 2
create TYPE processing_status as ENUM ('OK', 'Not OK');
create TYPE transaction_status as ENUM ('OK', 'Not OK');

create table account
(
    id         bigserial primary key,
    first_name varchar(32) not null,
    last_name  varchar(32) not null,
    patronymic varchar(32) not null
);

create table country
(
    id   bigserial primary key,
    name varchar(32)
);

create table terminal
(
    id   bigserial primary key,
    ipv4 inet
);

create table pay_type
(
    id   bigserial primary key,
    type varchar(32)
);

create table pay_method
(
    id     bigserial primary key,
    method varchar(32)
);

create table currency
(
    id              bigserial primary key,
    name            varchar(32) not null,
    value_to_dollar decimal     not null
);


create table transaction
(
    id                 bigserial primary key,
    transaction_date   date               not null,
    currency_type_id   bigint             not null references currency (id),
    amount_of_money    bigint             not null,
    check ( amount_of_money > 0 ),
    cost_of_risk       decimal            not null,
    check ( cost_of_risk >= 0 and cost_of_risk <= 100),
    pay_type_id        bigint             not null references pay_type (id),
    pay_method_id      bigint             not null references pay_method (id),
    processing_status  processing_status  not null,
    last_four_digits   int                not null,
    check ( last_four_digits > 999 and last_four_digits < 10000),
    transaction_status transaction_status not null,
    terminal_id        bigint             not null references terminal (id),
    user_id            bigint             not null references account (id),
    country_id         bigint             not null references country (id)
);

-- Задание 3. Витрина данных путем создания таблиц, где хранятся агрегированные данные актуальные к моменту времени, когда запрос был выполнен. Таким образом хранится агрегированная история платежей.
create materialized view country_statistic as select c.name, sum(amount_of_money*cur.value_to_dollar) as monthly_sum_in_dollars, date_trunc('month', transaction_date) as month from transaction left join country c on c.id = transaction.country_id left join currency cur on cur.id=transaction.currency_type_id group by c.name, month;

create materialized view currency_statistic as select c.name, sum(amount_of_money) as monthly_sum, date_trunc('month', transaction_date) as month from transaction left join currency c on transaction.currency_type_id = c.id group by c.name, month;

create materialized view transaction_status_statistic as select transaction_status, sum(amount_of_money) as monthly_sum, date_trunc('month', transaction_date) as month from transaction group by transaction_status, month;
