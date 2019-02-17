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

--
-- Name: alina_db; Type: DATABASE; Schema: -; Owner: -
--

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
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.clients VALUES ('1a0634cd-1309-4c15-91a3-25aab8abb7c3', 'Николай', 'Сергеенко', '1987-12-21', 'sergeenko87@mail.ru', '79118437654', '5');
INSERT INTO public.clients VALUES ('56aa9d32-8781-44eb-b343-fbed89421f3d', 'Лидия', 'Иванова', '1991-10-11', 'ligiya_ivanova@gmail.ru', NULL, '5');
INSERT INTO public.clients VALUES ('53e6a716-c026-461a-a26e-0088334645af', 'Михаил', 'Сидоров', '1984-07-11', NULL, NULL, '5');
INSERT INTO public.clients VALUES ('50d2a7a4-99d4-4f27-b1c8-7672032c5ff9', 'Ирина', 'Андреева', NULL, NULL, '79658322378', '5');
INSERT INTO public.clients VALUES ('70ff302a-481e-4542-b3ca-e2ba9c7764bd', 'Игорь', 'Петров', NULL, NULL, '79218437654', '5');


--
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dishes VALUES (33, 'Овощное рагу', '229,00');
INSERT INTO public.dishes VALUES (34, 'Медальоны с печеным картофелем', '450,00');
INSERT INTO public.dishes VALUES (35, 'Грибной суп-пюре', '200,00');
INSERT INTO public.dishes VALUES (36, 'Куриные котлеты на пару с рисом', '322,00');
INSERT INTO public.dishes VALUES (37, 'Борщ', '315,00');
INSERT INTO public.dishes VALUES (38, 'Лосось гриль с овощами', '517,00');
INSERT INTO public.dishes VALUES (39, 'Щучьи котлетки с картофельным пюре', '390,00');
INSERT INTO public.dishes VALUES (40, 'Куриная грудка гриль с рисом', '346,00');
INSERT INTO public.dishes VALUES (41, 'Салат цезарь с курицей', '270,00');
INSERT INTO public.dishes VALUES (42, 'Салат цезарь с креветкой', '350,00');
INSERT INTO public.dishes VALUES (43, 'Салат греческий', '200,00');
INSERT INTO public.dishes VALUES (44, 'Чай зеленый в чайничке', '200,00');
INSERT INTO public.dishes VALUES (45, 'Чай черный в чайничке', '200,00');


--
-- Data for Name: tables; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tables VALUES (1, 2);
INSERT INTO public.tables VALUES (2, 4);
INSERT INTO public.tables VALUES (3, 2);
INSERT INTO public.tables VALUES (4, 4);
INSERT INTO public.tables VALUES (5, 6);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES (1, NULL, '50d2a7a4-99d4-4f27-b1c8-7672032c5ff9', '2018-12-11 00:00:00', '2018-12-11 00:00:00', '22,00', '44,00', 'cash', 'created', true, NULL);
INSERT INTO public.orders VALUES (6, 2, '53e6a716-c026-461a-a26e-0088334645af', '2019-01-28 01:42:29.809853', '2019-01-28 02:28:08.914399', '1399,00', '150,00', 'credit_card', 'completed', false, NULL);
INSERT INTO public.orders VALUES (8, 4, '53e6a716-c026-461a-a26e-0088334645af', '2019-01-30 00:07:12.922958', '2019-01-30 00:21:28.612682', '1192,40', '119,24', 'credit_card', 'created', true, NULL);
INSERT INTO public.orders VALUES (7, 2, NULL, '2019-01-28 01:51:59.121103', NULL, NULL, '0,00', 'cash', 'created', false, NULL);
INSERT INTO public.orders VALUES (9, 4, '53e6a716-c026-461a-a26e-0088334645af', '2019-02-04 01:15:17.368361', '2019-02-04 01:42:43.323872', '1192,40', '119,24', 'credit_card', 'created', true, '1132,78');


--
-- Data for Name: dishes_list; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dishes_list VALUES (6, 33, 3, '687,00', 1);
INSERT INTO public.dishes_list VALUES (13, 33, 1, '229,00', 6);
INSERT INTO public.dishes_list VALUES (14, 41, 1, '270,00', 6);
INSERT INTO public.dishes_list VALUES (15, 34, 2, '900,00', 6);
INSERT INTO public.dishes_list VALUES (16, 37, 1, '315,00', 8);
INSERT INTO public.dishes_list VALUES (17, 33, 1, '229,00', 8);
INSERT INTO public.dishes_list VALUES (18, 41, 2, '540,00', 8);
INSERT INTO public.dishes_list VALUES (19, 37, 1, '315,00', 9);
INSERT INTO public.dishes_list VALUES (20, 33, 1, '229,00', 9);
INSERT INTO public.dishes_list VALUES (21, 41, 2, '540,00', 9);


--
-- Data for Name: waiters; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.waiters VALUES ('02c1b2db-89f6-469e-a62a-f4ffa2c5263c', 'Олег', 'Рудников', '2018-06-23', '6534', '632876', 'working', NULL);
INSERT INTO public.waiters VALUES ('bb2bd2f0-0188-44f3-bec5-c57c79740b66', 'Анна', 'Смирнова', '2016-03-18', '4563', '456875', 'working', NULL);
INSERT INTO public.waiters VALUES ('98ed2dac-b06d-4d89-a261-f80bb497a19e', 'Светлана', 'Абрамова', '2016-05-12', '6530', '432121', 'working', NULL);
INSERT INTO public.waiters VALUES ('5fcc1a8e-bd8c-4ed7-8879-78b9da73b825', 'Виктор', 'Самойлов', '2017-12-08', '8739', '378097', 'working', NULL);
INSERT INTO public.waiters VALUES ('3b3a064d-7dc4-4f0a-8ea9-0458901728ef', 'Александр', 'Борисов', '2016-11-23', '3280', '457942', 'working', NULL);
INSERT INTO public.waiters VALUES ('4fc611f4-b9f2-481b-9331-76c461e777ff', 'Игорь', 'Лавров', '2017-12-08', '3782', '649238', 'fired', '2018-06-17');
INSERT INTO public.waiters VALUES ('3e01bdcf-4986-4b7a-8eba-a52f4db73b4c', 'Лилия', 'Кузькина', '2015-01-20', '6423', '674567', 'fired', '2018-09-25');
INSERT INTO public.waiters VALUES ('31b76a5f-72c3-4793-b06a-ac70d5ae7d9c', 'Инна', 'Никитина', '2017-02-09', '4782', '578932', 'maternity leave', '2018-12-25');
INSERT INTO public.waiters VALUES ('684736df-0196-453e-815e-89dce1d77921', 'Светлана', 'Курочкина', '2015-01-20', '7632', '876209', 'quit', '2016-11-22');


--
-- Data for Name: waiters_orders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: dishes_dish_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dishes_dish_id_seq', 45, true);


--
-- Name: dishes_list_dishes_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dishes_list_dishes_list_id_seq', 21, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 9, true);


--
-- Name: waiters_orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.waiters_orders_order_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

