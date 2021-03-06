--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1 (Ubuntu 11.1-3.pgdg18.04+1)
-- Dumped by pg_dump version 11.1 (Ubuntu 11.1-3.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP ROLE IF EXISTS "user";
CREATE ROLE "user" SUPERUSER INHERIT LOGIN PASSWORD 'user';

DROP DATABASE IF EXISTS alina_db;
--
-- Name: alina_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE alina_db WITH TEMPLATE = template0 ENCODING = 'UTF8';


\connect alina_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: discount_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.discount_type AS ENUM (
    '5',
    '10',
    '15'
);


--
-- Name: payment_method_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_method_type AS ENUM (
    'credit_card',
    'cash'
);


--
-- Name: status_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.status_type AS ENUM (
    'created',
    'processed',
    'completed',
    'canceled '
);


--
-- Name: waiter_status_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.waiter_status_type AS ENUM (
    'working',
    'quit',
    'maternity leave',
    'fired'
);


--
-- Name: calc_cost(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calc_cost(id integer, number integer) RETURNS money
    LANGUAGE plpgsql
    AS $$
 
declare price money;
 begin
select price_dish into price from public.dishes where dish_id=id; 

RETURN price*number;
end;
$$;


--
-- Name: calc_discount_coeff(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calc_discount_coeff(id bigint) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare client uuid;
declare coeff double precision;
declare discoun_p discount_type;
begin
	select client_id into client from public.orders where order_id=id; 
	if client notnull then
		select discount into discoun_p from public.clients where client_id=client;
	 	case
	 		when discoun_p = '5' then coeff = 0.95;
	 		when discoun_p = '10' then coeff = 0.90;
	 		when discoun_p = '15' then coeff = 0.85;
		end case;
	else coeff=1;
	end if;
	RETURN coeff;
end;
$$;


--
-- Name: FUNCTION calc_discount_coeff(id bigint); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.calc_discount_coeff(id bigint) IS 'Вычисляет коэффициент скидки клиента. Принимает на вход orders.order_id.
Находит соответсвующего клиента для данного id заказа, и,
если клиент есть в базе, возвращает коэффициент, на который будет умножена стоимость.';


--
-- Name: calc_included_tip(money); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calc_included_tip(order_cost_with_tip money) RETURNS money
    LANGUAGE plpgsql
    AS $$
 begin
RETURN order_cost_with_tip*0.1;
end;
$$;


--
-- Name: calc_order_cost(bigint, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calc_order_cost(id bigint, tip boolean) RETURNS money
    LANGUAGE plpgsql
    AS $$
 
declare order_cost money;
 begin
select sum(total_cost) into order_cost from 
public.dishes_list where order_id=id; 

if tip=true then
order_cost=1.1*order_cost;
end if;

RETURN order_cost;
end;
$$;


--
-- Name: FUNCTION calc_order_cost(id bigint, tip boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.calc_order_cost(id bigint, tip boolean) IS 'Вычисляет предварительную (без учета скидки клиета) стоимость заказа. Принимает на вход orders.order_id и orders.is_tip_included. Проходится по справочнику dishes_list и выдает суммарную стоимость для данного orders.order_id; если чаевые включены, домножает на соответсвующий коэффициент (чаевые 10%)';


SET default_with_oids = false;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    client_id uuid NOT NULL,
    first_name character varying(40) NOT NULL,
    last_name character varying(40) NOT NULL,
    "DOB" date,
    "e-mail" character varying(40),
    phone_number character varying(16),
    discount public.discount_type DEFAULT '5'::public.discount_type,
    CONSTRAINT phone_number_num CHECK (((phone_number)::text ~ '^[0-9]+$'::text)),
    CONSTRAINT real_dob CHECK (("DOB" > '1890-01-01'::date))
);


--
-- Name: COLUMN clients.client_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.clients.client_id IS 'тип - uuid, т.к. суррогатный ключ и может нести в себе конфиденциальную информацию';


--
-- Name: COLUMN clients."DOB"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.clients."DOB" IS 'может быть равен NULL, например, клиент не захотел указывать дату рождения;
constraint - дата рождения должна быть > 1890/01/01 (реальной)';


--
-- Name: CONSTRAINT real_dob ON clients; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT real_dob ON public.clients IS 'дата рождения должна быть > 1890/01/01 (реальной)';


--
-- Name: dishes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dishes (
    dish_id integer NOT NULL,
    name_dish character varying(40) NOT NULL,
    price_dish money NOT NULL,
    CONSTRAINT positive_price CHECK ((price_dish > money(0.0)))
);


--
-- Name: COLUMN dishes.dish_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dishes.dish_id IS 'тип - serial, т.к. суррогатный ключ и не несет в себе конфиденциальной информации';


--
-- Name: COLUMN dishes.price_dish; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dishes.price_dish IS 'constraint - стоимость д.б. больше 0;
предположительно стоимость в других таблицах будет рассчитываться автоматически, ориентируясь на данные значения';


--
-- Name: CONSTRAINT positive_price ON dishes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT positive_price ON public.dishes IS ' стоимость д.б. больше 0';


--
-- Name: dishes_dish_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dishes_dish_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dishes_dish_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dishes_dish_id_seq OWNED BY public.dishes.dish_id;


--
-- Name: dishes_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dishes_list (
    dishes_list_id bigint NOT NULL,
    dish_id integer NOT NULL,
    number_of_dishes smallint NOT NULL,
    total_cost money,
    order_id bigint NOT NULL,
    CONSTRAINT several_dishes CHECK ((number_of_dishes > 0))
);


--
-- Name: COLUMN dishes_list.dishes_list_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dishes_list.dishes_list_id IS 'тип - serial, т.к. суррогатный ключ и не несет в себе конфиденциальной информации';


--
-- Name: COLUMN dishes_list.number_of_dishes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dishes_list.number_of_dishes IS 'constraint - количество блюд в списке д.б. > 1';


--
-- Name: COLUMN dishes_list.total_cost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dishes_list.total_cost IS 'тип - деньги, возможно, должен вычисляться автоматически - стоимость одного блюда*количество';


--
-- Name: dishes_list_dishes_list_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dishes_list_dishes_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dishes_list_dishes_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dishes_list_dishes_list_id_seq OWNED BY public.dishes_list.dishes_list_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    order_id bigint NOT NULL,
    table_number smallint,
    client_id uuid,
    start_time timestamp(6) without time zone NOT NULL,
    end_time timestamp(6) without time zone,
    order_price money,
    tip money DEFAULT 0.0 NOT NULL,
    payment_method public.payment_method_type DEFAULT 'cash'::public.payment_method_type NOT NULL,
    status public.status_type DEFAULT 'created'::public.status_type NOT NULL,
    is_tip_included boolean DEFAULT false,
    final_order_price money,
    CONSTRAINT positive_tip CHECK ((tip >= money(0.0)))
);


--
-- Name: COLUMN orders.order_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.order_id IS 'тип - serial, т.к. суррогатный ключ и не несет в себе конфиденциальной информации';


--
-- Name: COLUMN orders.table_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.table_number IS 'может быть равен NULL, т.к. заказ может быть взят с собой';


--
-- Name: COLUMN orders.client_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.client_id IS 'может быть равен NULL, если клиент не зарегистрирован в БД ресторана';


--
-- Name: COLUMN orders.start_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.start_time IS 'тип - дата и время без указания зоны; хранит время и дату начала заказа';


--
-- Name: COLUMN orders.end_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.end_time IS 'тип - дата и время без указания зоны; хранит время и дату начала заказа';


--
-- Name: COLUMN orders.order_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.order_price IS 'тип - деньги, общая стоимость заказа (возможно, должен вычисляться автоматически из disfes_list + обязательные чаевые (если они есть))';


--
-- Name: COLUMN orders.tip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.tip IS 'тип - деньги, чаевые;
constraint - чаевые д.б. больше либо равны 0;';


--
-- Name: COLUMN orders.payment_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.payment_method IS 'тип - enum payment_method_type, перечисление возможных способов оплаты';


--
-- Name: COLUMN orders.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.orders.status IS 'тип - enum status_type, перечисление возможных статусов заказов (еще в процессе осмысления, какими они могу быть);
индекс по статусу заказа. Думаю, потребуется
при сортировке и анализе заказов, при выполнении активных заказов';


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tables (
    table_number smallint NOT NULL,
    number_of_seats smallint DEFAULT 2 NOT NULL
);


--
-- Name: COLUMN tables.table_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tables.table_number IS 'значений до 32767 для номеров столов должно хватить';


--
-- Name: COLUMN tables.number_of_seats; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tables.number_of_seats IS 'значений до 32767 для посадочных мест должно хватить; значение по умолчанию - 2 пусть самое часто встречающееся для данного ресторана';


--
-- Name: waiters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waiters (
    waiter_id uuid NOT NULL,
    first_name character varying(40) NOT NULL,
    last_name character varying(40) NOT NULL,
    start_working date NOT NULL,
    passport_series character varying(8) NOT NULL,
    passport_number character varying(8) NOT NULL,
    waiter_status public.waiter_status_type DEFAULT 'working'::public.waiter_status_type NOT NULL,
    finish_working date
);


--
-- Name: COLUMN waiters.waiter_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.waiters.waiter_id IS 'тип - uuid, т.к. суррогатный ключ и может нести в себе конфиденциальную информацию';


--
-- Name: COLUMN waiters.passport_series; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.waiters.passport_series IS 'серия - максимум 8ми значное значение (с запасом); не выбрано в качестве составного ключа - довольно личная информация';


--
-- Name: COLUMN waiters.passport_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.waiters.passport_number IS 'номер - максимум 8ми значное значение (с запасом); не выбрано в качестве составного ключа - довольно личная информация';


--
-- Name: COLUMN waiters.waiter_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.waiters.waiter_status IS 'тип - enum waiter_status_type, перечисление рабочего статуса официанта;
индекс по рабочему статусу официантов.
Возможно будет удобно для анализа персонала';


--
-- Name: waiters_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waiters_orders (
    waiter_id uuid NOT NULL,
    order_id bigint NOT NULL
);


--
-- Name: waiters_orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.waiters_orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: waiters_orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.waiters_orders_order_id_seq OWNED BY public.waiters_orders.order_id;


--
-- Name: dishes dish_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes ALTER COLUMN dish_id SET DEFAULT nextval('public.dishes_dish_id_seq'::regclass);


--
-- Name: dishes_list dishes_list_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes_list ALTER COLUMN dishes_list_id SET DEFAULT nextval('public.dishes_list_dishes_list_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- Name: dishes_list dishes_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes_list
    ADD CONSTRAINT dishes_list_pkey PRIMARY KEY (dishes_list_id);


--
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (dish_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: tables tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_pkey PRIMARY KEY (table_number);


--
-- Name: waiters unique_passport; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiters
    ADD CONSTRAINT unique_passport UNIQUE (passport_series, passport_number);


--
-- Name: clients unique_phone_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT unique_phone_number UNIQUE (phone_number);


--
-- Name: waiters_orders waiters_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiters_orders
    ADD CONSTRAINT waiters_orders_pkey PRIMARY KEY (waiter_id, order_id);


--
-- Name: waiters waiters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiters
    ADD CONSTRAINT waiters_pkey PRIMARY KEY (waiter_id);


--
-- Name: clients_last_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clients_last_name_idx ON public.clients USING btree (last_name);


--
-- Name: orders_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX orders_status_idx ON public.orders USING btree (status);


--
-- Name: INDEX orders_status_idx; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.orders_status_idx IS 'индекс по статусу заказа. Думаю, потребуется
при сортировке и анализе заказов, при выполнении активных заказов';


--
-- Name: waiters_waiter_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX waiters_waiter_status_idx ON public.waiters USING btree (waiter_status);


--
-- Name: INDEX waiters_waiter_status_idx; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.waiters_waiter_status_idx IS 'индекс по рабочему статусу официантов.
Возможно будет удобно для анализа персонала';


--
-- Name: dishes_list fk_dishes_list_dishes_list; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes_list
    ADD CONSTRAINT fk_dishes_list_dishes_list FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: dishes_list fk_dishes_list_to_dishes; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dishes_list
    ADD CONSTRAINT fk_dishes_list_to_dishes FOREIGN KEY (dish_id) REFERENCES public.dishes(dish_id);


--
-- Name: orders fk_orders_to_clients; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_to_clients FOREIGN KEY (client_id) REFERENCES public.clients(client_id);


--
-- Name: orders fk_orders_to_tables; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_to_tables FOREIGN KEY (table_number) REFERENCES public.tables(table_number);


--
-- Name: waiters_orders fk_waiters_orders_orders; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiters_orders
    ADD CONSTRAINT fk_waiters_orders_orders FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: waiters_orders fk_waiters_orders_waiters; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waiters_orders
    ADD CONSTRAINT fk_waiters_orders_waiters FOREIGN KEY (waiter_id) REFERENCES public.waiters(waiter_id);


--
-- PostgreSQL database dump complete
--

