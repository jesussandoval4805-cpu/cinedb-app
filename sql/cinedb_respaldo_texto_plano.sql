--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_auditar_eliminacion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_auditar_eliminacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO pelicula_auditoria (id_pelicula_eliminada, titulo_eliminado, accion)
  VALUES (OLD.id_pelicula, OLD.titulo, 'DELETE');
  RETURN OLD;
END;
$$;


--
-- Name: fn_validar_calificacion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_validar_calificacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.calificacion IS NOT NULL AND (NEW.calificacion < 0 OR NEW.calificacion > 10) THEN
    RAISE EXCEPTION 'La calificacion debe estar entre 0 y 10 (valor recibido: %)', NEW.calificacion;
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actor (
    id_actor integer NOT NULL,
    nombre_actor character varying(150) NOT NULL
);


--
-- Name: actor_id_actor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actor_id_actor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actor_id_actor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actor_id_actor_seq OWNED BY public.actor.id_actor;


--
-- Name: director; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.director (
    id_director integer NOT NULL,
    nombre_director character varying(150) NOT NULL
);


--
-- Name: director_id_director_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.director_id_director_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: director_id_director_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.director_id_director_seq OWNED BY public.director.id_director;


--
-- Name: genero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.genero (
    id_genero integer NOT NULL,
    nombre_genero character varying(50) NOT NULL
);


--
-- Name: genero_id_genero_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.genero_id_genero_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genero_id_genero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.genero_id_genero_seq OWNED BY public.genero.id_genero;


--
-- Name: pelicula; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pelicula (
    id_pelicula integer NOT NULL,
    rank_original integer,
    titulo character varying(200) NOT NULL,
    descripcion text,
    anio integer NOT NULL,
    duracion_minutos integer,
    calificacion numeric(3,1),
    votos integer,
    recaudacion_millones numeric(8,2),
    metascore integer,
    id_director integer
);


--
-- Name: pelicula_actor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pelicula_actor (
    id_pelicula integer NOT NULL,
    id_actor integer NOT NULL,
    orden_reparto integer
);


--
-- Name: pelicula_auditoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pelicula_auditoria (
    id_auditoria integer NOT NULL,
    id_pelicula_eliminada integer,
    titulo_eliminado character varying(200),
    fecha_eliminacion timestamp without time zone DEFAULT now(),
    accion character varying(20)
);


--
-- Name: pelicula_auditoria_id_auditoria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pelicula_auditoria_id_auditoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pelicula_auditoria_id_auditoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pelicula_auditoria_id_auditoria_seq OWNED BY public.pelicula_auditoria.id_auditoria;


--
-- Name: pelicula_genero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pelicula_genero (
    id_pelicula integer NOT NULL,
    id_genero integer NOT NULL
);


--
-- Name: pelicula_id_pelicula_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pelicula_id_pelicula_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pelicula_id_pelicula_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pelicula_id_pelicula_seq OWNED BY public.pelicula.id_pelicula;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    nombre_usuario character varying(50) NOT NULL,
    contrasena_hash character varying(255) NOT NULL,
    rol character varying(20) NOT NULL,
    fecha_creacion date DEFAULT CURRENT_DATE,
    CONSTRAINT usuario_rol_check CHECK (((rol)::text = ANY ((ARRAY['administrador'::character varying, 'analista'::character varying])::text[])))
);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- Name: vista_catalogo_completo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vista_catalogo_completo AS
 SELECT p.id_pelicula,
    p.titulo,
    p.anio,
    p.calificacion,
    p.recaudacion_millones,
    d.nombre_director,
    string_agg(DISTINCT (g.nombre_genero)::text, ', '::text ORDER BY (g.nombre_genero)::text) AS generos
   FROM (((public.pelicula p
     LEFT JOIN public.director d ON ((d.id_director = p.id_director)))
     LEFT JOIN public.pelicula_genero pg ON ((pg.id_pelicula = p.id_pelicula)))
     LEFT JOIN public.genero g ON ((g.id_genero = pg.id_genero)))
  GROUP BY p.id_pelicula, p.titulo, p.anio, p.calificacion, p.recaudacion_millones, d.nombre_director;


--
-- Name: vista_recaudacion_por_genero; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vista_recaudacion_por_genero AS
 SELECT g.nombre_genero,
    round(sum(p.recaudacion_millones), 2) AS recaudacion_total_millones,
    round(avg(p.calificacion), 2) AS calificacion_promedio
   FROM ((public.genero g
     JOIN public.pelicula_genero pg ON ((pg.id_genero = g.id_genero)))
     JOIN public.pelicula p ON ((p.id_pelicula = pg.id_pelicula)))
  GROUP BY g.nombre_genero
  ORDER BY (round(sum(p.recaudacion_millones), 2)) DESC;


--
-- Name: vista_top_peliculas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vista_top_peliculas AS
 SELECT p.titulo,
    p.anio,
    p.calificacion,
    d.nombre_director
   FROM (public.pelicula p
     JOIN public.director d ON ((d.id_director = p.id_director)))
  ORDER BY p.calificacion DESC NULLS LAST, p.votos DESC NULLS LAST, p.id_pelicula
 LIMIT 10;


--
-- Name: actor id_actor; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor ALTER COLUMN id_actor SET DEFAULT nextval('public.actor_id_actor_seq'::regclass);


--
-- Name: director id_director; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.director ALTER COLUMN id_director SET DEFAULT nextval('public.director_id_director_seq'::regclass);


--
-- Name: genero id_genero; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genero ALTER COLUMN id_genero SET DEFAULT nextval('public.genero_id_genero_seq'::regclass);


--
-- Name: pelicula id_pelicula; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula ALTER COLUMN id_pelicula SET DEFAULT nextval('public.pelicula_id_pelicula_seq'::regclass);


--
-- Name: pelicula_auditoria id_auditoria; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_auditoria ALTER COLUMN id_auditoria SET DEFAULT nextval('public.pelicula_auditoria_id_auditoria_seq'::regclass);


--
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- Data for Name: actor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actor (id_actor, nombre_actor) FROM stdin;
1	Chris Pratt
2	Vin Diesel
3	Bradley Cooper
4	Zoe Saldana
5	Noomi Rapace
6	Logan Marshall-Green
7	Michael Fassbender
8	Charlize Theron
9	James McAvoy
10	Anya Taylor-Joy
11	Haley Lu Richardson
12	Jessica Sula
13	Matthew McConaughey
14	Reese Witherspoon
15	Seth MacFarlane
16	Scarlett Johansson
17	Will Smith
18	Jared Leto
19	Margot Robbie
20	Viola Davis
21	Matt Damon
22	Tian Jing
23	Willem Dafoe
24	Andy Lau
25	Ryan Gosling
26	Emma Stone
27	Rosemarie DeWitt
28	J.K. Simmons
29	Essie Davis
30	Andrea Riseborough
31	Julian Barratt
32	Kenneth Branagh
33	Charlie Hunnam
34	Robert Pattinson
35	Sienna Miller
36	Tom Holland
37	Jennifer Lawrence
38	Michael Sheen
39	Laurence Fishburne
40	Eddie Redmayne
41	Katherine Waterston
42	Alison Sudol
43	Dan Fogler
44	Taraji P. Henson
45	Octavia Spencer
46	Janelle Monáe
47	Kevin Costner
48	Felicity Jones
49	Diego Luna
50	Alan Tudyk
51	Donnie Yen
52	Auli'i Cravalho
53	Dwayne Johnson
54	Rachel House
55	Temuera Morrison
56	Anne Hathaway
57	Jason Sudeikis
58	Austin Stowell
59	Tim Blake Nelson
60	Louis C.K.
61	Eric Stonestreet
62	Kevin Hart
63	Lake Bell
64	Andrew Garfield
65	Sam Worthington
66	Luke Bracey
67	Teresa Palmer
68	Tommy Lee Jones
69	Alicia Vikander
70	Vincent Cassel
71	Dev Patel
72	Nicole Kidman
73	Rooney Mara
74	Sunny Pawar
75	Amy Adams
76	Jeremy Renner
77	Forest Whitaker
78	Michael Stuhlbarg
79	Edgar Ramírez
80	Bryce Dallas Howard
81	Corey Stoll
82	Casey Affleck
83	Michelle Williams
84	Kyle Chandler
85	Lucas Hedges
86	Emma Booth
87	Ashleigh Cummings
88	Stephen Curry
89	Susie Porter
90	Anna Kendrick
91	Justin Timberlake
92	Zooey Deschanel
93	Christopher Mintz-Plasse
94	Liam Hemsworth
95	Jeff Goldblum
96	Bill Pullman
97	Maika Monroe
98	Fiona Gordon
99	Dominique Abel
100	Emmanuelle Riva
101	Pierre Richard
102	Prabhas
103	Rana Daggubati
104	Anushka Shetty
105	Tamannaah Bhatia
106	Jocelin Donahue
107	Jesse Bradford
108	Jesse Borrego
109	Lori Petty
110	Mila Kunis
111	Kathryn Hahn
112	Kristen Bell
113	Christina Applegate
114	Marion Cotillard
115	Jeremy Irons
116	Brendan Gleeson
117	Zoey Deutch
118	James Franco
119	Tangie Ambrose
120	Cedric the Entertainer
121	Jake Gyllenhaal
122	Michael Shannon
123	Aaron Taylor-Johnson
124	Nicholas Hoult
125	Ryan Reynolds
126	Morena Baccarin
127	T.J. Miller
128	Ed Skrein
129	Milla Jovovich
130	Iain Glen
131	Ali Larter
132	Shawn Roberts
133	Chris Evans
134	Robert Downey Jr.
135	Sebastian Stan
136	Jessica Chastain
137	Mackenzie Foy
138	Benedict Cumberbatch
139	Chiwetel Ejiofor
140	Rachel McAdams
141	Benedict Wong
142	Denzel Washington
143	Ethan Hawke
144	Vincent D'Onofrio
145	John Francis Daley
146	Austin Pendleton
147	Colleen Camp
148	Neil Flynn
149	Seth Rogen
150	Kristen Wiig
151	Jonah Hill
152	Alistair Abell
153	Mahershala Ali
154	Shariff Earp
155	Duan Sanderson
156	Alex R. Hibbert
157	Brittany Blanton
158	Ayse Howard
159	Roman Jossart
160	Nadia White
161	Michael Keaton
162	Nick Offerman
163	John Carroll Lynch
164	Linda Cardellini
165	Gabriel Chavarria
166	Demián Bichir
167	Theo Rossi
168	Tony Revolori
169	Johnny Depp
170	Penélope Cruz
171	Ian McShane
172	Geoffrey Rush
173	Mark Strong
174	Gugu Mbatha-Raw
175	Hermione Corfield
176	Addison Timlin
177	Joely Richardson
178	Jeremy Irvine
179	Chris Pine
180	Zachary Quinto
181	Karl Urban
182	Javier Bardem
183	Adèle Exarchopoulos
184	Jared Harris
185	Daisy Ridley
186	John Boyega
187	Oscar Isaac
188	Domhnall Gleeson
189	Kate Beckinsale
190	Theo James
191	Tobias Menzies
192	Lara Pulver
193	Jennifer Aniston
194	Kate Hudson
195	Julia Roberts
196	Keanu Reeves
197	Michael Nyqvist
198	Alfie Allen
199	Christian Bale
200	Heath Ledger
201	Aaron Eckhart
202	Michael Caine
203	Adam Driver
204	Liam Neeson
205	Tadanobu Asano
206	Stephen Lang
207	Jane Levy
208	Dylan Minnette
209	Daniel Zovatto
210	Emilia Clarke
211	Sam Claflin
212	Janet McTeer
213	Charles Dance
214	Gemma Arterton
215	Bill Nighy
216	Jack Huston
217	Tom Hanks
218	Laura Linney
219	Valerie Mahaffey
220	Ben Affleck
221	Henry Cavill
222	Jesse Eisenberg
223	Brian Cox
224	Emile Hirsch
225	Ophelia Lovibond
226	Michael McElhatton
227	Emily Blunt
228	Haley Bennett
229	Rebecca Ferguson
230	Justin Theroux
231	Dakota Johnson
232	Jamie Dornan
233	Jennifer Ehle
234	Eloise Mumford
235	Hugh Jackman
236	Colin Firth
237	Taron Egerton
238	Samuel L. Jackson
239	Mark Wahlberg
240	Michelle Monaghan
241	John Goodman
242	Tom Hardy
243	Zoë Kravitz
244	Bryan Cranston
245	Jennifer Garner
246	Beverly D'Angelo
247	Jason O'Mara
248	Kurt Russell
249	Douglas M. Griffin
250	James DuMont
251	Charlotte Le Bon
252	Daniel Giménez Cacho
253	Brad Pitt
254	Vincent Ebrahim
255	Lewis MacDougall
256	Sigourney Weaver
257	Toby Kebbell
258	Edward Norton
259	Kate Winslet
260	Michael Peña
261	Ginnifer Goodwin
262	Jason Bateman
263	Idris Elba
264	Jenny Slate
265	Orlando Bloom
266	Keira Knightley
267	Diane Kruger
268	Eli Roth
269	Mélanie Laurent
270	Jack Davenport
271	Melissa McCarthy
272	Kate McKinnon
273	Leslie Jones
274	Leonardo DiCaprio
275	Joseph Gordon-Levitt
276	Ellen Page
277	Ken Watanabe
278	Viggo Mortensen
279	George MacKay
280	Samantha Isler
281	Annalise Basso
282	Rosamund Pike
283	Neil Patrick Harris
284	Tyler Perry
285	Paul Walker
286	Jason Statham
287	Ty Simpkins
288	Judy Greer
289	Elle Fanning
290	Chris Messina
291	Michelle Rodriguez
292	Jennifer Jason Leigh
293	Walton Goggins
294	Jon Bernthal
295	Melissa Leo
296	Travis Fimmel
297	Paula Patton
298	Ben Foster
299	Dominic Cooper
300	Miles Teller
301	Steve Lantz
302	Gregg Weiner
303	Mark Ruffalo
304	Chris Hemsworth
305	Russell Crowe
306	Angourie Rice
307	Matt Bomer
308	Ryûnosuke Kamiki
309	Mone Kamishiraishi
310	Ryô Narita
311	Aoi Yuki
312	Aaron Poole
313	Kenneth Welsh
314	Daniel Fathers
315	Kathleen Munroe
316	Kristen Stewart
317	Lars Eidinger
318	Sigrid Bouaziz
319	Anders Danielsen Lie
320	Jack Nicholson
321	Emily Browning
322	Paul Anderson
323	Anthony Hopkins
324	Natalie Portman
325	Tom Hiddleston
326	Kate Mara
327	Mario Casas
328	Ana Wagener
329	José Coronado
330	Bárbara Lennie
331	Armie Hammer
332	Elizabeth Debicki
333	Jeff Bridges
334	Gil Birmingham
335	Robert De Niro
336	Leslie Mann
337	Danny DeVito
338	Edie Falco
339	Alexander Skarsgård
340	Rory J. Saper
341	Christian Stevens
342	Christoph Waltz
343	Eve Lindley
344	Richard Kind
345	Mark Consuelos
346	Katherine Reis
347	Sonoya Mizuno
348	John Gallagher Jr.
349	Tony Goldwyn
350	Adria Arjona
351	John C. McGinley
352	Michael Kenneth Williams
353	Jason Momoa
354	Jim Carrey
355	Gerard Butler
356	Lena Headey
357	David Wenham
358	Dominic West
359	Daniel Radcliffe
360	Emma Watson
361	Rupert Grint
362	Michael Gambon
363	Olivia Munn
364	Christina Hendricks
365	Karl Glusman
366	Aamir Khan
367	Sakshi Tanwar
368	Fatima Sana Shaikh
369	Sanya Malhotra
370	Mary Elizabeth Winstead
371	Ellen DeGeneres
372	Albert Brooks
373	Ed O'Neill
374	Kaitlin Olson
375	Eva Green
376	Asa Butterfield
377	Judi Dench
378	Shailene Woodley
379	Jai Courtney
380	Zac Efron
381	Adam Devine
382	Aubrey Plaza
383	Scott Adkins
384	Teodora Duhovnikova
385	Alon Aboutboul
386	Julian Vergov
387	Gary Oldman
388	Neel Sethi
389	Bill Murray
390	Ben Kingsley
391	Nicola Peltz
392	Jack Reynor
393	Stanley Tucci
394	Emma Roberts
395	Dave Franco
396	Emily Meade
397	Miles Heizer
398	Meryl Streep
399	Pierce Brosnan
400	Amanda Seyfried
401	Stellan Skarsgård
402	Will Poulter
403	Stephen Henderson
404	Jovan Adepo
405	Blake Lively
406	Óscar Jaenada
407	Angelo Josue Lozano Corzo
408	Brett Cullen
409	Melissa Benoist
410	Paul Reiser
411	Eva Mendes
412	Craig Van Hook
413	Josh Brolin
414	Woody Harrelson
415	Carey Mulligan
416	Joel Edgerton
417	Tobey Maguire
418	Emily Mortimer
419	Dakota Fanning
420	Guy Pearce
421	Kit Harington
422	Carice van Houten
423	Simon Pegg
424	Leonard Nimoy
425	Zachary Gordon
426	Robert Capron
427	Rachael Harris
428	Steve Zahn
429	Steve Carell
430	Brie Larson
431	Jacob Tremblay
432	Sean Bridgers
433	Wendy Crewson
434	Jamie Foxx
435	Kerry Washington
436	Min-hee Kim
437	Jung-woo Ha
438	Jin-woong Jo
439	So-ri Moon
440	Hailee Steinfeld
441	Blake Jenner
442	Kyra Sedgwick
443	Jackie Earle Haley
444	Patrick Wilson
445	Carla Gugino
446	Malin Akerman
447	Michael Cera
448	Bill Hader
449	Irrfan Khan
450	Mark Rylance
451	Ruby Barnhill
452	Penelope Wilton
453	Jemaine Clement
454	Josh Hutcherson
455	Morgan Saylor
456	Brian Marc
457	Justin Bartha
458	Adrian Martinez
459	Benicio Del Toro
460	Chris Isaak
461	Kiefer Sutherland
462	C.H. Evans
463	Sandra Kinder
464	Reiko Aylesworth
465	Steven Pasquale
466	Shareeka Epps
467	John Ortiz
468	Rinko Kikuchi
469	Charlie Day
470	Julianne Moore
471	Kieran Culkin
472	Alison Pill
473	Nick Frost
474	Martin Freeman
475	Annabelle Wallis
476	Tom Cullen
477	Clint Dyer
478	Sharlto Copley
479	Cillian Murphy
480	Patrick Stewart
481	Ian McKellen
482	Tom Cruise
483	Cobie Smulders
484	Aldis Hodge
485	Robert Knepper
486	Daniel Craig
487	Jeffrey Wright
488	Billy Burke
489	Sarah Clarke
490	Helen Mirren
491	Daniel Brühl
492	Katie Holmes
493	John Krasinski
494	Pablo Schreiber
495	James Badge Dale
496	David Denman
497	Léa Seydoux
498	Ralph Fiennes
499	Rene Russo
500	Bill Paxton
501	Riz Ahmed
502	Art Parkinson
503	Graham Skipper
504	Chase Williamson
505	Brea Grant
506	Barbara Crampton
507	Joaquin Phoenix
508	Idina Menzel
509	Jonathan Groff
510	Josh Gad
511	George Clooney
512	Britt Robertson
513	Hugh Laurie
514	Raffey Cassidy
515	Keri Russell
516	Andy Serkis
517	Kodi Smit-McPhee
518	Ben Stiller
519	Jack Black
520	Jeff Kahn
521	Vera Farmiga
522	Madison Wolfe
523	Frances O'Connor
524	Paul Rudd
525	Michael Douglas
526	Evangeline Lilly
527	Renée Zellweger
528	Gemma Jones
529	Jim Broadbent
530	Sally Phillips
531	Ralph Ineson
532	Kate Dickie
533	Julian Richings
534	Lily James
535	Cate Blanchett
536	Richard Madden
537	Helena Bonham Carter
538	Tom Hughes
539	Oona Chaplin
540	Barry Ward
541	Taraneh Alidoosti
542	Shahab Hosseini
543	Babak Karimi
544	Farid Sajjadi Hosseini
545	Aomi Muyock
546	Klara Kristin
547	Juan Saavedra
548	Joe Alwyn
549	Garrett Hedlund
550	Arturo Castro
551	Mason Lee
552	Mia Wasikowska
553	Amy Schumer
554	Colin Quinn
555	Rachel Weisz
556	Florence Clery
557	Erika Linder
558	Natalie Krill
559	Sebastian Pigott
560	Mayko Nguyen
561	Liev Schreiber
562	Rose Leslie
563	Michael Yare
564	Nick Nolte
565	Jennifer Morrison
566	Hugo Weaving
567	Hayley Atwell
568	Callan McAuliffe
569	Lorraine Nicholson
570	Daniel Eric Gold
571	Clifton Collins Jr.
572	Vince Vaughn
573	Catherine Keener
574	Marcia Gay Harden
575	Matthew Goode
576	Allen Leech
577	Danielle Nicolet
578	Amy Ryan
579	Dane DeHaan
580	Jason Isaacs
581	Mia Goth
582	Ivo Nandi
583	Gwyneth Paltrow
584	Terrence Howard
585	Jeff Daniels
586	Naomi Watts
587	Kevin Bacon
588	Garance Marillier
589	Ella Rumpf
590	Rabah Nait Oufella
591	Laurent Lucas
592	Golshifteh Farahani
593	Nellie
594	Rizwan Manji
595	Maya Rudolph
596	Rose Byrne
597	Terry Crews
598	Glenn Close
599	Dominique Tipper
600	Paddy Considine
601	Alexandra Daddario
602	Colton Haynes
603	Vanessa Hudgens
604	Selena Gomez
605	Ashley Benson
606	Rachel Korine
607	Shia LaBeouf
608	Megan Fox
609	Josh Duhamel
610	Tyrese Gibson
611	Elizabeth Olsen
612	Brenton Thwaites
613	Nikolaj Coster-Waldau
614	Chadwick Boseman
615	Robert Redford
616	Lucas Till
617	Thomas Lennon
618	Barry Pepper
619	Mark Huberman
620	Susan Loughnane
621	Steve Oram
622	Catherine Walker
623	Nicolas Cage
624	Chloë Grace Moretz
625	Garrett M. Brown
626	Tim Roth
627	Danila Kozlovsky
628	Owen Wilson
629	Bonnie Hunt
630	Paul Newman
631	Larry the Cable Guy
632	Keir Gilchrist
633	Olivia Luccardi
634	Lili Sepe
635	Christopher Plummer
636	Ed Helms
637	Sasha Lane
638	Riley Keough
639	McCaul Lombardi
640	Colin Farrell
641	Jessica Barden
642	Olivia Colman
643	Adrien Brody
644	Topher Grace
645	Alice Braga
646	Angelina Jolie
647	Lesley Manville
648	Michael Chiklis
649	Kerry Bishé
650	Peter Stormare
651	Ivana Baquero
652	Ariadna Gil
653	Sergi López
654	Maribel Verdú
655	Jessica Biel
656	Vincent Kartheiser
657	Gerardo Taracena
658	Raoul Max Trujillo
659	Dalia Hernández
660	Rudy Youngblood
661	Logan Lerman
662	Ezra Miller
663	Peter Sarsgaard
664	Greta Gerwig
665	Billy Crudup
666	Mel Raido
667	Duncan Joiner
668	F. Murray Abraham
669	Mathieu Amalric
670	Saoirse Ronan
671	Max Irons
672	Jake Abel
673	Amy Poehler
674	Lewis Black
675	Mindy Kaling
676	Luke Wilson
677	Eddie Izzard
678	Arnold Schwarzenegger
679	Jason Clarke
680	Kevin McKidd
681	Steve Coogan
682	Brandon T. Jackson
683	Clive Owen
684	Annette Bening
685	Jude Law
686	François Cluzet
687	Omar Sy
688	Anne Le Ny
689	Audrey Fleurot
690	Diane Lane
691	Alec Baldwin
692	Arnaud Viard
693	Linda Gegusch
694	Christos Stergioglou
695	Michele Valley
696	Angeliki Papoulia
697	Hristos Passalis
698	O'Shea Jackson Jr.
699	Corey Hawkins
700	Jason Mitchell
701	Neil Brown Jr.
702	Paul Giamatti
703	Ron Livingston
704	Lili Taylor
705	Zach Galifianakis
706	Brooklyn Decker
707	Rihanna
708	Freida Pinto
709	Karin Konoval
710	Gabriel Bateman
711	Maria Bello
712	Richard Gere
713	Lior Ashkenazi
714	Charlotte Gainsbourg
715	Winona Ryder
716	Tyler James Williams
717	Tessa Thompson
718	Kyle Gallner
719	Teyonah Parris
720	Stacy Martin
721	Will Arnett
722	Lorenza Izzo
723	Ana de Armas
724	Aaron Burns
725	Halle Berry
726	Hugh Grant
727	Danny Huston
728	Sarah Hyland
729	Steven Krueger
730	Justin Chon
731	Clara Mamet
732	Naomie Harris
733	Richard Armitage
734	Channing Tatum
735	Ice Cube
736	Ferdia Walsh-Peelo
737	Aidan Gillen
738	Maria Doyle Kennedy
739	Carly Rae Jepsen
740	Maddie Ziegler
741	Morgan Freeman
742	Olga Kurylenko
743	Anthony Edwards
744	Tyler Hoechlin
745	Ryan Guzman
746	Don Cheadle
747	Common
748	Zoë Bell
749	Rosario Dawson
750	Vanessa Ferlito
751	Amber Heard
752	Ben Whishaw
753	John Hurt
754	Joseph Fiennes
755	Abbie Cornish
756	Jena Malone
757	Isla Fisher
758	Jon Hamm
759	Gal Gadot
760	Sean Bean
761	Ross Kimball
762	Romain Duris
763	Jalil Lespert
764	Camille Cottin
765	Yoo Gong
766	Soo-an Kim
767	Yu-mi Jung
768	Dong-seok Ma
769	Brittany Snow
770	Rebel Wilson
771	Anna Camp
772	Loïs van Wijk
773	Benjamin Walker
774	Maggie Grace
775	Ray Romano
776	Denis Leary
777	John Leguizamo
778	Chris Wedge
779	Adrian Grenier
780	Daniel Day-Lewis
781	Paul Dano
782	Ciarán Hinds
783	Martin Stringer
784	Marton Csokas
785	David Harbour
786	Taylor Kitsch
787	Kristen Connolly
788	Anna Hutchison
789	Fran Kranz
790	Anna Faris
791	Colin Hanks
792	Kat Dennings
793	Jay Baruchel
794	Alice Eve
795	Mike Vogel
796	Emory Cohen
797	Lucas Black
798	Zachery Ty Bryan
799	Shad Moss
800	Damien Marzette
801	Alison Brie
802	Quinton Aaron
803	Sandra Bullock
804	Tim McGraw
805	Jae Head
806	Salim Kechiouche
807	Aurélien Recoing
808	Noah Wiseman
809	Daniel Henshall
810	Hayley McElhinney
811	Jamie Bell
812	Tilda Swinton
813	Ed Harris
814	Matthew Zuk
815	Gabriela Lopez
816	Bailey Anne Borders
817	Connor Paolo
818	Nick Damici
819	Laura Abramsen
820	A.C. Peterson
821	Olivia DeJonge
822	Ed Oxenbould
823	Deanna Dunagan
824	Peter McRobbie
825	Jordana Brewster
826	Jenna Dewan Tatum
827	Damaine Radcliff
828	De'Shawn Washington
829	Jessie Ok Gray
830	Cary Joji Fukunaga
831	Tom Wilkinson
832	Thandie Newton
833	Olivia Wilde
834	Elijah Wood
835	Ólafur Darri Ólafsson
836	Jessica Brown Findlay
837	Andrew Scott
838	Luke Treadaway
839	Bob the Cat
840	Ruta Gedmintas
841	Joanne Froggatt
842	Anton Yelchin
843	Imogen Poots
844	Alia Shawkat
845	Wei Tang
846	Leehom Wang
847	Andy Samberg
848	Katie Crown
849	Kelsey Grammer
850	Cole Konis
851	Sally Field
852	David Strathairn
853	Alexandra Maria Lara
854	Kate Bosworth
855	Thomas Jane
856	Annabeth Gish
857	Jacki Weaver
858	Alexi Pappas
859	Chase Offerle
860	Rachel Dratch
861	Andy Buckley
862	Ansel Elgort
863	Nat Wolff
864	Laura Dern
865	Adam Sandler
866	Drew Barrymore
867	Wendi McLendon-Covey
868	Kevin Nealon
869	Bruce Willis
870	Maggie Gyllenhaal
871	Oakes Fegley
872	Oona Laurence
873	Kirsten Dunst
874	Thomas Haden Church
875	Matthew Macfadyen
876	Ray Stevenson
877	Charlie Cox
878	Claire Danes
879	Adam Brody
880	Johnny Simmons
881	Kathy Bates
882	Kurt Fuller
883	Florence Pugh
884	Christopher Fairbank
885	Cosmo Jarvis
886	Naomi Ackie
887	Judy Davis
888	Ben Barnes
889	Clémence Poésy
890	Antoine Bertrand
891	Ashley Walters
892	Tom Prior
893	Sophie Perry
894	Lydia Wilson
895	Will Ferrell
896	John C. Reilly
897	Mary Steenburgen
898	Richard Jenkins
899	Andy Powers
900	Laura Allen
901	Christian Distefano
902	Abigail Breslin
903	Alden Ehrenreich
904	Saurabh Shukla
905	Anil Kapoor
906	Taylor Lautner
907	Peter Facinelli
908	William Fichtner
909	Jon Voight
910	Lia Marie Johnson
911	Gabriel Basso
912	Rhys Ifans
913	Rodrigo Santoro
914	Nazanin Boniadi
915	Jacob Latimore
916	Seychelle Gabriel
917	Dulé Hill
918	Storm Reid
919	Dylan O'Brien
920	Kaya Scodelario
921	Thomas Brodie-Sangster
922	Terence Stamp
923	Simon Helberg
924	Michael B. Jordan
925	Sylvester Stallone
926	Phylicia Rashad
927	Antonia Ribero
928	Jet Li
929	Antonio Banderas
930	Taika Waititi
931	Cori Gonzalez-Macuer
932	Jonny Brugh
933	Kate Siegel
934	Michael Trucco
935	Samantha Sloyan
936	Alan Alda
937	Elizabeth Banks
938	Ang Phula Sherpa
939	Thomas M. Wright
940	Martin Henderson
941	Kevin James
942	Peter Dinklage
943	Max von Sydow
944	Will Yun Lee
945	Tao Okamoto
946	Rila Fukushima
947	Lynn Collins
948	Samantha Morton
949	Keegan-Michael Key
950	Jordan Peele
951	Tiffany Haddish
952	Method Man
953	Sean Penn
954	Jasmine Trinca
955	Tim Pigott-Smith
956	Naomi Battrick
957	Ellie Kendrick
958	James Cosmo
959	Chris Rock
960	David Spade
961	Michiel Huisman
962	Harrison Ford
963	Kathy Baker
964	Liv Tyler
965	William Hurt
966	Jon Favreau
967	Sanjeev Bhaskar
968	Rob Riggle
969	Alex Pettyfer
970	Pierre Coffin
971	Natasha Henstridge
972	Lukas Hassel
973	Lin Shaye
974	Dominique Swain
975	Kelly Adams
976	Luing Andrews
977	Katy Barker
978	Jason Segel
979	Russell Brand
980	Julie Andrews
981	James Marsden
982	Liana Liberato
983	Emayatzy Corinealdi
984	Tammy Blanchard
985	Mandy Moore
986	Zachary Levi
987	Donna Murphy
988	Ron Perlman
989	Skyler Gisondo
990	Steele Stebbins
991	Famke Janssen
992	Leland Orser
993	Billy Crystal
994	Steve Buscemi
995	Isabelle Huppert
996	Laurent Lafitte
997	Anne Consigny
998	Charles Berling
999	Jessica Alba
1000	Michelle Yeoh
1001	Justin Long
1002	Michael Parks
1003	Haley Joel Osment
1004	Genesis Rodriguez
1005	Gretchen Mol
1006	Brenda Blethyn
1007	Lucy Walters
1008	Eric Bana
1009	Vicky Krieps
1010	Lauren Birkell
1011	Paul Borghese
1012	Chira Cassel
1013	Anthony Cirillo
1014	Sam Riley
1015	Bella Heathcote
1016	Sullivan Stapleton
1017	Hans Matheson
1018	Angela Bassett
1019	Julia Ormond
1020	Mickey Rourke
1021	Joan Allen
1022	Julia Stiles
1023	Srdjan 'Zika' Todorovic
1024	Sergej Trifunovic
1025	Jelena Gavrilovic
1026	Slobodan Bestic
1027	Frank Grillo
1028	Elizabeth Mitchell
1029	Mykelti Williamson
1030	Joseph Julian Soria
1031	Madhavan
1032	Mona Singh
1033	Sharman Joshi
1034	Mireille Enos
1035	Daniella Kertesz
1036	Marilyn Manson
1037	Mark Boone Junior
1038	Sam Quartin
1039	Niko Nicotera
1040	Eddie Marsan
1041	Scott Eastwood
1042	Ewan McGregor
1043	Oaklee Pendergast
1044	Alex Karpovsky
1045	Wyatt Russell
1046	Meredith Hagner
1047	Melanie Lynskey
1048	Teri Hatcher
1049	John Hodgman
1050	Jennifer Saunders
1051	John Doman
1052	Faith Wladyka
1053	Logan Paul
1054	Peyton List
1055	Calum Worthy
1056	Radha Mitchell
1057	Laurie Holden
1058	Deborah Kara Unger
1059	Olivia Thirlby
1060	Rachel Wood
1061	Sam Neill
1062	Julian Dennison
1063	Rima Te Wiata
1064	Ryan Potter
1065	Scott Adsit
1066	Jamie Chung
1067	Gabriella Wilde
1068	Portia Doubleday
1069	Chris Cooper
1070	Judah Lewis
1071	Dennis Quaid
1072	Cam Gigandet
1073	Antje Traue
1074	Timothy Olyphant
1075	Dianna Agron
1076	Mads Mikkelsen
1077	Thomas Bo Larsen
1078	Annika Wedderkopp
1079	Lasse Fogelstrøm
1080	Craig T. Nelson
1081	T.I.
1082	Christopher Fitzgerald
1083	Jonathan Roumie
1084	Rebecca Hall
1085	Lauren Cohan
1086	Rupert Evans
1087	James Russell
1088	Jim Norton
1089	Timothy Spall
1090	Sarah Snook
1091	Noah Taylor
1092	Madeleine West
1093	Odeya Rush
1094	Ryan Lee
1095	Daniel Olbrychski
1096	Sarah Gadon
1097	Isabella Rossellini
1098	David James
1099	Jason Cope
1100	Nathalie Boltt
1101	Derek Jeter
1102	Jason Schwartzman
1103	Rip Torn
1104	John Cusack
1105	Amanda Peet
1106	Alan Arkin
1107	Tom Costello
1108	Jo Hartley
1109	Ulrich Mühe
1110	Martina Gedeck
1111	Sebastian Koch
1112	Ulrich Tukur
1113	Dominic Monaghan
1114	Ksenia Solo
1115	Jennette McCurdy
1116	Da'Vone McDonald
1117	Nancy Kwan
1118	Annabelle Attanasio
1119	Alfred Molina
1120	Jack Madigan
1121	Frank Madigan
1122	Taylor Swift
1123	Anthony Mackie
1124	Aaron Paul
1125	Giuseppe Battiston
1126	Anna Foglietta
1127	Marco Giallini
1128	Edoardo Leo
1129	Danny McBride
1130	Jared Gilman
1131	Kara Hayward
1132	John Travolta
1133	Queen Latifah
1134	Nikki Blonsky
1135	Michelle Pfeiffer
1136	Julianne Hough
1137	David Lyons
1138	Brad Garrett
1139	Lou Romano
1140	Patton Oswalt
1141	Ian Holm
1142	Kelly McGillis
1143	Gregory Jones
1144	Jessica Lucas
1145	Lizzy Caplan
1146	Ray Winstone
1147	Jeremy McWilliams
1148	Lynsey Taylor Mackay
1149	Dougie McConnell
1150	Charlie Tahan
1151	Salli Richardson-Whitfield
1152	AJ Michalka
1153	Joel Courtney
1154	Leslie Bibb
1155	Colm Meaney
1156	Edward Asner
1157	Jordan Nagai
1158	John Ratzenberger
1159	Giancarlo Esposito
1160	Sarah Paulson
1161	Toni Collette
1162	Tracy Letts
1163	Sam Trammell
1164	Harvey Keitel
1165	Jane Fonda
1166	Sarah Polley
1167	Linh Dan Pham
1168	Billie Piper
1169	James Floyd
1170	Cush Jumbo
1171	Geoffrey Arend
1172	Stephen Merchant
1173	Orto Ignatiussen
1174	David Thewlis
1175	Rupert Friend
1176	Zac Mattoon O'Brien
1177	Rhona Mitra
1178	Danny Glover
1179	Ashlyn Sanchez
1180	Matthew Fox
1181	Joe Manganiello
1182	Adam Rodriguez
1183	Amanda Bynes
1184	Penn Badgley
1185	Dan Byrd
1186	Ken Stott
1187	Anika Noni Rose
1188	Joseph Mawle
1189	Brian Caspe
1190	Karel Hermánek Jr.
1191	Cameron Diaz
1192	Anton Adasinsky
1193	Aleksandr Armer
1194	Vilen Babichev
1195	Rostislav Bershauer
1196	Tina Fey
1197	Billy Magnussen
1198	Terry Chen
1199	Teresa Navarro
1200	Vanessa Ross
1201	Jodie Foster
1202	Ariel Levy
1203	Kirby Bliss Blanton
1204	Scott Glenn
1205	Albert Finney
1206	Alycia Debnam-Carey
1207	William Moseley
1208	Brit Morgan
1209	Jim Caviezel
1210	Val Kilmer
1211	Min-sik Choi
1212	Amr Waked
1213	Cynthia Nixon
1214	Duncan Duff
1215	Keith Carradine
1216	Scott Mescudi
1217	Werner Herzog
1218	Kati Outinen
1219	Jennifer Connelly
1220	Peter Riegert
1221	Olivia Williams
1222	Anna Friel
1223	Bruce Greenwood
1224	Max Martini
1225	Hilary Swank
1226	Harry Connick Jr.
1227	Lisa Kudrow
1228	Richard Dreyfuss
1229	Gillian Jacobs
1230	Mike Birbiglia
1231	Chris Gethard
1232	Elisabeth Moss
1233	Dave Johns
1234	Hayley Squires
1235	Sharon Percy
1236	Briana Shann
1237	Joey Lauren Adams
1238	Ruth Negga
1239	Will Dalton
1240	Dean Mumford
1241	Martin McCann
1242	Andrew Simpson
1243	Richenda Carey
1244	Jennifer Lopez
1245	Kristin Chenoweth
1246	John Corbett
1247	Allison Tolman
1248	Luke Evans
1249	Dax Shepard
1250	Dolph Lundgren
1251	Shiloh Fernandez
1252	Lou Taylor Pucci
1253	Juliet Rylance
1254	James Ransone
1255	Fred Dalton Thompson
1256	Jack McBrayer
1257	Jane Lynch
1258	Sarah Silverman
1259	Levi Miller
1260	Rosie Huntington-Whiteley
1261	Sarita Choudhury
1262	Alexander Black
1263	Jack O'Connell
1264	Kate Upton
1265	Susan Sarandon
1266	Patrick Dempsey
1267	Anders Holm
1268	Greg Kinnear
1269	Katey Sagal
1270	Jason Flemyng
1271	Bruce Boxleitner
1272	Philip Seymour Hoffman
1273	Frank Langella
1274	Lily Rabe
1275	Dave Bautista
1276	Alain Moussi
1277	Gina Carano
1278	Jean-Claude Van Damme
1279	Noah Ringer
1280	Jackson Rathbone
1281	Rob Corddry
1282	Ellie Kemper
1283	Matthew Morrison
1284	J. Todd Smith
1285	Robin Wright
1286	Sam Elliott
1287	Matt Long
1288	Miyavi
1289	Stephen Dorff
1290	Kelly Macdonald
1291	Billy Connolly
1292	Emma Thompson
1293	Julie Walters
1294	Ewa Fröling
1295	Lena Endre
1296	Xavier Samuel
1297	James Frecheville
1298	James Gandolfini
1299	Matthias Schoenaerts
1300	Laura Ramsey
1301	Vinnie Jones
1302	Cara Buono
1303	Sean Faris
1304	Djimon Hounsou
1305	Sacha Baron Cohen
1306	Freddie Crowder
1307	Sam Rockwell
1308	Kevin Spacey
1309	Dominique McElligott
1310	Rosie Shaw
1311	Giovanni Ribisi
1312	Mel Gibson
1313	Erin Moriarty
1314	Morgan Lily
1315	Trenton Rogers
1316	Dustin Hoffman
1317	Matt Vael
1318	Simon Cotton
1319	Kevin Leslie
1320	Olivia Moyles
1321	Fionn O'Shea
1322	Nicholas Galitzine
1323	Moe Dunford
1324	John Hawkes
1325	Garret Dillahunt
1326	Isaiah Stone
1327	Steve Wiebe
1328	Anne Dorval
1329	Antoine-Olivier Pilon
1330	Suzanne Clément
1331	Patrick Huard
1332	Selma Blair
1333	Doug Jones
1334	John Alexander
1335	Alice Englert
1336	Sandra Hüller
1337	Peter Simonischek
1338	Michael Wittenborn
1339	Thomas Loibl
1340	Sam Shepard
1341	Mary-Louise Parker
1342	Tony Danza
1343	Kelly Reilly
1344	Paul Sidhu
1345	Branden Coles
1346	Arielle Holmes
1347	Kelcey Watson
1348	Jon Daly
1349	Shameik Moore
1350	Kiersey Clemons
1351	Kimberly Elise
1352	Michael Ealy
1353	India Eisley
1354	Stephen Rea
1355	Storm Acheche Sahlstrøm
1356	Jared Padalecki
1357	Amanda Righetti
1358	Derek Mears
1359	Danielle Panabaker
1360	Bokeem Woodbine
1361	Lyndsy Fonseca
1362	Michael Doneger
1363	Tommy Dewey
1364	Bruce Campbell
1365	Robin Williams
1366	Dick Van Dyke
1367	Oliver Platt
1368	Randall Park
1369	Kang-ho Song
1370	Hee-Bong Byun
1371	Hae-il Park
1372	Doona Bae
1373	Amber Perkins
1374	Rachel Quinn
1375	Dean Waite
1376	Jael Elizabeth Steinmeyer
1377	Ben Burtt
1378	Elissa Knight
1379	Jeff Garlin
1380	Fred Willard
1381	Katherine Heigl
1382	Heather Sossaman
1383	Matthew Bohrer
1384	Courtney Halverson
1385	Shelley Hennig
1386	Jason Biggs
1387	Alyson Hannigan
1388	Seann William Scott
1389	Chris Klein
1390	Jaden Smith
1391	Brian Howe
1392	Darío Grandinetti
1393	María Marull
1394	Mónica Villa
1395	Rita Cortese
1396	Jorge Garcia
1397	Pierre Niney
1398	Paula Beer
1399	Ernst Stötzner
1400	Marie Gruber
1401	Sofia Black-D'Elia
1402	Analeigh Tipton
1403	Travis Tope
1404	Michael Kelly
1405	Clint Eastwood
1406	Bee Vang
1407	Christopher Carley
1408	Ahney Her
1409	Riccardo Scamarcio
1410	Dan Crisafulli
1411	Kay Whitney
1412	Richard Garcia
1413	Pat Cashman
1414	Rachael Blake
1415	Ewen Leslie
1416	Bridgette Barrett
1417	Lucy Fry
1418	Gabriel Byrne
1419	Alan Rickman
1420	Jeffrey Dean Morgan
1421	Jorma Taccone
1422	Akiva Schaffer
1423	David Troughton
1424	Jack Holden
1425	Joe Blakemore
1426	Christian Stolte
1427	Ellar Coltrane
1428	Patricia Arquette
1429	Elijah Smith
1430	Noel Fisher
1431	Armin Mueller-Stahl
1432	Josef Altin
1433	Nicholas Hope
1434	Gary Cole
1435	Victoria Justice
1436	Michael McDonald
1437	André Marcon
1438	Roman Kolinka
1439	Edith Scob
1440	Dale Dickey
1441	Jessica Barth
1442	Tony Shalhoub
1443	Kagiso Kuypers
1444	Alessandro Nivola
1445	James Hamrick
1446	Joel Kinnaman
1447	Brian Geraghty
1448	Andre Braugher
1449	50 Cent
1450	Lily Collins
1451	Christian Cooke
1452	Jaime Winstone
1453	Mae Whitman
1454	Bella Thorne
1455	Robbie Amell
1456	Allison Janney
1457	Byung-hun Lee
1458	Ji-min Han
1459	Jasper Newell
1460	Chloë Sevigny
1461	Emma Greenwell
1462	Jamie Campbell Bower
1463	Robert Sheehan
1464	Jemima West
1465	Derek Jacobi
1466	Stuart Graham
1467	Laine Megaw
1468	Brian Milligan
1469	Liam McMahon
1470	Hayden Christensen
1471	Rachel Bilson
1472	Tim Allen
1473	Joan Cusack
1474	Ned Beatty
1475	Sienna Guillory
1476	Aryana Engineer
1477	Alia Bhatt
1478	Shah Rukh Khan
1479	Kunal Kapoor
1480	Priyanka Moodley
1481	Adewale Akinnuoye-Agbaje
1482	Suraj Sharma
1483	Adil Hussain
1484	Tabu
1485	Cary-Hiroyuki Tagawa
1486	Sarah Roemer
1487	Michael Pitt
1488	Steven Yeun
1489	Astrid Bergès-Frisbey
1490	Brit Marling
1491	Maggie Q
1492	Wesley Elder
1493	Christina Grimmie
1494	Osric Chau
1495	Olan Rogers
1496	Brady Corbet
1497	Joel McHale
1498	Shea Adams
1499	Eddie Baroo
1500	Billy Bob Thornton
1501	Mauricio Lopez
1502	Josh Stewart
1503	Bill Engvall
1504	Alex Essoe
1505	Ronnie Gene Blevins
1506	Lisa Thoreson
1507	Florence Kastriner
1508	Robert Duvall
1509	Emmanuel Garijo
1510	Tom Hudson
1511	Baptiste Goy
1512	Axel Devillers
1513	Lubna Azabal
1514	Mélissa Désormeaux-Poulin
1515	Maxim Gaudette
1516	Mustafa Kamel
1517	Jerry Stiller
1518	Brittany Murphy
1519	Kevin Connolly
1520	Jerry Ferrara
1521	Kevin Dillon
1522	Scott Speedman
1523	Gemma Ward
1524	Alex Fisher
1525	Gaby Hoffmann
1526	Salma Hayek
1527	James Allen McCune
1528	Callie Hernandez
1529	Corbin Reid
1530	Brandon Scott
1531	Jackie Chan
1532	Wenwen Han
1533	Patricia Clarkson
1534	Jenna Elfman
1535	Rufus Sewell
1536	Dan Stevens
1537	Sheila Kelley
1538	Joel David Moore
1539	Aasif Mandvi
1540	Mia Stallard
1541	Audrey Tautou
1542	Jean Reno
1543	Eddie Murphy
1544	Natascha McElhone
1545	Christopher Lee
1546	Kiernan Shipka
1547	Lauren Holly
1548	Lucy Boynton
1549	Brian Dennehy
1550	Brendan Fraser
1551	Ella Anderson
1552	Usher Raymond
1553	Rubén Blades
1554	Ricardo Darín
1555	Soledad Villamil
1556	Pablo Rago
1557	Carla Quevedo
1558	Wes Bentley
1559	Emily Ratajkowski
1560	Jonny Weston
1561	Brian White
1562	Karrueche Tran
1563	Angelique Pereira
1564	Jessica Vanessa DeLeon
1565	Taissa Farmiga
1566	Steve Tom
1567	Elizabeth Reaser
1568	Lulu Wilson
1569	Henry Thomas
1570	Nathan Fillion
1571	Karen Gillan
1572	Katee Sackhoff
1573	Rory Cochrane
1574	Elizabeth Berrington
1575	Til Schweiger
1576	Tatiana Pauhofová
1577	Karl Markovics
1578	Gedeon Burkhard
1579	Simona Stasová
1580	Dermot Mulroney
1581	Diego Klattenhoff
1582	Larenz Tate
1583	Meagan Good
1584	Rotimi
1585	Rick Gonzalez
1586	Rose McGowan
1587	Freddie Highmore
1588	Jonathan Rhys Meyers
1589	Barkhad Abdi
1590	Max Burkholder
1591	Adelaide Kane
1592	Anushka Sharma
1593	Sanjay Dutt
1594	Boman Irani
1595	Karen Allen
1596	Cara Delevingne
1597	Austin Abrams
1598	Justice Smith
1599	Anthony LaPaglia
1600	Craig Ferguson
1601	Bob Balaban
1602	Sean Patrick Thomas
1603	Ellen Burstyn
1604	Malcolm McDowell
1605	Richard Brake
1606	Jeff Daniel Phillips
1607	Sheri Moon Zombie
1608	Logan Huffman
1609	Alexander Ludwig
1610	Maddy Curley
1611	John DeLuca
1612	Nikki SooHoo
1613	Drew Seeley
1614	Malcolm Sinclair
1615	Raghuvir Joshi
1616	January Jones
1617	Aidan Quinn
1618	Natalie Martinez
1619	Demi Moore
1620	Dane Cook
1621	Callum Turner
1622	Grace Van Patten
1623	Michal Vondel
1624	Emma Fitzpatrick
1625	John Cullum
1626	Barkhad Abdirahman
1627	Aidan Turner
1628	Ben Winchell
1629	Josh Brener
1630	Andy Garcia
1631	Ike Barinholtz
1632	John D'Leo
1633	Craig Robinson
1634	Gerry Bednob
1635	Gaspard Schlatter
1636	Sixtine Murat
1637	Paulin Jaccoud
1638	Michel Vuillermoz
1639	Mandy Gonzalez
1640	Ashton Kutcher
1641	Kevin Kline
1642	Cary Elwes
1643	Jeremy Davies
1644	Zach Grenier
1645	Benjamin Bratt
1646	Miranda Cosgrove
1647	Boyd Holbrook
1648	Lily-Rose Depp
1649	Harley Quinn Smith
1650	Christopher Walken
1651	Crispin Glover
1652	Mary McCormack
1653	Paul Birchard
1654	Jessica Lange
1655	David Oyelowo
1656	Tom Felton
1657	Tom Sizemore
1658	Matt Lanter
1659	Munro Chambers
1660	Laurence Leboeuf
1661	Michael Ironside
1662	Edwin Wright
1663	Megan Charpentier
1664	Isabelle Nélisse
1665	Isabelle Fuhrman
1666	CCH Pounder
1667	Woody Allen
1668	Jason Barry
1669	Karen Moskow
1670	Kai Ryssdal
1671	Amber Tamblyn
1672	Sean Bott
1673	Ward Horton
1674	Alfre Woodard
1675	Tony Amendola
1676	Katie Cassidy
1677	Elizabeth Henstridge
1678	Adam Campbell
1679	Miles Fisher
1680	Kristin Scott Thomas
1681	Eric Godon
1682	Lily Cole
1683	Marlon Wayans
1684	Michael C. Hall
1685	Maria Dizzia
1686	Michael Vartan
1687	Nadine Velazquez
1688	Charlie Heaton
1689	Mark Chao
1690	Ni Ni
1691	Danny Trejo
1692	Carmen Electra
1693	Vanessa Lachey
1694	Nicole Parker
1695	Antonio Tarver
1696	Milo Ventimiglia
1697	Burt Young
1698	Devon Bostick
1699	Su Elliot
1700	Donald Sutherland
1701	Alexis Dziena
1702	Wentworth Miller
1703	Adrian Titieni
1704	Maria-Victoria Dragus
1705	Lia Bugnar
1706	Malina Manovici
1707	John Turturro
1708	Emmanuelle Chriqui
1709	Nick Swardson
1710	Christopher McDonald
1711	Mira Sorvino
1712	Sally Hawkins
1713	Kari Matchett
1714	Zachary Bennett
1715	Keith David
1716	Oprah Winfrey
1717	Bruno Campos
1718	Ethan Suplee
1719	Jim Parsons
1720	Steve Martin
1721	Jim Sturgess
1722	Sylvia Hoeks
1723	Sophie Nélisse
1724	Josh Wiggins
1725	Joe Cobden
1726	T.R. Knight
1727	Nicole Beharie
1728	Aaron Yoo
1729	Adam Levine
1730	Christopher Evan Welch
1731	Regina Hall
1732	Anthony Anderson
1733	Eve
1734	Moon Bloodgood
1735	Imelda Staunton
1736	Ted Levine
1737	Kathleen Quinlan
1738	Emilie de Ravin
1739	Colm Feore
1740	Gattlin Griffith
1741	Caitlyn Rund
1742	Moisés Acevedo
1743	Miyu Irino
1744	Saori Hayami
1745	Kenshô Ono
1746	Ruth Wilson
1747	Aiden Longworth
1748	Juno Temple
1749	Max Minghella
1750	Joe Anderson
1751	Tijuana Ricks
1752	Sue Dahlman
1753	Tye Sheridan
1754	Ving Rhames
1755	Rolf Lassgård
1756	Bahar Pars
1757	Filip Berg
1758	Ida Engvoll
1759	Justin Chatwin
1760	James Marsters
1761	Yun-Fat Chow
1762	Emmy Rossum
1763	Isabel Lucas
1764	Josh Peck
1765	Tom Mison
1766	Josh Lucas
1767	Alexis Clagett
1768	Robert Carlyle
1769	Harold Perrineau
1770	John Malkovich
1771	Adrianne Palicki
1772	Hiroki Hasegawa
1773	Yutaka Takenouchi
1774	Satomi Ishihara
1775	Ren Ôsugi
1776	Annie Rose Buckley
1777	George Lopez
1778	Karen Disher
1779	Vernetta Lopez
1780	Scott Lawrence
1781	Gael García Bernal
1782	Mohamed Akhzam
1783	Hunter McCracken
1784	Taylor Schilling
1785	Blythe Danner
1786	Riley Thomas Stewart
1787	Elisabeth Shue
1788	Jerry O'Connell
1789	Dylan Duffus
1790	Scorcher
1791	Shone Romulus
1792	Jade Asha
1793	Maude Apatow
1794	Iris Apatow
1795	Dakota Goyo
1796	Sarah Jessica Parker
1797	Kim Cattrall
1798	Kristin Davis
1799	Julie Benz
1800	Matthew Marsden
1801	Graham McTavish
1802	Freddy Rodríguez
1803	Marley Shelton
1804	David Morse
1805	Lee Pace
1806	Catinca Untaru
1807	Justine Waddell
1808	Kim Uylenbroek
1809	Bree Turner
1810	Eric Winter
1811	Candice Bergen
1812	Bryan Greenberg
1813	Jordan Carlos
1814	Margarita Levieva
1815	Julianna Margulies
1816	Nathan Phillips
1817	Rachel Blanchard
1818	Zoe Kazan
1819	Megan Park
1820	Max Greenfield
1821	Tyne Daly
1822	Michael Mantell
1823	Michael Rooker
1824	Don Thompson
1825	Toby Jones
1826	Paula Prentiss
1827	AnnaSophia Robb
1828	Robert Patrick
1829	Emily Baldoni
1830	Maury Sterling
1831	Nicholas Brendon
1832	Elizabeth Gracen
1833	Jamal Woolard
1834	Derek Luke
1835	Momo Dione
1836	Jun Kunimura
1837	Jung-min Hwang
1838	Do-won Kwak
1839	Woo-hee Chun
1840	Randy Couture
1841	William Atherton
1842	Blythe Auffarth
1843	Blanche Baker
1844	Kevin Chamberlin
1845	Francesc Albiol
1846	Dakota Blue Richards
1847	Ben Walker
1848	Andreas Wisniewski
1849	Logan Miller
1850	Joey Morgan
1851	Sarah Dumont
1852	Matthew Perry
1853	Chatchawai Kamonsakpitak
1854	Brandon Routh
1855	Gabourey Sidibe
1856	Mo'Nique
1857	Mariah Carey
1858	Ryoko Seta
1859	Nicholas Braun
1860	Mateo Arias
1861	Israel Broussard
1862	Jesse Plemons
1863	Kenny Wormald
1864	Andie MacDowell
1865	Jamie Blackley
1866	Joshua Leonard
1867	Bel Powley
1868	Stephen Moyer
1869	Samantha Robinson
1870	Jeffrey Vincent Parise
1871	Laura Waddell
1872	Gian Keys
1873	Dieter Laser
1874	Ashley C. Williams
1875	Ashlynn Yennie
1876	Akihiro Kitamura
1877	Rainn Wilson
1878	Brooke Shields
1879	Gabriel Luna
1880	David Acord
1881	Ari Graynor
1882	Jordi Mollà
1883	Melissa George
1884	Joshua McIvor
1885	Jack Taylor
1886	Michael Dorman
1887	Garrett Clayton
1888	Christian Slater
1889	Molly Ringwald
1890	James Kelley
1891	Sophie Okonedo
1892	Jahking Guillory
1893	Christopher Jordan Wallace
1894	Christopher Meyer
1895	Kofi Siriboe
1896	Thomas Mann
1897	RJ Cyler
1898	Olivia Cooke
1899	Amara Miller
1900	Nick Krause
1901	Nick Robinson
1902	Moises Arias
1903	Paul Bettany
1904	Charles S. Dutton
1905	America Ferrera
1906	Connie Nielsen
1907	Josh Hartnett
1908	Lucy Liu
1909	Danny Sapani
1910	Evan Rachel Wood
1911	Callum Keith Rennie
1912	Sarah Butler
1913	Jeff Branson
1914	Andrew Howard
1915	Daniel Franzese
1916	Hayden Panettiere
1917	Catalina Sandino Moreno
1918	Karolina Gruszka
1919	Lambert Wilson
1920	Guillaume Baillargeon
1921	Émilie Leclerc
1922	Andrea Whitburn
1923	Jennifer Koenig
1924	Michael Dickson
1925	Tania Raymonde
1926	Trey Songz
1927	Carrie-Anne Moss
1928	Diego Boneta
1929	Neve Campbell
1930	Courteney Cox
1931	David Arquette
1932	Lucy Hale
1933	Madina Nalwanga
1934	Lupita Nyong'o
1935	Martin Kabanza
1936	Nia Vardalos
1937	Michael Constantine
1938	Lainie Kazan
1939	Janet Montgomery
1940	Ashley Tisdale
1941	Bria L. Murphy
1942	Nathalie Baye
1943	Elena Anaya
1944	Jan Cornet
1945	Marisa Paredes
1946	Kylie Rogers
1947	Brighton Sharbino
1948	Quvenzhané Wallis
1949	Dana Fuchs
1950	Jake Johnson
1951	Damon Wayans Jr.
1952	Nina Dobrev
1953	Luke Kleintank
1954	Lauren Graham
1955	Rasmus Hardiker
1956	Nicholas D'Agosto
1957	Emma Bell
1958	Arlen Escarpeta
1959	Morjana Alaoui
1960	Mylène Jampanoï
1961	Catherine Bégin
1962	Robert Toupin
1963	Carmen Ejogo
1964	Lorraine Toussaint
1965	Steven Mackintosh
1966	Darsheel Safary
1967	Tanay Chheda
1968	Sachet Engineer
1969	Kim Coates
1970	Oliver Cooper
1971	Jonathan Daniel Brown
1972	Dax Flame
1973	Dean Norris
1974	Lauren German
1975	Heather Matarazzo
1976	Bijou Phillips
1977	Roger Bart
1978	Robert Hoffman
1979	Briana Evigan
1980	Cassie Ventura
1981	Adam G. Sevani
1982	Adam Pally
1983	Thomas Middleditch
1984	Shannon Woodward
1985	Cheryl Hines
\.


--
-- Data for Name: director; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.director (id_director, nombre_director) FROM stdin;
1	James Gunn
2	Ridley Scott
3	M. Night Shyamalan
4	Christophe Lourdelet
5	David Ayer
6	Yimou Zhang
7	Damien Chazelle
8	Sean Foley
9	James Gray
10	Morten Tyldum
11	David Yates
12	Theodore Melfi
13	Gareth Edwards
14	Ron Clements
15	Nacho Vigalondo
16	Chris Renaud
17	Mel Gibson
18	Paul Greengrass
19	Garth Davis
20	Denis Villeneuve
21	Stephen Gaghan
22	Kenneth Lonergan
23	Ben Young
24	Walt Dohrn
25	Roland Emmerich
26	Dominique Abel
27	S.S. Rajamouli
28	Phillip Guzman
29	Jon Lucas
30	Justin Kurzel
31	John Hamburg
32	Tom Ford
33	Bryan Singer
34	Tim Miller
35	Paul W.S. Anderson
36	Anthony Russo
37	Christopher Nolan
38	Scott Derrickson
39	Antoine Fuqua
40	Patrick Read Johnson
41	Greg Tiernan
42	Barry Jenkins
43	Shawn Burkett
44	John Lee Hancock
45	Ricardo de Montreuil
46	Rob Marshall
47	John Madden
48	Scott Hicks
49	Justin Lin
50	Sean Penn
51	J.J. Abrams
52	Anna Foerster
53	Garry Marshall
54	Chad Stahelski
55	Martin Scorsese
56	Fede Alvarez
57	Thea Sharrock
58	Lone Scherfig
59	Clint Eastwood
60	Zack Snyder
61	André Øvredal
62	Tate Taylor
63	Sam Taylor-Johnson
64	Matthew Vaughn
65	Peter Berg
66	George Miller
67	Robin Swicord
68	Terry George
69	Robert Zemeckis
70	J.A. Bayona
71	David Frankel
72	Byron Howard
73	Gore Verbinski
74	Joss Whedon
75	Quentin Tarantino
76	Paul Feig
77	Matt Ross
78	David Fincher
79	James Wan
80	Colin Trevorrow
81	Ben Affleck
82	James Cameron
83	Gavin O'Connor
84	Duncan Jones
85	Todd Phillips
86	Shane Black
87	Makoto Shinkai
88	Jeremy Gillespie
89	Olivier Assayas
90	Brian Helgeland
91	Kenneth Branagh
92	Oriol Paulo
93	Guy Ritchie
94	David Mackenzie
95	Taylor Hackford
96	Katie Holmes
97	Alex Garland
98	Greg McLean
99	Steve McQueen
100	Ana Lily Amirpour
101	Josh Gordon
102	Nicolas Winding Refn
103	Nitesh Tiwari
104	Dan Trachtenberg
105	Andrew Stanton
106	Tim Burton
107	Neil Burger
108	Jake Szymanski
109	Todor Chapkanov
110	Jon Favreau
111	Michael Bay
112	Henry Joost
113	Phyllida Lloyd
114	Alejandro González Iñárritu
115	Denzel Washington
116	Jaume Collet-Serra
117	Derek Cianfrance
118	Ethan Coen
119	Baz Luhrmann
120	Martin Koolhoven
121	Thor Freudenthal
122	Adam McKay
123	Lenny Abrahamson
124	Chan-wook Park
125	Kelly Fremon Craig
126	Greg Mottola
127	Ron Howard
128	Steven Spielberg
129	Gary Ross
130	Elizabeth Wood
131	David Lynch
132	Colin Strause
133	Guillermo del Toro
134	Glenn Ficarra
135	Edgar Wright
136	Fabio Guaglione
137	Ben Wheatley
138	Edward Zwick
139	Martin Campbell
140	Catherine Hardwicke
141	Jon M. Chu
142	Simon Curtis
143	Sam Mendes
144	Dan Gilroy
145	Travis Knight
146	Jackson Stewart
147	Spike Jonze
148	Chris Buck
149	Brad Bird
150	Matt Reeves
151	Ben Stiller
152	Peyton Reed
153	Sharon Maguire
154	Robert Eggers
155	Mateo Gil
156	Asghar Farhadi
157	Gaspar Noé
158	Ang Lee
159	Judd Apatow
160	April Mullen
161	Tom McCarthy
162	Luke Scott
163	Joe Johnston
164	Akan Satayev
165	Rawson Marshall Thurber
166	Doug Liman
167	Oliver Stone
168	Robert Schwentke
169	Julia Ducournau
170	Jim Jarmusch
171	Colm McCarthy
172	Brad Peyton
173	Harmony Korine
174	Spike Lee
175	Alan Taylor
176	Alex Proyas
177	Chris Wedge
178	Liam Gavin
179	Ilya Naishuller
180	John Lasseter
181	David Robert Mitchell
182	Andrea Arnold
183	Yorgos Lanthimos
184	Nimród Antal
185	Robert Stromberg
186	Steven Shainberg
187	Andy Goddard
188	Christopher McQuarrie
189	Cedric Nicolas-Troyan
190	Stephen Chbosky
191	Pablo Larraín
192	D.J. Caruso
193	Wes Anderson
194	Andrew Niccol
195	Pete Docter
196	Ash Brannon
197	Chris Columbus
198	Tom Hooper
199	Alfonso Cuarón
200	Mike Mills
201	Olivier Nakache
202	Eleanor Coppola
203	F. Gary Gray
204	Marc Webb
205	Rupert Wyatt
206	David F. Sandberg
207	Joseph Cedar
208	Darren Aronofsky
209	Justin Simien
210	Lars von Trier
211	Dave Green
212	Eli Roth
213	Dan Mazer
214	Tom Tykwer
215	Gavin Hood
216	Jeffrey G. Hunt
217	Peter Jackson
218	Phil Lord
219	John Carney
220	Eric Summer
221	Joseph Kosinski
222	Richard Linklater
223	Louis Leterrier
224	Brett Ratner
225	Lana Wachowski
226	Jared Hess
227	Jalil Lespert
228	Sang-ho Yeon
229	Jason Moore
230	Nicholas Stoller
231	David Leveaux
232	Ross Katz
233	Mike Thurmeier
234	Brad Furman
235	Paul Thomas Anderson
236	Drew Goddard
237	Fred Wolf
238	Jim Field Smith
239	James Bobin
240	Gary Michael Schultz
241	Christian Ditter
242	Abdellatif Kechiche
243	Jennifer Kent
244	Bong Joon Ho
245	J Blakeson
246	Dan Berk
247	Anne Fletcher
248	So Yong Kim
249	Breck Eisner
250	Paul McGuigan
251	Roger Spottiswoode
252	Jeremy Saulnier
253	Michael Mann
254	Jean-Marc Vallée
255	Mike Flanagan
256	David O. Russell
257	Alexi Pappas
258	Josh Boone
259	Frank Coraci
260	Rian Johnson
261	David Lowery
262	Sam Raimi
263	Karyn Kusama
264	Woody Allen
265	William Oldroyd
266	Jocelyn Moorhouse
267	Sergei Bodrov
268	Hugo Gélin
269	James Marsh
270	Evan Goldberg
271	Richard Curtis
272	Jon Watts
273	Ruben Fleischer
274	Danny Boyle
275	Bill Condon
276	Alex Ranarivelo
277	Timur Bekmambetov
278	J.D. Dillard
279	Wes Ball
280	Ariel Vromen
281	Stephen Frears
282	Eran Creevy
283	Scott Cooper
284	Ryan Coogler
285	Dan Kwan
286	Patrick Hughes
287	Jemaine Clement
288	Baltasar Kormákur
289	James Mangold
290	Peter Atencio
291	Pierre Morel
292	Gillies MacKinnon
293	Dennis Dugan
294	Lee Toland Krieger
295	Peter Billingsley
296	Terry Jones
297	Steven Soderbergh
298	Kyle Balda
299	Rolfe Kanefsky
300	Pierre Coffin
301	Michael Hoffman
302	Kathryn Bigelow
303	Nathan Greno
304	Francis Lawrence
305	John Francis Daley
306	Elizabeth Banks
307	Dan Scanlon
308	Paul Verhoeven
309	Dennis Gansel
310	Kevin Smith
311	Mark Williams
312	Joe Wright
313	David Ross
314	Burr Steers
315	Noam Murro
316	Babak Najafi
317	Frank Miller
318	Srdjan Spasojevic
319	James DeMonaco
320	Rajkumar Hirani
321	Marc Forster
322	Corey Asraf
323	Jon S. Baird
324	George Tillman Jr.
325	Jeff Wadlow
326	Jeff Grace
327	John Crowley
328	Henry Selick
329	Michael J. Gallagher
330	Christophe Gans
331	Pete Travis
332	Taika Waititi
333	Don Hall
334	Kimberly Peirce
335	Christian Alvart
336	Thomas Vinterberg
337	Etan Cohen
338	William Brent Bell
339	Mick Jackson
340	Michael Spierig
341	Rob Letterman
342	Phillip Noyce
343	Neill Blomkamp
344	Sofia Coppola
345	Dexter Fletcher
346	Florian Henckel von Donnersmarck
347	Carles Torrens
348	Amber Tamblyn
349	John Hillcoat
350	Paolo Genovese
351	Clay Kaytis
352	Adam Shankman
353	Lasse Hallström
354	Jim Mickle
355	Albert Hughes
356	Ericson Core
357	Jonathan Glazer
358	Barry Sonnenfeld
359	Todd Haynes
360	Daniel Ragussis
361	Paolo Sorrentino
362	Jaco Van Dormael
363	Mark Herman
364	S. Craig Zahler
365	Gregory Jacobs
366	Will Gluck
367	Biyi Bandele
368	Sean Ellis
369	Andrey Kravchuk
370	David Schwimmer
371	George Nolfi
372	Tony Gilroy
373	Simon Verhoeven
374	Tony Scott
375	Luc Besson
376	Terence Davies
377	Scott Waugh
378	Steven Brill
379	Alexandros Avranas
380	Ewan McGregor
381	Roman Polanski
382	Nic Mathieu
383	Richard LaGravenese
384	Mora Stephens
385	Jeff Nichols
386	Mike Birbiglia
387	Philippe Falardeau
388	Ken Loach
389	Josh Trank
390	Stephen Fingleton
391	Florian Gallenberger
392	Rob Cohen
393	Joel Edgerton
394	Gary Shore
395	Mike Judge
396	Sylvester Stallone
397	Rich Moore
398	Rupert Sanders
399	Jason Reitman
400	Jodie Foster
401	Nick Cassavetes
402	Kevin Lima
403	Nancy Meyers
404	Jonathan Dayton
405	Ben Younger
406	Craig Gillespie
407	Andrew Jarecki
408	John Stockwell
409	Jake Kasdan
410	Kirk Jones
411	Bennett Miller
412	Mark Steven Johnson
413	Angelina Jolie
414	Tarsem Singh
415	Mark Andrews
416	Niels Arden Oplev
417	Anne Fontaine
418	Michaël R. Roskam
419	Andy Fickman
420	Sean Anders
421	Tom McGrath
422	Jean-François Richet
423	Ken Kwapis
424	Alessandro Carloni
425	Zackary Adler
426	John Butler
427	Debra Granik
428	Seth Gordon
429	Xavier Dolan
430	Maren Ade
431	Andrew Dominik
432	Joseph Gordon-Levitt
433	James Watkins
434	Joey Curtis
435	Paco Cabezas
436	Rick Famuyiwa
437	Måns Mårlind
438	Marcus Nispel
439	Olivier Megaton
440	Len Wiseman
441	Will Slocombe
442	Courtney Hunt
443	Shawn Levy
444	Michael Goi
445	Levan Gabriadze
446	Jon Hurwitz
447	Gabriele Muccino
448	Damián Szifron
449	François Ozon
450	John Wells
451	Jonathan Holbrook
452	Julia Leigh
453	Mark Waters
454	Afonso Poyart
455	Akiva Schaffer
456	Hope Dickson Leach
457	Jonathan Liebesman
458	David Cronenberg
459	Simon Stone
460	David Gordon Green
461	Jon Kasdan
462	Mia Hansen-Løve
463	Alejandro Amenábar
464	Seth MacFarlane
465	Atom Egoyan
466	Daniel Espinosa
467	John Michael McDonagh
468	Frank Darabont
469	Mikael Håfström
470	Ari Sandel
471	Jee-woon Kim
472	Lynne Ramsay
473	Whit Stillman
474	Harald Zwart
475	Lee Unkrich
476	Tomas Alfredson
477	Gauri Shinde
478	Michael Grandage
479	Jamie Linden
480	Mike Cahill
481	Caleb Vetter
482	Michael Haneke
483	Marcus Dunstan
484	John Krasinski
485	David Dobkin
486	Michael Dudok de Wit
487	Jorge R. Gutiérrez
488	Bobby Farrelly
489	Doug Ellin
490	Bryan Bertino
491	Adam Wingard
492	Joe Carnahan
493	Simon Aboud
494	Bruce Beresford
495	Oz Perkins
496	Terrence Malick
497	Ben Falcone
498	Jonathan Jakubowicz
499	Juan José Campanella
500	Max Joseph
501	Chris Stokes
502	Warren Beatty
503	Gregory Hoblit
504	Martin McDonagh
505	McG
506	Filip Renc
507	Ed Gass-Donnelly
508	Jamal Hill
509	Kirsten Sheridan
510	Jake Schreier
511	Walter Hill
512	Dean DeBlois
513	Rob Zombie
514	Tyler Shields
515	Hisonni Johnson
516	Matt Brown
517	Bruce A. Evans
518	Adam Leon
519	Chris Evans
520	Jim Sheridan
521	Stewart Hendler
522	Genndy Tartakovsky
523	Claude Barras
524	Asger Leth
525	Ivan Reitman
526	Werner Herzog
527	Scott Frank
528	Mike Newell
529	James Ponsoldt
530	Amma Asante
531	Mario Van Peebles
532	François Simard
533	Andrés Muschietti
534	John Moore
535	John R. Leonetti
536	Saul Dibb
537	Terry Gilliam
538	Stephen Sommers
539	Antonio Campos
540	Dito Montiel
541	Phil Claydon
542	Farren Blackburn
543	Matthias Hoene
544	Robert Rodriguez
545	Jason Friedberg
546	David Bowers
547	Cary Joji Fukunaga
548	Andy Tennant
549	Larry Charles
550	Erik Van Looy
551	Cristian Mungiu
552	Gee Malik Linton
553	Aisling Walsh
554	Luca Guadagnino
555	Tim Johnson
556	Giuseppe Tornatore
557	Nathan Morlando
558	Robert Luketic
559	Mark Osborne
560	Malcolm D. Lee
561	Alexandre Aja
562	Allen Coulter
563	Naoko Yamada
564	Miguel Arteta
565	Steven Knight
566	James Schamus
567	Kyle Patrick Alvarez
568	Hannes Holm
569	James Wong
570	Dan Bradley
571	Greg Berlanti
572	Juan Carlos Fresnadillo
573	Jonathan Levine
574	Hideaki Anno
575	Wally Pfister
576	Carlos Saldanha
577	Drake Doremus
578	Femi Oyeniran
579	Michael Patrick King
580	Peter Landesman
581	Gary Winick
582	Leslye Headland
583	David R. Ellis
584	Michael Dowse
585	José Padilha
586	James Franco
587	Michael Showalter
588	Matteo Garrone
589	Gabor Csupo
590	James Ward Byrkit
591	Hong-jin Na
592	Simon West
593	Gregory Wilson
594	Chris Weitz
595	Neil Marshall
596	Christopher Landon
597	John Erick Dowdle
598	Lee Daniels
599	Gus Van Sant
600	Chris McCoy
601	Craig Brewer
602	R.J. Cutler
603	Ido Fluk
604	Christopher Smith
605	Anna Biller
606	Tom Six
607	Richie Smyth
608	Ryûhei Kitamura
609	David Slade
610	Greg Kwedar
611	Mark Mylod
612	David Twohy
613	Justin Kelly
614	Justin Tipping
615	Alfonso Gomez-Rejon
616	Alexander Payne
617	Jordan Vogt-Roberts
618	Tom Gormican
619	Scott Stewart
620	Patricia Rozema
621	Justin Chadwick
622	Steven R. Monroe
623	James Lapine
624	Jérôme Salle
625	Micheal Bafaro
626	John Luessenhop
627	Wes Craven
628	Mira Nair
629	Gilles Paquet-Brenner
630	Lisa Addario
631	Pedro Almodóvar
632	Patricia Riggen
633	Julie Taymor
634	Luke Greenfield
635	Boaz Yakin
636	Steven Quale
637	Shana Feste
638	Pascal Laugier
639	Ava DuVernay
640	Patrick Tatopoulos
641	Aamir Khan
642	Nima Nourizadeh
643	Billy Ray
644	Scot Armstrong
\.


--
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.genero (id_genero, nombre_genero) FROM stdin;
1	Action
2	Adventure
3	Sci-Fi
4	Mystery
5	Horror
6	Thriller
7	Animation
8	Comedy
9	Family
10	Fantasy
11	Drama
12	Music
13	Biography
14	Romance
15	History
16	Crime
17	Western
18	War
19	Musical
20	Sport
\.


--
-- Data for Name: pelicula; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelicula (id_pelicula, rank_original, titulo, descripcion, anio, duracion_minutos, calificacion, votos, recaudacion_millones, metascore, id_director) FROM stdin;
1	1	Guardians of the Galaxy	A group of intergalactic criminals are forced to work together to stop a fanatical warrior from taking control of the universe.	2014	121	8.1	757074	333.13	76	1
2	2	Prometheus	Following clues to the origin of mankind, a team finds a structure on a distant moon, but they soon realize they are not alone.	2012	124	7.0	485820	126.46	65	2
3	3	Split	Three girls are kidnapped by a man with a diagnosed 23 distinct personalities. They must try to escape before the apparent emergence of a frightful new 24th.	2016	117	7.3	157606	138.12	62	3
4	4	Sing	In a city of humanoid animals, a hustling theater impresario's attempt to save his theater with a singing competition becomes grander than he anticipates even as its finalists' find that their lives will never be the same.	2016	108	7.2	60545	270.32	59	4
5	5	Suicide Squad	A secret government agency recruits some of the most dangerous incarcerated super-villains to form a defensive task force. Their first mission: save the world from the apocalypse.	2016	123	6.2	393727	325.02	40	5
6	6	The Great Wall	European mercenaries searching for black powder become embroiled in the defense of the Great Wall of China against a horde of monstrous creatures.	2016	103	6.1	56036	45.13	42	6
7	7	La La Land	A jazz pianist falls for an aspiring actress in Los Angeles.	2016	128	8.3	258682	151.06	93	7
8	8	Mindhorn	A has-been actor best known for playing the title character in the 1980s detective series "Mindhorn" must work with the police when a serial killer says that he will only speak with Detective Mindhorn, whom he believes to be a real person.	2016	89	6.4	2490	\N	71	8
9	9	The Lost City of Z	A true-life drama, centering on British explorer Col. Percival Fawcett, who disappeared while searching for a mysterious city in the Amazon in the 1920s.	2016	141	7.1	7188	8.01	78	9
10	10	Passengers	A spacecraft traveling to a distant colony planet and transporting thousands of people has a malfunction in its sleep chambers. As a result, two passengers are awakened 90 years early.	2016	116	7.0	192177	100.01	41	10
11	11	Fantastic Beasts and Where to Find Them	The adventures of writer Newt Scamander in New York's secret community of witches and wizards seventy years before Harry Potter reads his book in school.	2016	133	7.5	232072	234.02	66	11
12	12	Hidden Figures	The story of a team of female African-American mathematicians who served a vital role in NASA during the early years of the U.S. space program.	2016	127	7.8	93103	169.27	74	12
13	13	Rogue One	The Rebel Alliance makes a risky move to steal the plans for the Death Star, setting up the epic saga to follow.	2016	133	7.9	323118	532.17	65	13
14	14	Moana	In Ancient Polynesia, when a terrible curse incurred by the Demigod Maui reaches an impetuous Chieftain's daughter's island, she answers the Ocean's call to seek out the Demigod to set things right.	2016	107	7.7	118151	248.75	81	14
15	15	Colossal	Gloria is an out-of-work party girl forced to leave her life in New York City, and move back home. When reports surface that a giant creature is destroying Seoul, she gradually comes to the realization that she is somehow connected to this phenomenon.	2016	109	6.4	8612	2.87	70	15
16	16	The Secret Life of Pets	The quiet life of a terrier named Max is upended when his owner takes in Duke, a stray whom Max instantly dislikes.	2016	87	6.6	120259	368.31	61	16
17	17	Hacksaw Ridge	WWII American Army Medic Desmond T. Doss, who served during the Battle of Okinawa, refuses to kill people, and becomes the first man in American history to receive the Medal of Honor without firing a shot.	2016	139	8.2	211760	67.12	71	17
18	18	Jason Bourne	The CIA's most dangerous former operative is drawn out of hiding to uncover more explosive truths about his past.	2016	123	6.7	150823	162.16	58	18
19	19	Lion	A five-year-old Indian boy gets lost on the streets of Calcutta, thousands of kilometers from home. He survives many challenges before being adopted by a couple in Australia. 25 years later, he sets out to find his lost family.	2016	118	8.1	102061	51.69	69	19
20	20	Arrival	When twelve mysterious spacecraft appear around the world, linguistics professor Louise Banks is tasked with interpreting the language of the apparent alien visitors.	2016	116	8.0	340798	100.50	81	20
21	21	Gold	Kenny Wells, a prospector desperate for a lucky break, teams up with a similarly eager geologist and sets off on a journey to find gold in the uncharted jungle of Indonesia.	2016	120	6.7	19053	7.22	49	21
22	22	Manchester by the Sea	A depressed uncle is asked to take care of his teenage nephew after the boy's father dies.	2016	137	7.9	134213	47.70	96	22
23	23	Hounds of Love	A cold-blooded predatory couple while cruising the streets in search of their next victim, will stumble upon a 17-year-old high school girl, who will be sedated, abducted and chained in the strangers' guest room.	2016	108	6.7	1115	\N	72	23
24	24	Trolls	After the Bergens invade Troll Village, Poppy, the happiest Troll ever born, and the curmudgeonly Branch set off on a journey to rescue her friends.	2016	92	6.5	38552	153.69	56	24
25	25	Independence Day: Resurgence	Two decades after the first Independence Day invasion, Earth is faced with a new extra-Solar threat. But will mankind's new space defenses be enough?	2016	120	5.3	127553	103.14	32	25
26	26	Paris pieds nus	Fiona visits Paris for the first time to assist her myopic Aunt Martha. Catastrophes ensue, mainly involving Dom, a homeless man who has yet to have an emotion or thought he was afraid of expressing.	2016	83	6.8	222	\N	\N	26
27	27	Bahubali: The Beginning	In ancient India, an adventurous and daring man becomes involved in a decades old feud between two warring people.	2015	159	8.3	76193	6.50	\N	27
28	28	Dead Awake	A young woman must save herself and her friends from an ancient evil that stalks its victims through the real-life phenomenon of sleep paralysis.	2016	99	4.7	523	0.01	\N	28
29	29	Bad Moms	When three overworked and under-appreciated moms are pushed beyond their limits, they ditch their conventional responsibilities for a jolt of long overdue freedom, fun, and comedic self-indulgence.	2016	100	6.2	66540	113.08	60	29
30	30	Assassin's Creed	When Callum Lynch explores the memories of his ancestor Aguilar and gains the skills of a Master Assassin, he discovers he is a descendant of the secret Assassins society.	2016	115	5.9	112813	54.65	36	30
31	31	Why Him?	A holiday gathering threatens to go off the rails when Ned Fleming realizes that his daughter's Silicon Valley millionaire boyfriend is about to pop the question.	2016	111	6.3	48123	60.31	39	31
718	718	The Strangers	A young couple staying in an isolated vacation home are terrorized by three unknown assailants.	2008	86	6.2	96718	52.53	47	490
32	32	Nocturnal Animals	A wealthy art gallery owner is haunted by her ex-husband's novel, a violent thriller she interprets as a symbolic revenge tale.	2016	116	7.5	126030	10.64	67	32
33	33	X-Men: Apocalypse	After the re-emergence of the world's first mutant, world-destroyer Apocalypse, the X-Men must unite to defeat his extinction level plan.	2016	144	7.1	275510	155.33	52	33
34	34	Deadpool	A fast-talking mercenary with a morbid sense of humor is subjected to a rogue experiment that leaves him with accelerated healing powers and a quest for revenge.	2016	108	8.0	627797	363.02	65	34
35	35	Resident Evil: The Final Chapter	Alice returns to where the nightmare began: The Hive in Raccoon City, where the Umbrella Corporation is gathering its forces for a final strike against the only remaining survivors of the apocalypse.	2016	107	5.6	46165	26.84	49	35
36	36	Captain America: Civil War	Political interference in the Avengers' activities causes a rift between former allies Captain America and Iron Man.	2016	147	7.9	411656	408.08	75	36
37	37	Interstellar	A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.	2014	169	8.6	1047747	187.99	74	37
38	38	Doctor Strange	While on a journey of physical and spiritual healing, a brilliant neurosurgeon is drawn into the world of the mystic arts.	2016	115	7.6	293732	232.60	72	38
39	39	The Magnificent Seven	Seven gunmen in the old west gradually come together to help a poor village against savage thieves.	2016	132	6.9	122853	93.38	54	39
40	40	5- 25- 77	Alienated, hopeful-filmmaker Pat Johnson's epic story growing up in rural Illinois, falling in love, and becoming the first fan of the movie that changed everything.	2007	113	7.1	241	\N	\N	40
41	41	Sausage Party	A sausage strives to discover the truth about his existence.	2016	89	6.3	120690	97.66	66	41
42	42	Moonlight	A chronicle of the childhood, adolescence and burgeoning adulthood of a young, African-American, gay man growing up in a rough neighborhood of Miami.	2016	111	7.5	135095	27.85	99	42
43	43	Don't Fuck in the Woods	A group of friends are going on a camping trip to celebrate graduating college. But once they enter the woods, the proverbial shit starts to hit the fan.	2016	73	2.7	496	\N	\N	43
44	44	The Founder	The story of Ray Kroc, a salesman who turned two brothers' innovative fast food eatery, McDonald's, into one of the biggest restaurant businesses in the world with a combination of ambition, persistence, and ruthlessness.	2016	115	7.2	37033	12.79	66	44
45	45	Lowriders	A young street artist in East Los Angeles is caught between his father's obsession with lowrider car culture, his ex-felon brother and his need for self-expression.	2016	99	6.3	279	4.21	57	45
46	46	Pirates of the Caribbean: On Stranger Tides	Jack Sparrow and Barbossa embark on a quest to find the elusive fountain of youth, only to discover that Blackbeard and his daughter are after it too.	2011	136	6.7	395025	241.06	45	46
47	47	Miss Sloane	In the high-stakes world of political power-brokers, Elizabeth Sloane is the most sought after and formidable lobbyist in D.C. But when taking on the most powerful opponent of her career, she finds winning may come at too high a price.	2016	132	7.3	17818	3.44	64	47
48	48	Fallen	A young girl finds herself in a reform school after therapy since she was blamed for the death of a young boy. At the school she finds herself drawn to a fellow student, unaware that he is an angel, and has loved her for thousands of years.	2016	91	5.6	5103	\N	\N	48
49	49	Star Trek Beyond	The USS Enterprise crew explores the furthest reaches of uncharted space, where they encounter a new ruthless enemy who puts them and everything the Federation stands for to the test.	2016	122	7.1	164567	158.80	68	49
50	50	The Last Face	A director (Charlize Theron) of an international aid agency in Africa meets a relief aid doctor (Javier Bardem) amidst a political/social revolution, and together face tough choices ... See full summary »	2016	130	3.7	987	\N	16	50
51	51	Star Wars: Episode VII - The Force Awakens	Three decades after the defeat of the Galactic Empire, a new threat arises. The First Order attempts to rule the galaxy and only a ragtag group of heroes can stop them, along with the help of the Resistance.	2015	136	8.1	661608	936.63	81	51
52	52	Underworld: Blood Wars	Vampire death dealer, Selene (Kate Beckinsale) fights to end the eternal war between the Lycan clan and the Vampire faction that betrayed her.	2016	91	5.8	41362	30.35	23	52
53	53	Mother's Day	Three generations come together in the week leading up to Mother's Day.	2016	118	5.6	20221	32.46	18	53
54	54	John Wick	An ex-hitman comes out of retirement to track down the gangsters that took everything from him.	2014	101	7.2	321933	43.00	68	54
55	55	The Dark Knight	When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, the Dark Knight must come to terms with one of the greatest psychological tests of his ability to fight injustice.	2008	152	9.0	1791916	533.32	82	37
56	56	Silence	In the 17th century, two Portuguese Jesuit priests travel to Japan in an attempt to locate their mentor, who is rumored to have committed apostasy, and to propagate Catholicism.	2016	161	7.3	49190	7.08	79	55
57	57	Don't Breathe	Hoping to walk away with a massive fortune, a trio of thieves break into the house of a blind man who isn't as helpless as he seems.	2016	88	7.2	121103	89.21	71	56
58	58	Me Before You	A girl in a small town forms an unlikely bond with a recently-paralyzed man she's taking care of.	2016	106	7.4	113322	56.23	51	57
59	59	Their Finest	A former secretary, newly appointed as a scriptwriter for propaganda films, joins the cast and crew of a major production while the Blitz rages around them.	2016	117	7.0	3739	3.18	76	58
60	60	Sully	The story of Chesley Sullenberger, an American pilot who became a hero after landing his damaged plane on the Hudson River in order to save the flight's passengers and crew.	2016	96	7.5	137608	125.07	74	59
61	61	Batman v Superman: Dawn of Justice	Fearing that the actions of Superman are left unchecked, Batman takes on the Man of Steel, while the world wrestles with what kind of a hero it really needs.	2016	151	6.7	472307	330.25	44	60
62	62	The Autopsy of Jane Doe	A father and son, both coroners, are pulled into a complex mystery while attempting to identify the body of a young woman, who was apparently harboring dark secrets.	2016	86	6.8	35870	\N	65	61
63	63	The Girl on the Train	A divorcee becomes entangled in a missing persons investigation that promises to send shockwaves throughout her life.	2016	112	6.5	102177	75.31	48	62
64	64	Fifty Shades of Grey	Literature student Anastasia Steele's life changes forever when she meets handsome, yet tormented, billionaire Christian Grey.	2015	125	4.1	244474	166.15	46	63
65	65	The Prestige	Two stage magicians engage in competitive one-upmanship in an attempt to create the ultimate stage illusion.	2006	130	8.5	913152	53.08	66	37
66	66	Kingsman: The Secret Service	A spy organization recruits an unrefined, but promising street kid into the agency's ultra-competitive training program, just as a global threat emerges from a twisted tech genius.	2014	129	7.7	440209	128.25	58	64
67	67	Patriots Day	The story of the 2013 Boston Marathon bombing and the aftermath, which includes the city-wide manhunt to find the terrorists responsible.	2016	133	7.4	39784	31.86	69	65
68	68	Mad Max: Fury Road	A woman rebels against a tyrannical ruler in postapocalyptic Australia in search for her home-land with the help of a group of female prisoners, a psychotic worshipper, and a drifter named Max.	2015	120	8.1	632842	153.63	90	66
69	69	Wakefield	A man's nervous breakdown causes him to leave his wife and live in his attic for several months.	2016	106	7.5	291	0.01	61	67
70	70	Deepwater Horizon	A dramatization of the April 2010 disaster, when the offshore drilling rig Deepwater Horizon exploded and created the worst oil spill in U.S. history.	2016	107	7.2	89849	61.28	68	65
71	71	The Promise	Set during the last days of the Ottoman Empire, The Promise follows a love triangle between Michael, a brilliant medical student, the beautiful and sophisticated Ana, and Chris - a renowned American journalist based in Paris.	2016	133	5.9	149791	\N	49	68
72	72	Allied	In 1942, a Canadian intelligence officer in North Africa encounters a female French Resistance fighter on a deadly mission behind enemy lines. When they reunite in London, their relationship is tested by the pressures of war.	2016	124	7.1	78079	40.07	60	69
73	73	A Monster Calls	A boy seeks the help of a tree monster to cope with his single mother's terminal illness.	2016	108	7.5	39134	3.73	76	70
74	74	Collateral Beauty	Retreating from life after a tragedy, a man questions the universe by writing to Love, Time and Death. Receiving unexpected answers, he begins to see how these things interlock and how even loss can reveal moments of meaning and beauty.	2016	97	6.8	43977	30.98	23	71
75	75	Zootopia	In a city of anthropomorphic animals, a rookie bunny cop and a cynical con artist fox must work together to uncover a conspiracy.	2016	108	8.1	296853	341.26	78	72
76	76	Pirates of the Caribbean: At World's End	Captain Barbossa, Will Turner and Elizabeth Swann must sail off the edge of the map, navigate treachery and betrayal, find Jack Sparrow, and make their final alliances for one last decisive battle.	2007	169	7.1	498821	309.40	50	73
77	77	The Avengers	Earth's mightiest heroes must come together and learn to fight as a team if they are to stop the mischievous Loki and his alien army from enslaving humanity.	2012	143	8.1	1045588	623.28	69	74
78	78	Inglourious Basterds	In Nazi-occupied France during World War II, a plan to assassinate Nazi leaders by a group of Jewish U.S. soldiers coincides with a theatre owner's vengeful plans for the same.	2009	153	8.3	959065	120.52	69	75
79	79	Pirates of the Caribbean: Dead Man's Chest	Jack Sparrow races to recover the heart of Davy Jones to avoid enslaving his soul to Jones' service, as other friends and foes seek the heart for their own agenda as well.	2006	151	7.3	552027	423.03	53	73
80	80	Ghostbusters	Following a ghost invasion of Manhattan, paranormal enthusiasts Erin Gilbert and Abby Yates, nuclear engineer Jillian Holtzmann, and subway worker Patty Tolan band together to stop the otherworldly threat.	2016	116	5.3	147717	128.34	60	76
81	81	Inception	A thief, who steals corporate secrets through use of dream-sharing technology, is given the inverse task of planting an idea into the mind of a CEO.	2010	148	8.8	1583625	292.57	74	37
82	82	Captain Fantastic	In the forests of the Pacific Northwest, a father devoted to raising his six kids with a rigorous physical and intellectual education is forced to leave his paradise and enter the world, challenging his idea of what it means to be a parent.	2016	118	7.9	105081	5.88	72	77
83	83	The Wolf of Wall Street	Based on the true story of Jordan Belfort, from his rise to a wealthy stock-broker living the high life to his fall involving crime, corruption and the federal government.	2013	180	8.2	865134	116.87	75	55
84	84	Gone Girl	With his wife's disappearance having become the focus of an intense media circus, a man sees the spotlight turned on him when it's suspected that he may not be innocent.	2014	149	8.1	636243	167.74	79	78
85	85	Furious Seven	Deckard Shaw seeks revenge against Dominic Toretto and his family for his comatose brother.	2015	137	7.2	301249	350.03	67	79
86	86	Jurassic World	A new theme park, built on the original site of Jurassic Park, creates a genetically modified hybrid dinosaur, which escapes containment and goes on a killing spree.	2015	124	7.0	455169	652.18	59	80
87	87	Live by Night	A group of Boston-bred gangsters set up shop in balmy Florida during the Prohibition era, facing off against the competition and the Ku Klux Klan.	2016	129	6.4	27869	10.38	49	81
88	88	Avatar	A paraplegic marine dispatched to the moon Pandora on a unique mission becomes torn between following his orders and protecting the world he feels is his home.	2009	162	7.8	935408	760.51	83	82
89	89	The Hateful Eight	In the dead of a Wyoming winter, a bounty hunter and his prisoner find shelter in a cabin currently inhabited by a collection of nefarious characters.	2015	187	7.8	341170	54.12	68	75
90	90	The Accountant	As a math savant uncooks the books for a new client, the Treasury Department closes in on his activities and the body count starts to rise.	2016	128	7.4	162122	86.20	51	83
91	91	Prisoners	When Keller Dover's daughter and her friend go missing, he takes matters into his own hands as the police pursue multiple leads and the pressure mounts.	2013	153	8.1	431185	60.96	74	20
92	92	Warcraft	As an Orc horde invades the planet Azeroth using a magic portal, a few human heroes and dissenting Orcs must attempt to stop the true evil behind this war.	2016	123	7.0	187547	47.17	32	84
93	93	The Help	An aspiring author during the civil rights movement of the 1960s decides to write a book detailing the African American maids' point of view on the white families for which they work, and the hardships they go through on a daily basis.	2011	146	8.1	342429	169.71	62	62
94	94	War Dogs	Based on the true story of two young men, David Packouz and Efraim Diveroli, who won a $300 million contract from the Pentagon to arm America's allies in Afghanistan.	2016	114	7.1	106463	43.02	57	85
95	95	Avengers: Age of Ultron	When Tony Stark and Bruce Banner try to jump-start a dormant peacekeeping program called Ultron, things go horribly wrong and it's up to Earth's mightiest heroes to stop the villainous Ultron from enacting his terrible plan.	2015	141	7.4	516895	458.99	66	74
96	96	The Nice Guys	In 1970s Los Angeles, a mismatched pair of private eyes investigate a missing girl and the mysterious death of a porn star.	2016	116	7.4	175067	36.25	70	86
97	97	Kimi no na wa	Two strangers find themselves linked in a bizarre way. When a connection forms, will distance be the only thing to keep them apart?	2016	106	8.6	34110	4.68	79	87
98	98	The Void	Shortly after delivering a patient to an understaffed hospital, a police officer experiences strange and violent occurrences seemingly linked to a group of mysterious hooded figures.	2016	90	5.8	9247	0.15	62	88
99	99	Personal Shopper	A personal shopper in Paris refuses to leave the city until she makes contact with her twin brother who previously died there. Her life becomes more complicated when a mysterious person contacts her via text message.	2016	105	6.3	10181	1.29	77	89
100	100	The Departed	An undercover cop and a mole in the police attempt to identify each other while infiltrating an Irish gang in South Boston.	2006	151	8.5	937414	132.37	85	55
101	101	Legend	Identical twin gangsters Ronald and Reginald Kray terrorize London during the 1960s.	2015	132	7.0	108836	1.87	55	90
102	102	Thor	The powerful but arrogant god Thor is cast out of Asgard to live amongst humans in Midgard (Earth), where he soon becomes one of their finest defenders.	2011	115	7.0	570814	181.02	57	91
103	103	The Martian	An astronaut becomes stranded on Mars after his team assume him dead, and must rely on his ingenuity to find a way to signal to Earth that he is alive.	2015	144	8.0	556097	228.43	80	2
104	104	Contratiempo	A young businessman faces a lawyer trying to prove his innocence by the assassination of his lover.	2016	106	7.9	7204	\N	\N	92
105	105	The Man from U.N.C.L.E.	In the early 1960s, CIA agent Napoleon Solo and KGB operative Illya Kuryakin participate in a joint mission against a mysterious criminal organization, which is working to proliferate nuclear weapons.	2015	116	7.3	202973	45.43	56	93
106	106	Hell or High Water	A divorced father and his ex-con older brother resort to a desperate scheme in order to save their family's ranch in West Texas.	2016	102	7.7	115546	26.86	88	94
107	107	The Comedian	A look at the life of an aging insult comic named Jack Burke.	2016	120	5.4	1954	1.66	40	95
108	108	The Legend of Tarzan	Tarzan, having acclimated to life in London, is called back to his former home in the jungle to investigate the activities at a mining encampment.	2016	110	6.3	117590	126.59	44	11
109	109	All We Had	A mother struggles to make a better life for her daughter.	2016	105	5.8	1004	\N	48	96
110	110	Ex Machina	A young programmer is selected to participate in a ground-breaking experiment in synthetic intelligence by evaluating the human qualities of a breath-taking humanoid A.I.	2014	108	7.7	339797	25.44	78	97
111	111	The Belko Experiment	In a twisted social experiment, 80 Americans are locked in their high-rise corporate office in Bogotá, Colombia and ordered by an unknown voice coming from the company's intercom system to participate in a deadly game of kill or be killed.	2016	89	6.3	3712	10.16	44	98
112	112	12 Years a Slave	In the antebellum United States, Solomon Northup, a free black man from upstate New York, is abducted and sold into slavery.	2013	134	8.1	486338	56.67	96	99
113	113	The Bad Batch	A dystopian love story in a Texas wasteland and set in a community of cannibals.	2016	118	6.1	512	\N	65	100
114	114	300	King Leonidas of Sparta and a force of 300 men fight the Persians at Thermopylae in 480 B.C.	2006	117	7.7	637104	210.59	52	60
115	115	Harry Potter and the Deathly Hallows: Part 2	Harry, Ron and Hermione search for Voldemort's remaining Horcruxes in their effort to destroy the Dark Lord as the final battle rages on at Hogwarts.	2011	130	8.1	590595	380.96	87	11
116	116	Office Christmas Party	When his uptight CEO sister threatens to shut down his branch, the branch manager throws an epic Christmas party in order to land a big client and save the day, but the party gets way out of hand...	2016	105	5.8	30761	54.73	42	101
117	117	The Neon Demon	When aspiring model Jesse moves to Los Angeles, her youth and vitality are devoured by a group of beauty-obsessed women who will take any means necessary to get what she has.	2016	118	6.2	50359	1.33	51	102
118	118	Dangal	Former wrestler Mahavir Singh Phogat and his two wrestler daughters struggle towards glory at the Commonwealth Games in the face of societal oppression.	2016	161	8.8	48969	11.15	\N	103
119	119	10 Cloverfield Lane	After getting in a car accident, a woman is held in a shelter with two men, who claim the outside world is affected by a widespread chemical attack.	2016	104	7.2	192968	71.90	76	104
120	120	Finding Dory	The friendly but forgetful blue tang fish, Dory, begins a search for her long-lost parents, and everyone learns a few things about the real meaning of family along the way.	2016	97	7.4	157026	486.29	77	105
121	121	Miss Peregrine's Home for Peculiar Children	When Jacob discovers clues to a mystery that stretches across time, he finds Miss Peregrine's Home for Peculiar Children. But the danger deepens after he gets to know the residents and learns about their special powers.	2016	127	6.7	101058	87.24	57	106
122	122	Divergent	In a world divided by factions based on virtues, Tris learns she's Divergent and won't fit in. When she discovers a plot to destroy Divergents, Tris and the mysterious Four must find out what makes Divergents dangerous before it's too late.	2014	139	6.7	362093	150.83	48	107
123	123	Mike and Dave Need Wedding Dates	Two hard-partying brothers place an online ad to find the perfect dates for their sister's Hawaiian wedding. Hoping for a wild getaway, the boys instead find themselves out-hustled by an uncontrollable duo.	2016	98	6.0	53183	46.01	51	108
124	124	Boyka: Undisputed IV	In the fourth installment of the fighting franchise, Boyka is shooting for the big leagues when an accidental death in the ring makes him question everything he stands for.	2016	86	7.4	10428	\N	\N	109
125	125	The Dark Knight Rises	Eight years after the Joker's reign of anarchy, the Dark Knight, with the help of the enigmatic Selina, is forced from his imposed exile to save Gotham City, now on the edge of total annihilation, from the brutal guerrilla terrorist Bane.	2012	164	8.5	1222645	448.13	78	37
126	126	The Jungle Book	After a threat from the tiger Shere Khan forces him to flee the jungle, a man-cub named Mowgli embarks on a journey of self discovery with the help of panther, Bagheera, and free spirited bear, Baloo.	2016	106	7.5	198243	364.00	77	110
127	127	Transformers: Age of Extinction	Autobots must escape sight from a bounty hunter who has taken control of the human serendipity: Unexpectedly, Optimus Prime and his remaining gang turn to a mechanic, his daughter, and her back street racing boyfriend for help.	2014	165	5.7	255483	245.43	32	111
128	128	Nerve	A high school senior finds herself immersed in an online game of truth or dare, where her every move starts to become manipulated by an anonymous community of "watchers."	2016	96	6.6	69651	38.56	58	112
129	129	Mamma Mia!	The story of a bride-to-be trying to find her real father told using hit songs by the popular '70s group ABBA.	2008	108	6.4	153481	143.70	51	113
130	130	The Revenant	A frontiersman on a fur trading expedition in the 1820s fights for survival after being mauled by a bear and left for dead by members of his own hunting team.	2015	156	8.0	499424	183.64	76	114
131	131	Fences	A working-class African-American father tries to raise his family in the 1950s, while coming to terms with the events of his life.	2016	139	7.3	50953	57.64	79	115
132	132	Into the Woods	A witch tasks a childless baker and his wife with procuring magical items from classic fairy tales to reverse the curse put on their family tree.	2014	125	6.0	109756	128.00	69	46
133	133	The Shallows	A mere 200 yards from shore, surfer Nancy is attacked by a great white shark, with her short journey to safety becoming the ultimate contest of wills.	2016	86	6.4	78328	55.12	59	116
134	134	Whiplash	A promising young drummer enrolls at a cut-throat music conservatory where his dreams of greatness are mentored by an instructor who will stop at nothing to realize a student's potential.	2014	107	8.5	477276	13.09	88	7
135	135	Furious 6	Hobbs has Dominic and Brian reassemble their crew to take down a team of mercenaries: Dominic unexpectedly gets convoluted also facing his presumed deceased girlfriend, Letty.	2013	130	7.1	318051	238.67	61	49
136	136	The Place Beyond the Pines	A motorcycle stunt rider turns to robbing banks as a way to provide for his lover and their newborn child, a decision that puts him on a collision course with an ambitious rookie cop navigating a department ruled by a corrupt detective.	2012	140	7.3	200090	21.38	68	117
137	137	No Country for Old Men	Violence and mayhem ensue after a hunter stumbles upon a drug deal gone wrong and more than two million dollars in cash near the Rio Grande.	2007	122	8.1	660286	74.27	91	118
138	138	The Great Gatsby	A writer and wall street trader, Nick, finds himself drawn to the past and lifestyle of his millionaire neighbor, Jay Gatsby.	2013	143	7.3	386102	144.81	55	119
139	139	Shutter Island	In 1954, a U.S. marshal investigates the disappearance of a murderess who escaped from a hospital for the criminally insane.	2010	138	8.1	855604	127.97	63	55
140	140	Brimstone	From the moment the new reverend climbs the pulpit, Liz knows she and her family are in great danger.	2016	148	7.1	13004	\N	44	120
141	141	Star Trek	The brash James T. Kirk tries to live up to his father's legacy with Mr. Spock keeping him in check as a vengeful Romulan from the future creates black holes to destroy the Federation one planet at a time.	2009	127	8.0	526324	257.70	82	51
142	142	Diary of a Wimpy Kid	The adventures of a teenager who is fresh out of elementary and transitions to middle school, where he has to learn the consequences and responsibility to survive the year.	2010	94	6.2	34184	64.00	56	121
143	143	The Big Short	Four denizens in the world of high-finance predict the credit and housing bubble collapse of the mid-2000s, and decide to take on the big banks for their greed and lack of foresight.	2015	130	7.8	246360	70.24	81	122
144	144	Room	A young boy is raised within the confines of a small shed.	2015	118	8.2	224132	14.68	86	123
145	145	Django Unchained	With the help of a German bounty hunter , a freed slave sets out to rescue his wife from a brutal Mississippi plantation owner.	2012	165	8.4	1039115	162.80	81	75
146	146	Ah-ga-ssi	A woman is hired as a handmaiden to a Japanese heiress, but secretly she is involved in a plot to defraud her.	2016	144	8.1	33418	2.01	84	124
147	147	The Edge of Seventeen	High-school life gets even more unbearable for Nadine when her best friend, Krista, starts dating her older brother.	2016	104	7.4	47694	14.26	77	125
148	148	Watchmen	In 1985 where former superheroes exist, the murder of a colleague sends active vigilante Rorschach into his own sprawling investigation, uncovering something that could completely change the course of history as we know it.	2009	162	7.6	410249	107.50	56	60
149	149	Superbad	Two co-dependent high school seniors are forced to deal with separation anxiety after their plan to stage a booze-soaked party goes awry.	2007	113	7.6	442082	121.46	76	126
150	150	Inferno	When Robert Langdon wakes up in an Italian hospital with amnesia, he teams up with Dr. Sienna Brooks, and together they must race across Europe against the clock to foil a deadly global plot.	2016	121	6.2	97623	34.26	42	127
151	151	The BFG	An orphan little girl befriends a benevolent giant who takes her to Giant Country, where they attempt to stop the man-eating giants that are invading the human world.	2016	117	6.4	50853	55.47	66	128
152	152	The Hunger Games	Katniss Everdeen voluntarily takes her younger sister's place in the Hunger Games: a televised competition in which two teenagers from each of the twelve Districts of Panem are chosen at random to fight to the death.	2012	142	7.2	735604	408.00	68	129
153	153	White Girl	Summer, New York City. A college girl falls hard for a guy she just met. After a night of partying goes wrong, she goes to wild extremes to get him back.	2016	88	5.8	4299	0.20	65	130
154	154	Sicario	An idealistic FBI agent is enlisted by a government task force to aid in the escalating war against drugs at the border area between the U.S. and Mexico.	2015	121	7.6	243230	46.88	82	20
155	155	Twin Peaks: The Missing Pieces	Twin Peaks before Twin Peaks (1990) and at the same time not always and entirely in the same place as Twin Peaks: Fire Walk with Me (1992). A feature film which presents deleted scenes from Twin Peaks: Fire Walk with Me (1992) assembled together for the first time in an untold portion of the story's prequel.	2014	91	8.1	1973	\N	\N	131
156	156	Aliens vs Predator - Requiem	Warring alien and predator races descend on a rural US town, where unsuspecting residents must band together for any chance of survival.	2007	94	4.7	97618	41.80	29	132
157	157	Pacific Rim	As a war between humankind and monstrous sea creatures wages on, a former pilot and a trainee are paired up to drive a seemingly obsolete special weapon in a desperate effort to save the world from the apocalypse.	2013	131	7.0	400519	101.79	64	133
158	158	Crazy, Stupid, Love.	A middle-aged husband's life changes dramatically when his wife asks him for a divorce. He seeks to rediscover his manhood with the help of a newfound friend, Jacob, learning to pick up girls at bars.	2011	118	7.4	396714	84.24	68	134
159	159	Scott Pilgrim vs. the World	Scott Pilgrim must defeat his new girlfriend's seven evil exes in order to win her heart.	2010	112	7.5	291457	31.49	69	135
160	160	Hot Fuzz	Exceptional London cop Nicholas Angel is involuntarily transferred to a quaint English village and paired with a witless new partner. While on the beat, Nicholas suspects a sinister conspiracy is afoot with the residents.	2007	121	7.9	373244	23.62	81	135
161	161	Mine	After a failed assassination attempt, a soldier finds himself stranded in the desert. Exposed to the elements, he must survive the dangers of the desert and battle the psychological and physical tolls of the treacherous conditions.	2016	106	6.0	5926	\N	40	136
162	162	Free Fire	Set in Boston in 1978, a meeting in a deserted warehouse between two gangs turns into a shootout and a game of survival.	2016	90	7.0	6946	1.80	63	137
163	163	X-Men: Days of Future Past	The X-Men send Wolverine to the past in a desperate effort to change history and prevent an event that results in doom for both humans and mutants.	2014	132	8.0	552298	233.91	74	33
164	164	Jack Reacher: Never Go Back	Jack Reacher must uncover the truth behind a major government conspiracy in order to clear his name. On the run as a fugitive from the law, Reacher uncovers a potential secret from his past that could change his life forever.	2016	118	6.1	78043	58.40	47	138
165	165	Casino Royale	Armed with a licence to kill, Secret Agent James Bond sets out on his first mission as 007 and must defeat a weapons dealer in a high stakes game of poker at Casino Royale, but things are not what they seem.	2006	144	8.0	495106	167.01	80	139
166	166	Twilight	A teenage girl risks everything when she falls in love with a vampire.	2008	122	5.2	361449	191.45	56	140
167	167	Now You See Me 2	The Four Horsemen resurface and are forcibly recruited by a tech genius to pull off their most impossible heist yet.	2016	129	6.5	156567	65.03	46	141
168	168	Woman in Gold	Maria Altmann, an octogenarian Jewish refugee, takes on the Austrian government to recover artwork she believes rightfully belongs to her family.	2015	109	7.3	39723	33.31	51	142
169	169	13 Hours	During an attack on a U.S. compound in Libya, a security team struggles to make sense out of the chaos.	2016	144	7.3	76935	52.82	48	111
170	170	Spectre	A cryptic message from Bond's past sends him on a trail to uncover a sinister organization. While M battles political forces to keep the secret service alive, Bond peels back the layers of deceit to reveal the terrible truth behind SPECTRE.	2015	148	6.8	308981	200.07	60	143
171	171	Nightcrawler	When Louis Bloom, a con man desperate for work, muscles into the world of L.A. crime journalism, he blurs the line between observer and participant to become the star of his own story.	2014	118	7.9	332476	32.28	76	144
172	172	Kubo and the Two Strings	A young boy named Kubo must locate a magical suit of armour worn by his late father in order to defeat a vengeful spirit from the past.	2016	101	7.9	72778	48.02	84	145
173	173	Beyond the Gates	Two estranged brothers reunite at their missing father's video store and find a VCR board game dubbed 'Beyond The Gates' that holds a connection to their father's disappearance.	2016	84	5.2	2127	\N	59	146
174	174	Her	A lonely writer develops an unlikely relationship with an operating system designed to meet his every need.	2013	126	8.0	390531	25.56	90	147
175	175	Frozen	When the newly crowned Queen Elsa accidentally uses her power to turn things into ice to curse her home in infinite winter, her sister, Anna, teams up with a mountain man, his playful reindeer, and a snowman to change the weather condition.	2013	102	7.5	451894	400.74	74	148
176	176	Tomorrowland	Bound by a shared destiny, a teen bursting with scientific curiosity and a former boy-genius inventor embark on a mission to unearth the secrets of a place somewhere in time and space that exists in their collective memory.	2015	130	6.5	143069	93.42	60	149
177	177	Dawn of the Planet of the Apes	A growing nation of genetically evolved apes led by Caesar is threatened by a band of human survivors of the devastating virus unleashed a decade earlier.	2014	130	7.6	337777	208.54	79	150
178	178	Tropic Thunder	Through a series of freak occurrences, a group of actors shooting a big-budget war movie are forced to become the soldiers they are portraying.	2008	107	7.0	321442	110.42	71	151
179	179	The Conjuring 2	Lorraine and Ed Warren travel to north London to help a single mother raising four children alone in a house plagued by a malicious spirit.	2016	134	7.4	137203	102.46	65	79
180	180	Ant-Man	Armed with a super-suit with the astonishing ability to shrink in scale but increase in strength, cat burglar Scott Lang must embrace his inner hero and help his mentor, Dr. Hank Pym, plan and pull off a heist that will save the world.	2015	117	7.3	368912	180.19	64	152
181	181	Bridget Jones's Baby	Bridget's focus on single life and her career is interrupted when she finds herself pregnant, but with one hitch ... she can only be fifty percent sure of the identity of her baby's father.	2016	118	6.7	43086	24.09	59	153
182	182	The VVitch: A New-England Folktale	A family in 1630s New England is torn apart by the forces of witchcraft, black magic and possession.	2015	92	6.8	101781	25.14	83	154
183	183	Cinderella	When her father unexpectedly passes away, young Ella finds herself at the mercy of her cruel stepmother and her scheming step-sisters. Never one to give up hope, Ella's fortunes begin to change after meeting a dashing stranger.	2015	105	7.0	117018	201.15	67	91
184	184	Realive	Marc (Tom Hughes) is diagnosed with a disease and is given one year left to live. Unable to accept his own end, he decides to freeze his body. Sixty years later, in the year 2084, he ... See full summary »	2016	112	5.9	1176	\N	\N	155
185	185	Forushande	While both participating in a production of "Death of a Salesman," a teacher's wife is assaulted in her new home, which leaves him determined to find the perpetrator over his wife's traumatized objections.	2016	124	8.0	22389	3.40	85	156
186	186	Love	Murphy is an American living in Paris who enters a highly sexually and emotionally charged relationship with the unstable Electra. Unaware of the effect it will have on their relationship, they invite their pretty neighbor into their bed.	2015	135	6.0	24003	\N	51	157
187	187	Billy Lynn's Long Halftime Walk	19-year-old Billy Lynn is brought home for a victory tour after a harrowing Iraq battle. Through flashbacks the film shows what really happened to his squad - contrasting the realities of war with America's perceptions.	2016	113	6.3	11944	1.72	53	158
188	188	Crimson Peak	In the aftermath of a family tragedy, an aspiring author is torn between love for her childhood friend and the temptation of a mysterious outsider. Trying to escape the ghosts of her past, she is swept away to a house that breathes, bleeds - and remembers.	2015	119	6.6	97454	31.06	66	133
189	189	Drive	A mysterious Hollywood stuntman and mechanic moonlights as a getaway driver and finds himself in trouble when he helps out his neighbor.	2011	100	7.8	461509	35.05	78	102
190	190	Trainwreck	Having thought that monogamy was never possible, a commitment-phobic career woman may have to face her fears when she meets a good guy.	2015	125	6.3	106364	110.01	75	159
191	191	The Light Between Oceans	A lighthouse keeper and his wife living off the coast of Western Australia raise a baby they rescue from a drifting rowing boat.	2016	133	7.2	27382	12.53	60	117
192	192	Below Her Mouth	An unexpected affair quickly escalates into a heart-stopping reality for two women whose passionate connection changes their lives forever.	2016	94	5.6	1445	\N	42	160
193	193	Spotlight	The true story of how the Boston Globe uncovered the massive scandal of child molestation and cover-up within the local Catholic Archdiocese, shaking the entire Catholic Church to its core.	2015	128	8.1	268282	44.99	93	161
194	194	Morgan	A corporate risk-management consultant must decide whether or not to terminate an artificially created humanoid being.	2016	92	5.8	22107	3.91	48	162
195	195	Warrior	The youngest son of an alcoholic former boxer returns home, where he's trained by his father for competition in a mixed martial arts tournament - a path that puts the fighter on a collision course with his estranged, older brother.	2011	140	8.2	355722	13.65	71	83
196	196	Captain America: The First Avenger	Steve Rogers, a rejected military soldier transforms into Captain America after taking a dose of a "Super-Soldier serum". But being Captain America comes at a price as he attempts to take down a war monger and a terrorist organization.	2011	124	6.9	547368	176.64	66	163
197	197	Hacker	With the help of his new friends Alex Danyliuk turns to a life of crime and identity theft.	2016	95	6.3	3799	\N	\N	164
198	198	Into the Wild	After graduating from Emory University, top student and athlete Christopher McCandless abandons his possessions, gives his entire $24,000 savings account to charity and hitchhikes to Alaska to live in the wilderness. Along the way, Christopher encounters a series of characters that shape his life.	2007	148	8.1	459304	18.35	73	50
199	199	The Imitation Game	During World War II, mathematician Alan Turing tries to crack the enigma code with help from fellow mathematicians.	2014	114	8.1	532353	91.12	73	10
200	200	Central Intelligence	After he reconnects with an awkward pal from high school through Facebook, a mild-mannered accountant is lured into the world of international espionage.	2016	107	6.3	97082	127.38	52	165
201	201	Edge of Tomorrow	A soldier fighting aliens gets to relive the same day over and over again, the day restarting every time he dies.	2014	113	7.9	471815	100.19	71	166
202	202	A Cure for Wellness	An ambitious young executive is sent to retrieve his company's CEO from an idyllic but mysterious "wellness center" at a remote location in the Swiss Alps, but soon suspects that the spa's treatments are not what they seem.	2016	146	6.5	12193	8.10	47	73
203	203	Snowden	The NSA's illegal surveillance techniques are leaked to the public by one of the agency's employees, Edward Snowden, in the form of thousands of classified documents distributed to the press.	2016	134	7.3	79855	21.48	58	167
204	204	Iron Man	After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil.	2008	126	7.9	737719	318.30	79	110
205	205	Allegiant	After the earth-shattering revelations of Insurgent, Tris must escape with Four beyond the wall that encircles Chicago, to finally discover the shocking truth of the world around them.	2016	120	5.7	70504	66.00	33	168
206	206	X: First Class	In 1962, the United States government enlists the help of Mutants with superhuman abilities to stop a malicious dictator who is determined to start World War III.	2011	132	7.8	550011	146.41	65	64
207	207	Raw (II)	When a young vegetarian undergoes a carnivorous hazing ritual at vet school, an unbidden taste for meat begins to grow in her.	2016	99	7.5	5435	0.51	81	169
208	208	Paterson	A quiet observation of the triumphs and defeats of daily life, along with the poetry evident in its smallest details.	2016	118	7.5	26089	2.14	90	170
209	209	Bridesmaids	Competition between the maid of honor and a bridesmaid, over who is the bride's best friend, threatens to upend the life of an out-of-work pastry chef.	2011	125	6.8	227912	169.08	75	76
210	210	The Girl with All the Gifts	A scientist and a teacher living in a dystopian future embark on a journey of survival with a special young girl named Melanie.	2016	111	6.7	23713	\N	67	171
211	211	San Andreas	In the aftermath of a massive earthquake in California, a rescue-chopper pilot makes a dangerous journey with his ex-wife across the state in order to rescue his daughter.	2015	114	6.1	161396	155.18	43	172
212	212	Spring Breakers	Four college girls hold up a restaurant in order to fund their spring break vacation. While partying, drinking, and taking drugs, they are arrested, only to be bailed out by a drug and arms dealer.	2012	94	5.3	114290	14.12	63	173
213	213	Transformers	An ancient struggle between two Cybertronian races, the heroic Autobots and the evil Decepticons, comes to Earth, with a clue to the ultimate power held by a teenager.	2007	144	7.1	531112	318.76	61	111
214	214	Old Boy	Obsessed with vengeance, a man sets out to find out why he was kidnapped and locked into solitary confinement for twenty years without reason.	2013	104	5.8	54679	\N	49	174
215	215	Thor: The Dark World	When Dr. Jane Foster gets cursed with a powerful entity known as the Aether, Thor is heralded of the cosmic event known as the Convergence and the genocidal Dark Elves.	2013	112	7.0	443584	206.36	54	175
216	216	Gods of Egypt	Mortal hero Bek teams with the god Horus in an alliance against Set, the merciless god of darkness, who has usurped Egypt's throne, plunging the once peaceful and prosperous empire into chaos and conflict.	2016	126	5.5	73568	31.14	25	176
217	217	Captain America: The Winter Soldier	As Steve Rogers struggles to embrace his role in the modern world, he teams up with a fellow Avenger and S.H.I.E.L.D agent, Black Widow, to battle a new threat from history: an assassin known as the Winter Soldier.	2014	136	7.8	542362	259.75	70	36
218	218	Monster Trucks	A young man working at a small town junkyard discovers and befriends a creature which feeds on oil being sought by a fracking company.	2016	104	5.7	7044	33.04	41	177
219	219	A Dark Song	A determined young woman and a damaged occultist risk their lives and souls to perform a dangerous ritual that will grant them what they want.	2016	100	6.1	1703	\N	67	178
220	220	Kick-Ass	Dave Lizewski is an unnoticed high school student and comic book fan who one day decides to become a superhero, even though he has no powers, training or meaningful reason to do so.	2010	117	7.7	456749	48.04	66	64
221	221	Hardcore Henry	Henry is resurrected from death with no memory, and he must save his wife from a telekinetic warlord with a plan to bio-engineer soldiers.	2015	96	6.7	61098	9.24	51	179
222	222	Cars	A hot-shot race-car named Lightning McQueen gets waylaid in Radiator Springs, where he finds the true meaning of friendship and family.	2006	117	7.1	283445	244.05	73	180
223	223	It Follows	A young woman is followed by an unknown supernatural force after a sexual encounter.	2014	100	6.9	136399	14.67	83	181
224	224	The Girl with the Dragon Tattoo	Journalist Mikael Blomkvist is aided in his search for a woman who has been missing for forty years by Lisbeth Salander, a young computer hacker.	2011	158	7.8	348551	102.52	71	78
225	225	We're the Millers	A veteran pot dealer creates a fake family as part of his plan to move a huge shipment of weed into the U.S. from Mexico.	2013	110	7.0	334867	150.37	44	165
226	226	American Honey	A teenage girl with nothing to lose joins a traveling magazine sales crew, and gets caught up in a whirlwind of hard partying, law bending and young love as she criss-crosses the Midwest with a band of misfits.	2016	163	7.0	19660	0.66	79	182
227	227	The Lobster	In a dystopian near future, single people, according to the laws of The City, are taken to The Hotel, where they are obliged to find a romantic partner in forty-five days or are transformed into beasts and sent off into The Woods.	2015	119	7.1	121313	8.70	82	183
228	228	Predators	A group of elite warriors parachute into an unfamiliar jungle and are hunted by members of a merciless alien race.	2010	107	6.4	179450	52.00	51	184
229	229	Maleficent	A vengeful fairy is driven to curse an infant princess, only to discover that the child may be the one person who can restore peace to their troubled land.	2014	97	7.0	268877	241.41	56	185
230	230	Rupture	A single mom tries to break free from a mysterious organization that has abducted her.	2016	102	4.8	2382	\N	35	186
231	231	Pan's Labyrinth	In the falangist Spain of 1944, the bookish young stepdaughter of a sadistic army officer escapes into an eerie but captivating fantasy world.	2006	118	8.2	498879	37.62	98	133
232	232	A Kind of Murder	In 1960s New York, Walter Stackhouse is a successful architect married to the beautiful Clara who leads a seemingly perfect life. But his fascination with an unsolved murder leads him into a spiral of chaos as he is forced to play cat-and-mouse with a clever killer and an overambitious detective, while at the same time lusting after another woman.	2016	95	5.2	3305	0.00	50	187
233	233	Apocalypto	As the Mayan kingdom faces its decline, the rulers insist the key to prosperity is to build more temples and offer human sacrifices. Jaguar Paw, a young man captured for sacrifice, flees to avoid his fate.	2006	139	7.8	247926	50.86	68	17
234	234	Mission: Impossible - Rogue Nation	Ethan and team take on their most impossible mission yet, eradicating the Syndicate - an International rogue organization as highly skilled as they are, committed to destroying the IMF.	2015	131	7.4	257472	195.00	75	188
235	235	The Huntsman: Winter's War	Eric and fellow warrior Sara, raised as members of ice Queen Freya's army, try to conceal their forbidden love as they fight to survive the wicked intentions of both Freya and her sister Ravenna.	2016	114	6.1	66766	47.95	35	189
236	236	The Perks of Being a Wallflower	An introvert freshman is taken under the wings of two seniors who welcome him to the real world.	2012	102	8.0	377336	17.74	67	190
237	237	Jackie	Following the assassination of President John F. Kennedy, First Lady Jacqueline Kennedy fights through grief and trauma to regain her faith, console her children, and define her husband's historic legacy.	2016	100	6.8	41446	13.96	81	191
238	238	The Disappointments Room	A mother and her young son release unimaginable horrors from the attic of their rural dream home.	2016	85	3.9	4895	2.41	31	192
239	239	The Grand Budapest Hotel	The adventures of Gustave H, a legendary concierge at a famous hotel from the fictional Republic of Zubrowka between the first and second World Wars, and Zero Moustafa, the lobby boy who becomes his most trusted friend.	2014	99	8.1	530881	59.07	88	193
240	240	The Host	When an unseen enemy threatens mankind by taking over their bodies and erasing their memories, Melanie will risk everything to protect the people she cares most about, proving that love can conquer all in a dangerous new world.	2013	125	5.9	96852	26.62	35	194
241	241	Fury	A grizzled tank commander makes tough decisions as he and his crew fight their way across Germany in April, 1945.	2014	134	7.6	332234	85.71	64	5
242	242	Inside Out	After young Riley is uprooted from her Midwest life and moved to San Francisco, her emotions - Joy, Fear, Anger, Disgust and Sadness - conflict on how best to navigate a new city, house, and school.	2015	95	8.2	416689	356.45	94	195
243	243	Rock Dog	When a radio falls from the sky into the hands of a wide-eyed Tibetan Mastiff, he leaves home to fulfill his dream of becoming a musician, setting into motion a series of completely unexpected events.	2016	90	5.8	1109	9.40	48	196
244	244	Terminator Genisys	When John Connor, leader of the human resistance, sends Sgt. Kyle Reese back to 1984 to protect Sarah Connor and safeguard the future, an unexpected turn of events creates a fractured timeline.	2015	126	6.5	205365	89.73	38	175
245	245	Percy Jackson & the Olympians: The Lightning Thief	A teenager discovers he's the descendant of a Greek god and sets out on an adventure to settle an on-going battle between the gods.	2010	118	5.9	148949	88.76	47	197
246	246	Les Misérables	In 19th-century France, Jean Valjean, who for decades has been hunted by the ruthless policeman Javert after breaking parole, agrees to care for a factory worker's daughter. The decision changes their lives forever.	2012	158	7.6	257426	148.78	63	198
247	247	Children of Men	In 2027, in a chaotic world in which women have become somehow infertile, a former activist agrees to help transport a miraculously pregnant woman to a sanctuary at sea.	2006	109	7.9	382910	35.29	84	199
248	248	20th Century Women	The story of a teenage boy, his mother, and two other women who help raise him among the love and freedom of Southern California of 1979.	2016	119	7.4	14708	5.66	83	200
249	249	Spy	A desk-bound CIA analyst volunteers to go undercover to infiltrate the world of a deadly arms dealer, and prevent diabolical global disaster.	2015	119	7.1	188017	110.82	75	76
250	250	The Intouchables	After he becomes a quadriplegic from a paragliding accident, an aristocrat hires a young man from the projects to be his caregiver.	2011	112	8.6	557965	13.18	57	201
251	251	Bonjour Anne	Anne is at a crossroads in her life. Long married to a successful, driven but inattentive movie producer, she unexpectedly finds herself taking a car trip from Cannes to Paris with a ... See full summary »	2016	92	4.9	178	0.32	50	202
252	252	Kynodontas	Three teenagers live isolated, without leaving their house, because their over-protective parents say they can only leave when their dogtooth falls out.	2009	94	7.3	50946	0.11	73	183
253	253	Straight Outta Compton	The group NWA emerges from the mean streets of Compton in Los Angeles, California, in the mid-1980s and revolutionizes Hip Hop culture with their music and tales about life in the hood.	2015	147	7.9	139831	161.03	72	203
254	254	The Amazing Spider-Man 2	When New York is put under siege by Oscorp, it is up to Spider-Man to save the city he swore to protect as well as his loved ones.	2014	142	6.7	342183	202.85	53	204
255	255	The Conjuring	Paranormal investigators Ed and Lorraine Warren work to help a family terrorized by a dark presence in their farmhouse.	2013	112	7.5	330305	137.39	68	79
256	256	The Hangover	Three buddies wake up from a bachelor party in Las Vegas, with no memory of the previous night and the bachelor missing. They make their way around the city in order to find their friend before his wedding.	2009	100	7.8	611563	277.31	73	85
257	257	Battleship	A fleet of ships is forced to do battle with an armada of unknown origins in order to discover and thwart their destructive goals.	2012	131	5.8	210349	65.17	41	65
258	258	Rise of the Planet of the Apes	A substance, designed to help the brain repair itself, gives rise to a super-intelligent chimp who leads an ape uprising.	2011	105	7.6	422290	176.74	68	205
259	259	Lights Out	Rebecca must unlock the terror behind her little brother's experiences that once tested her sanity, bringing her face to face with an entity attached to their mother.	2016	81	6.4	69823	67.24	58	206
260	260	Norman: The Moderate Rise and Tragic Fall of a New York Fixer	Norman Oppenheimer is a small time operator who befriends a young politician at a low point in his life. Three years later, when the politician becomes an influential world leader, Norman's life dramatically changes for better and worse.	2016	118	7.1	664	2.27	76	207
261	261	Birdman or (The Unexpected Virtue of Ignorance)	Illustrated upon the progress of his latest Broadway play, a former popular actor's struggle to cope with his current life as a wasted actor is shown.	2014	119	7.8	440299	42.34	88	114
262	262	Black Swan	A committed dancer wins the lead role in a production of Tchaikovsky's "Swan Lake" only to find herself struggling to maintain her sanity.	2010	108	8.0	581518	106.95	79	208
263	263	Dear White People	The lives of four black students at an Ivy League college.	2014	108	6.2	21715	4.40	79	209
264	264	Nymphomaniac: Vol. I	A self-diagnosed nymphomaniac recounts her erotic experiences to the man who saved her after a beating.	2013	117	7.0	90556	0.79	64	210
265	265	Teenage Mutant Ninja Turtles: Out of the Shadows	After facing Shredder, who has joined forces with mad scientist Baxter Stockman and henchmen Bebop and Rocksteady to take over the world, the Turtles must confront an even greater nemesis: the notorious Krang.	2016	112	6.0	59312	0.54	40	211
266	266	Knock Knock	A devoted father helps two stranded young women who knock on his door, but his kind gesture turns into a dangerous seduction and a deadly game of cat and mouse.	2015	99	4.9	53441	0.03	53	212
267	267	Dirty Grandpa	Right before his wedding, an uptight guy is tricked into driving his grandfather, a lecherous former Army Lieutenant-Colonel, to Florida for spring break.	2016	102	6.0	75137	35.54	18	213
268	268	Cloud Atlas	An exploration of how the actions of individual lives impact one another in the past, present and future, as one soul is shaped from a killer into a hero, and an act of kindness ripples across centuries to inspire a revolution.	2012	172	7.5	298651	27.10	55	214
269	269	X-Men Origins: Wolverine	A look at Wolverine's early life, in particular his time with the government squad Team X and the impact it will have on his later years.	2009	107	6.7	388447	179.88	40	215
270	270	Satanic	Four friends on their way to Coachella stop off in Los Angeles to tour true-crime occult sites, only to encounter a mysterious young runaway who puts them on a terrifying path to ultimate horror.	2016	85	3.7	2384	\N	\N	216
271	271	Skyfall	Bond's loyalty to M is tested when her past comes back to haunt her. Whilst MI6 comes under attack, 007 must track down and destroy the threat, no matter how personal the cost.	2012	143	7.8	547386	304.36	81	143
272	272	The Hobbit: An Unexpected Journey	A reluctant hobbit, Bilbo Baggins, sets out to the Lonely Mountain with a spirited group of dwarves to reclaim their mountain home - and the gold within it - from the dragon Smaug.	2012	169	7.9	668651	303.00	58	217
273	273	21 Jump Street	A pair of underachieving cops are sent back to a local high school to blend in and bring down a synthetic drug ring.	2012	110	7.2	432046	138.45	69	218
274	274	Sing Street	A boy growing up in Dublin during the 1980s escapes his strained family life by starting a band to impress the mysterious girl he likes.	2016	106	8.0	52144	3.23	79	219
275	275	Ballerina	An orphan girl dreams of becoming a ballerina and flees her rural Brittany for Paris, where she passes for someone else and accedes to the position of pupil at the Grand Opera house.	2016	89	6.8	4729	\N	\N	220
276	276	Oblivion	A veteran assigned to extract Earth's remaining resources begins to question what he knows about his mission and himself.	2013	124	7.0	410125	89.02	54	221
277	277	22 Jump Street	After making their way through high school (twice), big changes are in store for officers Schmidt and Jenko when they go deep undercover at a local college.	2014	112	7.1	280110	191.62	71	218
278	278	Zodiac	In the late 1960s/early 1970s, a San Francisco cartoonist becomes an amateur detective obsessed with tracking down the Zodiac Killer, an unidentified individual who terrorizes Northern California with a killing spree.	2007	157	7.7	329683	33.05	78	78
279	279	Everybody Wants Some!!	In 1980, a group of college baseball players navigate their way through the freedoms and responsibilities of unsupervised adulthood.	2016	117	7.0	36312	3.37	83	222
280	280	Iron Man Three	When Tony Stark's world is torn apart by a formidable terrorist called the Mandarin, he starts an odyssey of rebuilding and retribution.	2013	130	7.2	591023	408.99	62	86
432	432	Zoolander 2	Derek and Hansel are lured into modeling again, in Rome, where they find themselves the target of a sinister conspiracy.	2016	102	4.7	48297	28.84	34	151
281	281	Now You See Me	An FBI agent and an Interpol detective track a team of illusionists who pull off bank heists during their performances and reward their audiences with the money.	2013	115	7.3	492324	117.70	50	223
282	282	Sherlock Holmes	Detective Sherlock Holmes and his stalwart partner Watson engage in a battle of wits and brawn with a nemesis whose plot is a threat to all of England.	2009	128	7.6	501769	209.02	57	93
283	283	Death Proof	Two separate sets of voluptuous women are stalked at different times by a scarred stuntman who uses his "death proof" cars to execute his murderous plans.	2007	113	7.1	220236	\N	\N	75
284	284	The Danish Girl	A fictitious love story loosely inspired by the lives of Danish artists Lili Elbe and Gerda Wegener. Lili and Gerda's marriage and work evolve as they navigate Lili's groundbreaking journey as a transgender pioneer.	2015	119	7.0	110773	12.71	66	198
285	285	Hercules	Having endured his legendary twelve labors, Hercules, the Greek demigod, has his life as a sword-for-hire tested when the King of Thrace and his daughter seek his aid in defeating a tyrannical warlord.	2014	98	6.0	122838	72.66	47	224
286	286	Sucker Punch	A young girl is institutionalized by her abusive stepfather, retreating to an alternative reality as a coping strategy, envisioning a plan to help her escape.	2011	110	6.1	204874	36.38	33	60
287	287	Keeping Up with the Joneses	A suburban couple becomes embroiled in an international espionage plot when they discover that their seemingly perfect new neighbors are government spies.	2016	105	5.8	30405	14.90	34	126
288	288	Jupiter Ascending	A young woman discovers her destiny as an heiress of intergalactic nobility and must fight to protect the inhabitants of Earth from an ancient and destructive industry.	2015	127	5.3	150121	47.38	40	225
289	289	Masterminds	A guard at an armored car company in the Southern U.S. organizes one of the biggest bank heists in American history. Based on the October 1997 Loomis Fargo robbery.	2016	95	5.8	26508	17.36	47	226
290	290	Iris	Iris, young wife of a businessman, disappears in Paris. Maybe a mechanic with many debts is involved in the strange affair. A really complicated job for the police.	2016	99	6.1	726	\N	\N	227
291	291	Busanhaeng	While a zombie virus breaks out in South Korea, passengers struggle to survive on the train from Seoul to Busan.	2016	118	7.5	58782	2.13	72	228
292	292	Pitch Perfect	Beca, a freshman at Barden University, is cajoled into joining The Bellas, her school's all-girls singing group. Injecting some much needed energy into their repertoire, The Bellas take on their male rivals in a campus competition.	2012	112	7.2	226631	65.00	66	229
293	293	Neighbors 2: Sorority Rising	When their new next-door neighbors turn out to be a sorority even more debaucherous than the fraternity previously living there, Mac and Kelly team with their former enemy, Teddy, to bring the girls down.	2016	92	5.7	76327	55.29	58	230
294	294	The Exception	A German soldier tries to determine if the Dutch resistance has planted a spy to infiltrate the home of Kaiser Wilhelm in Holland during the onset of World War II, but falls for a young Jewish Dutch woman during his investigation.	2016	107	7.7	96	\N	\N	231
295	295	Man of Steel	Clark Kent, one of the last of an extinguished race disguised as an unremarkable human, is forced to reveal his identity when Earth is invaded by an army of survivors who threaten to bring the planet to the brink of destruction.	2013	143	7.1	577010	291.02	55	60
296	296	The Choice	Travis and Gabby first meet as neighbors in a small coastal town and wind up in a relationship that is tested by life's most defining events.	2016	111	6.6	20514	18.71	26	232
297	297	Ice Age: Collision Course	Manny, Diego, and Sid join up with Buck to fend off a meteor strike that would destroy the world.	2016	94	5.7	34523	64.06	34	233
298	298	The Devil Wears Prada	A smart but sensible new graduate lands a job as an assistant to Miranda Priestly, the demanding editor-in-chief of a high fashion magazine.	2006	109	6.8	302268	124.73	62	71
299	299	The Infiltrator	A U.S. Customs official uncovers a money laundering scheme involving Colombian drug lord Pablo Escobar.	2016	127	7.1	43929	15.43	66	234
300	300	There Will Be Blood	A story of family, religion, hatred, oil and madness, focusing on a turn-of-the-century prospector in the early days of the business.	2007	158	8.1	400682	40.22	92	235
301	301	The Equalizer	A man believes he has put his mysterious past behind him and has dedicated himself to beginning a new, quiet life. But when he meets a young girl under the control of ultra-violent Russian gangsters, he can't stand idly by - he has to help her.	2014	132	7.2	249425	101.53	57	39
302	302	Lone Survivor	Marcus Luttrell and his team set out on a mission to capture or kill notorious Taliban leader Ahmad Shah, in late June 2005. Marcus and his team are left to fight for their lives in one of the most valiant efforts of modern warfare.	2013	121	7.5	218996	125.07	60	65
303	303	The Cabin in the Woods	Five friends go for a break at a remote cabin, where they get more than they bargained for, discovering the truth behind the cabin in the woods.	2012	95	7.0	295554	42.04	72	236
304	304	The House Bunny	After Playboy bunny Shelley is kicked out of the playboy mansion, she finds a job as the house mother for a sorority full of socially awkward girls.	2008	97	5.5	67033	48.24	55	237
305	305	She's Out of My League	An average Joe meets the perfect woman, but his lack of confidence and the influence of his friends and family begin to pick away at the relationship.	2010	104	6.4	105619	31.58	46	238
306	306	Inherent Vice	In 1970, drug-fueled Los Angeles private investigator Larry "Doc" Sportello investigates the disappearance of a former girlfriend.	2014	148	6.7	69509	8.09	81	235
307	307	Alice Through the Looking Glass	Alice returns to the whimsical world of Wonderland and travels back in time to help the Mad Hatter.	2016	113	6.2	57207	77.04	34	239
308	308	Vincent N Roxxy	A small town loner and a rebellious punk rocker unexpectedly fall in love as they are forced on the run and soon discover violence follows them everywhere.	2016	110	5.5	403	\N	\N	240
309	309	The Fast and the Furious: Tokyo Drift	A teenager becomes a major competitor in the world of drift racing after moving in with his father in Tokyo to avoid a jail sentence in America.	2006	104	6.0	193479	62.49	45	49
310	310	How to Be Single	A group of young adults navigate love and relationships in New York City.	2016	110	6.1	59886	46.81	51	241
311	311	The Blind Side	The story of Michael Oher, a homeless and traumatized boy who became an All American football player and first round NFL draft pick with the help of a caring woman and her family.	2009	129	7.7	237221	255.95	53	44
312	312	La vie d'Adèle	Adèle's life is changed when she meets Emma, a young woman with blue hair, who will allow her to discover desire and to assert herself as a woman and as an adult. In front of others, Adèle grows, seeks herself, loses herself, and ultimately finds herself through love and loss.	2013	180	7.8	103150	2.20	88	242
313	313	The Babadook	A single mother, plagued by the violent death of her husband, battles with her son's fear of a monster lurking in the house, but soon discovers a sinister presence all around her.	2014	93	6.8	132580	0.92	86	243
314	314	The Hobbit: The Battle of the Five Armies	Bilbo and Company are forced to engage in a war against an array of combatants and keep the Lonely Mountain from falling into the hands of a rising darkness.	2014	144	7.4	385598	255.11	59	217
315	315	Harry Potter and the Order of the Phoenix	With their warning about Lord Voldemort's return scoffed at, Harry and Dumbledore are targeted by the Wizard authorities as an authoritarian bureaucrat slowly seizes power at Hogwarts.	2007	138	7.5	385325	292.00	71	11
316	316	Snowpiercer	Set in a future where a failed climate-change experiment kills all life on the planet except for a lucky few who boarded the Snowpiercer, a train that travels around the globe, where a class system emerges.	2013	126	7.0	199048	4.56	84	244
317	317	The 5th Wave	Four waves of increasingly deadly alien attacks have left most of Earth decimated. Cassie is on the run, desperately trying to save her younger brother.	2016	112	5.2	73093	34.91	33	245
318	318	The Stakelander	When his home of New Eden is destroyed by a revitalized Brotherhood and its new Vamp leader, Martin finds himself alone in the badlands of America with only the distant memory of his mentor and legendary vampire hunter, Mister, to guide him.	2016	81	5.3	1263	\N	\N	246
319	319	The Visit	Two siblings become increasingly frightened by their grandparents' disturbing behavior while visiting them on vacation.	2015	94	6.2	81429	65.07	55	3
320	320	Fast Five	Dominic Toretto and his crew of street racers plan a massive heist to buy their freedom while in the sights of a powerful Brazilian drug lord and a dangerous federal agent.	2011	131	7.3	300803	209.81	66	49
321	321	Step Up	Tyler Gage receives the opportunity of a lifetime after vandalizing a performing arts school, gaining him the chance to earn a scholarship and dance with an up and coming dancer, Nora.	2006	104	6.5	95960	65.27	48	247
322	322	Lovesong	The relationship between two friends deepens during an impromptu road trip.	2016	84	6.4	616	0.01	74	248
323	323	RocknRolla	In London, a real-estate scam puts millions of pounds up for grabs, attracting some of the city's scrappiest tough guys and its more established underworld types, all of whom are looking to get rich quick. While the city's seasoned criminals vie for the cash, an unexpected player -- a drugged-out rock 'n' roller presumed to be dead but very much alive -- has a multi-million-dollar prize fall into... See full summary »	2008	114	7.3	203096	5.69	53	93
324	324	In Time	In a future where people stop aging at 25, but are engineered to live only one more year, having the means to buy your way out of the situation is a shot at immortal youth. Here, Will Salas finds himself accused of murder and on the run with a hostage - a connection that becomes an important part of the way against the system.	2011	109	6.7	319025	37.55	53	194
325	325	The Social Network	Harvard student Mark Zuckerberg creates the social networking site that would become known as Facebook, but is later sued by two brothers who claimed he stole their idea, and the co-founder who was later squeezed out of the business.	2010	120	7.7	510100	96.92	95	78
326	326	The Last Witch Hunter	The last witch hunter is all that stands between humanity and the combined forces of the most horrifying witches in history.	2015	106	6.0	71149	27.36	34	249
327	327	Victor Frankenstein	Told from Igor's perspective, we see the troubled young assistant's dark origins, his redemptive friendship with the young medical student Viktor Von Frankenstein, and become eyewitnesses to the emergence of how Frankenstein became the man - and the legend - we know today.	2015	110	6.0	37975	5.77	36	250
328	328	A Street Cat Named Bob	Based on the international best selling book. The true feel good story of how James Bowen, a busker and recovering drug addict, had his life transformed when he met a stray ginger cat.	2016	103	7.4	12643	0.04	54	251
329	329	Green Room	A punk rock band is forced to fight for survival after witnessing a murder at a neo-Nazi skinhead bar.	2015	95	7.0	62885	3.22	79	252
330	330	Blackhat	A furloughed convict and his American and Chinese partners hunt a high-level cybercrime network from Chicago to Los Angeles to Hong Kong to Jakarta.	2015	133	5.4	43085	7.10	51	253
331	331	Storks	Storks have moved on from delivering babies to packages. But when an order for a baby appears, the best delivery stork must scramble to fix the error by delivering the baby.	2016	87	6.9	34248	72.66	56	230
332	332	American Sniper	Navy S.E.A.L. sniper Chris Kyle's pinpoint accuracy saves countless lives on the battlefield and turns him into a legend. Back home to his wife and kids after four tours of duty, however, Chris finds that it is the war he can't leave behind.	2014	133	7.3	353305	350.12	72	59
333	333	Dallas Buyers Club	In 1985 Dallas, electrician and hustler Ron Woodroof works around the system to help AIDS patients get the medication they need after he is diagnosed with the disease.	2013	117	8.0	352801	27.30	84	254
334	334	Lincoln	As the War continues to rage, America's president struggles with continuing carnage on the battlefield as he fights with many inside his own cabinet on the decision to emancipate the slaves.	2012	150	7.4	207497	182.20	86	128
335	335	Rush	The merciless 1970s rivalry between Formula One rivals James Hunt and Niki Lauda.	2013	123	8.1	339722	26.90	75	127
336	336	Before I Wake	A young couple adopt an orphaned child whose dreams - and nightmares - manifest physically as he sleeps.	2016	97	6.1	18201	\N	\N	255
337	337	Silver Linings Playbook	After a stint in a mental institution, former teacher Pat Solitano moves back in with his parents and tries to reconcile with his ex-wife. Things get more challenging when Pat meets Tiffany, a mysterious girl with problems of her own.	2012	122	7.8	564364	132.09	81	256
338	338	Tracktown	A young, talented, and lonely long-distance runner twists her ankle as she prepares for the Olympic Trials and must do something she's never done before: take a day off.	2016	88	5.9	115	\N	64	257
339	339	The Fault in Our Stars	Two teenage cancer patients begin a life-affirming journey to visit a reclusive author in Amsterdam.	2014	126	7.8	271301	124.87	69	258
340	340	Blended	After a bad blind date, a man and woman find themselves stuck together at a resort for families, where their attraction grows as their respective kids benefit from the burgeoning relationship.	2014	117	6.5	93764	46.28	31	259
341	341	Fast & Furious	Brian O'Conner, back working for the FBI in Los Angeles, teams up with Dominic Toretto to bring down a heroin importer by infiltrating his operation.	2009	107	6.6	217464	155.02	46	49
342	342	Looper	In 2074, when the mob wants to get rid of someone, the target is sent into the past, where a hired gun awaits - someone like Joe - who one day learns the mob wants to 'close the loop' by sending back Joe's future self for assassination.	2012	119	7.4	452369	66.47	84	260
343	343	White House Down	While on a tour of the White House with his young daughter, a Capitol policeman springs into action to save his child and protect the president from a heavily armed group of paramilitary invaders.	2013	131	6.4	173320	73.10	52	25
344	344	Pete's Dragon	The adventures of an orphaned boy named Pete and his best friend Elliot, who just so happens to be a dragon.	2016	102	6.8	36322	76.20	71	261
345	345	Spider-Man 3	A strange black entity from another world bonds with Peter Parker and causes inner turmoil as he contends with new villains, temptations, and revenge.	2007	139	6.2	406219	336.53	59	262
346	346	The Three Musketeers	The hot-headed young D'Artagnan along with three former legendary but now down on their luck Musketeers must unite and defeat a beautiful double agent and her villainous employer from seizing the French throne and engulfing Europe in war.	2011	110	5.8	92329	20.32	35	35
347	347	Stardust	In a countryside town bordering on a magical land, a young man makes a promise to his beloved that he'll retrieve a fallen star by venturing into the magical realm.	2007	127	7.7	220664	38.35	66	64
348	348	American Hustle	A con man, Irving Rosenfeld, along with his seductive partner Sydney Prosser, is forced to work for a wild FBI agent, Richie DiMaso, who pushes them into a world of Jersey powerbrokers and mafia.	2013	138	7.3	379088	150.12	90	256
349	349	Jennifer's Body	A newly possessed high school cheerleader turns into a succubus who specializes in killing her male classmates. Can her best friend put an end to the horror?	2009	102	5.1	96617	16.20	47	263
350	350	Midnight in Paris	While on a trip to Paris with his fiancée's family, a nostalgic screenwriter finds himself mysteriously going back to the 1920s everyday at midnight.	2011	94	7.7	320323	56.82	81	264
351	351	Lady Macbeth	Set in 19th century rural England, young bride who has been sold into marriage to a middle-aged man discovers an unstoppable desire within herself as she enters into an affair with a work on her estate.	2016	89	7.3	1396	\N	83	265
352	352	Joy	Joy is the story of the title character, who rose to become founder and matriarch of a powerful family business dynasty.	2015	124	6.6	97679	56.44	56	256
353	353	The Dressmaker	A glamorous woman returns to her small town in rural Australia. With her sewing machine and haute couture style, she transforms the women and exacts sweet revenge on those who did her wrong.	2015	119	7.1	33352	2.02	47	266
354	354	Café Society	In the 1930s, a Bronx native moves to Hollywood and falls in love with a young woman who is seeing a married man.	2016	96	6.7	45579	11.08	64	264
355	355	Insurgent	Beatrice Prior must confront her inner demons and continue her fight against a powerful alliance which threatens to tear her society apart with the help from others on her side.	2015	119	6.3	171970	130.00	42	168
356	356	Seventh Son	When Mother Malkin, the queen of evil witches, escapes the pit she was imprisoned in by professional monster hunter Spook decades ago and kills his apprentice, he recruits young Tom, the seventh son of the seventh son, to help him.	2014	102	5.5	59958	17.18	30	267
357	357	Demain tout commence	Samuel parties hard in the Marseille area of France and is awoken one morning by a woman carrying a baby she claims is his. She drives off leaving him with a wailing infant; he gives chase ... See full summary »	2016	118	7.4	5496	\N	\N	268
358	358	The Theory of Everything	A look at the relationship between the famous physicist Stephen Hawking and his wife.	2014	123	7.7	299718	35.89	72	269
359	359	This Is the End	While attending a party at James Franco's house, Seth Rogen, Jay Baruchel and many other celebrities are faced with the Biblical Apocalypse.	2013	107	6.6	327838	101.47	67	270
360	360	About Time	At the age of 21, Tim discovers he can travel in time and change what happens and has happened in his own life. His decision to make his world a better place by getting a girlfriend turns out not to be as easy as you might think.	2013	123	7.8	221600	15.29	55	271
361	361	Step Brothers	Two aimless middle-aged losers still living at home are forced against their will to become roommates when their parents marry.	2008	98	6.9	223065	100.47	51	122
362	362	Clown	A loving father finds a clown suit for his son's birthday party, only to realize that it is not a suit at all.	2014	100	5.7	14248	0.05	42	272
363	363	Star Trek Into Darkness	After the crew of the Enterprise find an unstoppable force of terror from within their own organization, Captain Kirk leads a manhunt to a war-zone world to capture a one-man weapon of mass destruction.	2013	132	7.8	417663	228.76	72	51
364	364	Zombieland	A shy student trying to reach his family in Ohio, a gun-toting tough guy trying to find the last Twinkie, and a pair of sisters trying to get to an amusement park join forces to travel across a zombie-filled America.	2009	88	7.7	409403	75.59	73	273
365	365	Hail, Caesar!	A Hollywood fixer in the 1950s works to keep the studio's stars in line.	2016	106	6.3	89059	30.00	72	118
366	366	Slumdog Millionaire	A Mumbai teen reflects on his upbringing in the slums when he is accused of cheating on the Indian Version of "Who Wants to be a Millionaire?"	2008	120	8.0	677044	141.32	86	274
367	367	The Twilight Saga: Breaking Dawn - Part 2	After the birth of Renesmee, the Cullens gather other vampire clans in order to protect the child from a false allegation that puts the family in front of the Volturi.	2012	115	5.5	194329	292.30	52	275
368	368	American Wrestler: The Wizard	In 1980, a teenage boy escapes the unrest in Iran only to face more hostility in America, due to the hostage crisis. Determined to fit in, he joins the school's floundering wrestling team.	2016	117	6.9	286	\N	\N	276
369	369	The Amazing Spider-Man	After Peter Parker is bitten by a genetically altered spider, he gains newfound, spider-like powers and ventures out to solve the mystery of his parent's mysterious death.	2012	136	7.0	474320	262.03	66	204
370	370	Ben-Hur	Judah Ben-Hur, a prince falsely accused of treason by his adopted brother, an officer in the Roman army, returns to his homeland after years at sea to seek revenge, but finds redemption.	2016	123	5.7	28326	26.38	38	277
401	401	Minions	Minions Stuart, Kevin and Bob are recruited by Scarlet Overkill, a super-villain who, alongside her inventor husband Herb, hatches a plot to take over the world.	2015	91	6.4	159830	336.03	56	298
371	371	Sleight	A young street magician (Jacob Latimore) is left to care for his little sister after their parents passing, and turns to illegal activities to keep a roof over their heads. When he gets in ... See full summary »	2016	89	6.0	702	3.85	62	278
372	372	The Maze Runner	Thomas is deposited in a community of boys after his memory is erased, soon learning they're all trapped in a maze that will require him to join forces with fellow "runners" for a shot at escape.	2014	113	6.8	335531	102.41	57	279
373	373	Criminal	In a last-ditch effort to stop a diabolical plot, a dead CIA operative's memories, secrets, and skills are implanted into a death-row inmate in hopes that he will complete the operative's mission.	2016	113	6.3	38430	14.27	36	280
374	374	Wanted	A frustrated office worker learns that he is the son of a professional assassin, and that he shares his father's superhuman killing abilities.	2008	110	6.7	312495	134.57	64	277
375	375	Florence Foster Jenkins	The story of Florence Foster Jenkins, a New York heiress who dreamed of becoming an opera singer, despite having a terrible singing voice.	2016	111	6.9	31776	27.37	71	281
376	376	Collide	An American backpacker gets involved with a ring of drug smugglers as their driver, though he winds up on the run from his employers across Cologne high-speed Autobahn.	2016	99	5.7	7583	2.20	33	282
377	377	Black Mass	The true story of Whitey Bulger, the brother of a state senator and the most infamous violent criminal in the history of South Boston, who became an FBI informant to take down a Mafia family invading his turf.	2015	123	6.9	135706	62.56	68	283
378	378	Creed	The former World Heavyweight Champion Rocky Balboa serves as a trainer and mentor to Adonis Johnson, the son of his late friend and former rival Apollo Creed.	2015	133	7.6	175673	109.71	82	284
379	379	Swiss Army Man	A hopeless man stranded on a deserted island befriends a dead body and together they go on a surreal journey to get home.	2016	97	7.1	61812	4.21	64	285
380	380	The Expendables 3	Barney augments his team with new blood for a personal battle: to take down Conrad Stonebanks, the Expendables co-founder and notorious arms trader who is hell bent on wiping out Barney and every single one of his associates.	2014	126	6.1	137568	39.29	35	286
381	381	What We Do in the Shadows	A documentary team films the lives of a group of vampires for a few months. The vampires share a house in Wellington, New Zealand. Turns out vampires have their own domestic problems too.	2014	86	7.6	84016	3.33	76	287
382	382	Southpaw	Boxer Billy Hope turns to trainer Tick Wills to help him get his life back on track after losing his wife in a tragic accident and his daughter to child protection services.	2015	124	7.4	169083	52.42	57	39
383	383	Hush	A deaf writer who retreated into the woods to live a solitary life must fight for her life in silence when a masked killer appears at her window.	2016	81	6.6	45867	\N	67	255
384	384	Bridge of Spies	During the Cold War, an American lawyer is recruited to defend an arrested Soviet spy in court, and then help the CIA facilitate an exchange of the spy for the Soviet captured American U2 spy plane pilot, Francis Gary Powers.	2015	142	7.6	217938	72.31	81	128
385	385	The Lego Movie	An ordinary Lego construction worker, thought to be the prophesied 'Special', is recruited to join a quest to stop an evil tyrant from gluing the Lego universe into eternal stasis.	2014	100	7.8	266508	257.76	83	218
386	386	Everest	The story of New Zealand's Robert "Rob" Edwin Hall, who on May 10, 1996, together with Scott Fischer, teamed up on a joint expedition to ascend Mount Everest.	2015	121	7.1	154647	43.25	64	288
387	387	Pixels	When aliens misinterpret video feeds of classic arcade games as a declaration of war, they attack the Earth in the form of the video games.	2015	105	5.6	101092	78.75	27	197
388	388	Robin Hood	In 12th century England, Robin and his band of marauders confront corruption in a local village and lead an uprising against the crown that will forever alter the balance of world power.	2010	140	6.7	221117	105.22	53	2
389	389	The Wolverine	When Wolverine is summoned to Japan by an old acquaintance, he is embroiled in a conflict that forces him to confront his own demons.	2013	126	6.7	355362	132.55	60	289
390	390	John Carter	Transported to Barsoom, a Civil War vet discovers a barren planet seemingly inhabited by 12-foot tall barbarians. Finding himself prisoner of these creatures, he escapes, only to encounter Woola and a princess in desperate need of a savior.	2012	132	6.6	220667	73.06	51	105
391	391	Keanu	When an L.A. drug kingpin's kitten unexpectedly enters the life of two cousins, they will have to go through gangs, hitmen and drug dealers who claim him in order to get him back.	2016	100	6.3	31913	20.57	63	290
392	392	The Gunman	A sniper on a mercenary assassination team, kills the minister of mines of the Congo. Terrier's successful kill shot forces him into hiding. Returning to the Congo years later, he becomes the target of a hit squad himself.	2015	115	5.8	31194	10.64	39	291
393	393	Steve Jobs	Steve Jobs takes us behind the scenes of the digital revolution, to paint a portrait of the man at its epicenter. The story unfolds backstage at three iconic product launches, ending in 1998 with the unveiling of the iMac.	2015	122	7.2	116112	17.75	82	274
394	394	Whisky Galore	Scottish islanders try to plunder cases of whisky from a stranded ship.	2016	98	5.0	102	\N	43	292
395	395	Grown Ups 2	After moving his family back to his hometown to be with his friends and their kids, Lenny finds out that between old bullies, new bullies, schizo bus drivers, drunk cops on skis, and 400 costumed party crashers sometimes crazy follows you.	2013	101	5.4	114482	133.67	19	293
396	396	The Age of Adaline	A young woman, born at the turn of the 20th century, is rendered ageless after an accident. After many solitary years, she meets a man who complicates the eternal life she has settled into.	2015	112	7.2	112288	42.48	51	294
397	397	The Incredible Hulk	Bruce Banner, a scientist on the run from the U.S. Government, must find a cure for the monster he emerges whenever he loses his temper.	2008	112	6.8	342355	134.52	61	223
398	398	Couples Retreat	A comedy centered around four couples who settle into a tropical-island resort for a vacation. While one of the couples is there to work on the marriage, the others fail to realize that participation in the resort's therapy sessions is not optional.	2009	113	5.5	86417	109.18	23	295
399	399	Absolutely Anything	A group of eccentric aliens confer a human being with the power to do absolutely anything, as an experiment.	2015	85	6.0	26587	\N	31	296
400	400	Magic Mike	A male stripper teaches a younger performer how to party, pick up women, and make easy money.	2012	110	6.1	113686	113.71	72	297
402	402	The Black Room	PAUL and JENNIFER HEMDALE have just moved into their dream house. But their happy marriage is about to be put to the test as they slowly discover the secret behind the black room in the ... See full summary »	2016	91	3.9	240	\N	71	299
403	403	Bronson	A young man who was sentenced to seven years in prison for robbing a post office ends up spending three decades in solitary confinement. During this time, his own personality is supplanted by his alter-ego, Charles Bronson.	2008	92	7.1	93972	0.10	\N	102
404	404	Despicable Me	When a criminal mastermind uses a trio of orphan girls as pawns for a grand scheme, he finds their love is profoundly changing him for the better.	2010	95	7.7	410607	251.50	72	300
405	405	The Best of Me	A pair of former high school sweethearts reunite after many years when they return to visit their small hometown.	2014	118	6.7	49041	26.76	29	301
406	406	The Invitation	While attending a dinner party at his former home, a man thinks his ex-wife and her new husband have sinister intentions for their guests.	2015	100	6.7	40529	0.23	74	263
407	407	Zero Dark Thirty	A chronicle of the decade-long hunt for al-Qaeda terrorist leader Osama bin Laden after the September 2001 attacks, and his death at the hands of the Navy S.E.A.L.s Team 6 in May 2011.	2012	157	7.4	226661	95.72	95	302
408	408	Tangled	The magically long-haired Rapunzel has spent her entire life in a tower, but now that a runaway thief has stumbled upon her, she is about to discover the world for the first time, and who she really is.	2010	100	7.8	316459	200.81	71	303
409	409	The Hunger Games: Mockingjay - Part 2	As the war of Panem escalates to the destruction of other districts, Katniss Everdeen, the reluctant leader of the rebellion, must bring together an army against President Snow, while all she holds dear hangs in the balance.	2015	137	6.6	202380	281.67	65	304
410	410	Vacation	Rusty Griswold takes his own family on a road trip to "Walley World" in order to spice things up with his wife and reconnect with his sons.	2015	99	6.1	74589	58.88	34	305
411	411	Taken	A retired CIA agent travels across Europe and relies on his old skills to save his estranged daughter, who has been kidnapped while on a trip to Paris.	2008	93	7.8	502961	145.00	50	291
412	412	Pitch Perfect 2	After a humiliating command performance at The Kennedy Center, the Barden Bellas enter an international competition that no American group has ever won in order to regain their status and right to perform.	2015	115	6.5	108306	183.44	63	306
413	413	Monsters University	A look at the relationship between Mike and Sulley during their days at Monsters University -- when they weren't necessarily the best of friends.	2013	104	7.3	252119	268.49	65	307
414	414	Elle	A successful businesswoman gets caught up in a game of cat and mouse as she tracks down the unknown man who raped her.	2016	130	7.2	35417	\N	89	308
415	415	Mechanic: Resurrection	Arthur Bishop thought he had put his murderous past behind him, until his most formidable foe kidnaps the love of his life. Now he is forced to travel the globe to complete three impossible assassinations, and do what he does best: make them look like accidents.	2016	98	5.6	48161	21.20	38	309
416	416	Tusk	When podcaster Wallace Bryton goes missing in the backwoods of Manitoba while interviewing a mysterious seafarer named Howard Howe, his best friend Teddy and girlfriend Allison team with an ex-cop to look for him.	2014	102	5.4	34546	1.82	55	310
417	417	The Headhunter's Calling	A headhunter whose life revolves around closing deals in a a survival-of-the-fittest boiler room, battles his top rival for control of their job placement company -- his dream of owning the company clashing with the needs of his family.	2016	108	6.9	164	\N	85	311
418	418	Atonement	Fledgling writer Briony Tallis, as a thirteen-year-old, irrevocably changes the course of several lives when she accuses her older sister's lover of a crime he did not commit.	2007	123	7.8	202890	50.92	\N	312
419	419	Harry Potter and the Deathly Hallows: Part 1	As Harry races against time and evil to destroy the Horcruxes, he uncovers the existence of three most powerful objects in the wizarding world: the Deathly Hallows.	2010	146	7.7	357213	294.98	65	11
420	420	Shame	A man's carefully cultivated private life is disrupted when his sister arrives for an indefinite stay.	2011	101	7.2	155010	4.00	72	99
421	421	Hanna	A sixteen-year-old girl who was raised by her father to be the perfect assassin is dispatched on a mission across Europe, tracked by a ruthless intelligence agent and her operatives.	2011	111	6.8	164208	40.25	65	312
422	422	The Babysitters	A teenager turns her babysitting service into a call-girl service for married guys after fooling around with one of her customers.	2007	88	5.7	8914	0.04	35	313
423	423	Pride and Prejudice and Zombies	Five sisters in 19th century England must cope with the pressures to marry while protecting themselves from a growing population of zombies.	2016	108	5.8	35003	10.91	45	314
424	424	300: Rise of an Empire	Greek general Themistokles leads the charge against invading Persian forces led by mortal-turned-god Xerxes and Artemisia, vengeful commander of the Persian navy.	2014	102	6.2	237887	106.37	48	315
425	425	London Has Fallen	In London for the Prime Minister's funeral, Mike Banning discovers a plot to assassinate all the attending world leaders.	2016	99	5.9	100702	62.40	28	316
426	426	The Curious Case of Benjamin Button	Tells the story of Benjamin Button, a man who starts aging backwards with bizarre consequences.	2008	166	7.8	485075	127.49	70	78
427	427	Sin City: A Dame to Kill For	Some of Sin City's most hard-boiled citizens cross paths with a few of its more reviled inhabitants.	2014	102	6.5	122185	13.75	46	317
428	428	The Bourne Ultimatum	Jason Bourne dodges a ruthless CIA official and his agents from a new assassination program while searching for the origins of his life as a trained killer.	2007	115	8.1	525700	227.14	85	18
429	429	Srpski film	An aging porn star agrees to participate in an "art film" in order to make a clean break from the business, only to discover that he has been drafted into making a pedophilia and necrophilia themed snuff film.	2010	104	5.2	43648	\N	55	318
430	430	The Purge: Election Year	Former Police Sergeant Barnes becomes head of security for Senator Charlie Roan, a Presidential candidate targeted for death on Purge night due to her vow to eliminate the Purge.	2016	109	6.0	54216	79.00	\N	319
431	431	3 Idiots	Two friends are searching for their long lost companion. They revisit their college days and recall the memories of their friend who inspired them to think differently, even as the rest of the world called them "idiots".	2009	170	8.4	238789	6.52	67	320
433	433	World War Z	Former United Nations employee Gerry Lane traverses the world in a race against time to stop the Zombie pandemic that is toppling armies and governments, and threatening to destroy humanity itself.	2013	116	7.0	494819	202.35	63	321
434	434	Mission: Impossible - Ghost Protocol	The IMF is shut down when it's implicated in the bombing of the Kremlin, causing Ethan Hunt and his new team to go rogue to clear their organization's name.	2011	132	7.4	382459	209.36	73	149
435	435	Let Me Make You a Martyr	A cerebral revenge film about two adopted siblings who fall in love, and hatch a plan to kill their abusive father.	2016	102	6.4	223	\N	56	322
436	436	Filth	A corrupt, junkie cop with bipolar disorder attempts to manipulate his way through a promotion in order to win back his wife and daughter while also fighting his own borderline-fueled inner demons.	2013	97	7.1	81301	0.03	\N	323
437	437	The Longest Ride	The lives of a young couple intertwine with a much older man, as he reflects back on a past love.	2015	123	7.1	58421	37.43	33	324
438	438	The imposible	The story of a tourist family in Thailand caught in the destruction and chaotic aftermath of the 2004 Indian Ocean tsunami.	2012	114	7.6	156189	19.00	73	70
439	439	Kick-Ass 2	Following Kick-Ass' heroics, other citizens are inspired to become masked crusaders. But the Red Mist leads his own group of evil supervillains to kill Kick-Ass and destroy everything for which he stands.	2013	103	6.6	214825	28.75	41	325
440	440	Folk Hero & Funny Guy	A successful singer-songwriter hatches a plan to help his friend's struggling comedy career and broken love life by hiring him as his opening act on his solo tour.	2016	88	5.6	220	\N	63	326
441	441	Oz the Great and Powerful	A frustrated circus magician from Kansas is transported to a magical land called Oz, where he will have to fulfill a prophecy to become the king, and release the land from the Wicked Witches using his great (but fake) powers.	2013	130	6.3	181521	234.90	44	262
442	442	Brooklyn	An Irish immigrant lands in 1950s Brooklyn, where she quickly falls into a romance with a local. When her past catches up with her, however, she must choose between two countries and the lives that exist within.	2015	117	7.5	94977	38.32	87	327
443	443	Coraline	An adventurous girl finds another world that is a strangely idealized version of her frustrating home, but it has sinister secrets.	2009	100	7.7	156620	75.28	80	328
444	444	Blue Valentine	The relationship of a contemporary married couple, charting their evolution over a span of years by cross-cutting between time periods.	2010	112	7.4	151409	9.70	81	117
445	445	The Thinning	"The Thinning" takes place in a post-apocalyptic future where population control is dictated by a high-school aptitude test. When two students (Logan Paul and Peyton List) discover the test... See full summary »	2016	81	6.0	4531	\N	31	329
446	446	Silent Hill	A woman, Rose, goes in search for her adopted daughter within the confines of a strange, desolate town called Silent Hill.	2006	125	6.6	184152	46.98	\N	330
447	447	Dredd	In a violent, futuristic city where the police have the authority to act as judge, jury and executioner, a cop teams with a trainee to take down a gang that deals the reality-altering drug, SLO-MO.	2012	95	7.1	213764	13.40	59	331
448	448	Hunt for the Wilderpeople	A national manhunt is ordered for a rebellious kid and his foster uncle who go missing in the wild New Zealand bush.	2016	101	7.9	52331	5.20	81	332
449	449	Big Hero 6	The special bond that develops between plus-sized inflatable robot Baymax, and prodigy Hiro Hamada, who team up with a group of friends to form a band of high-tech heroes.	2014	102	7.8	309186	222.49	74	333
450	450	Carrie	A shy girl, outcasted by her peers and sheltered by her religious mother, unleashes telekinetic terror on her small town after being pushed too far at her senior prom.	2013	100	5.9	113272	35.27	53	334
451	451	Iron Man 2	With the world now aware of his identity as Iron Man, Tony Stark must contend with both his declining health and a vengeful mad man with ties to his father's legacy.	2010	124	7.0	556666	312.06	57	110
452	452	Demolition	A successful investment banker struggles after losing his wife in a tragic car crash. With the help of a customer service rep and her young son, he starts to rebuild, beginning with the demolition of the life he once knew.	2015	101	7.0	58720	1.82	49	254
453	453	Pandorum	A pair of crew members aboard a spaceship wake up with no knowledge of their mission or their identities.	2009	108	6.8	126656	10.33	28	335
454	454	Olympus Has Fallen	Disgraced Secret Service agent (and former presidential guard) Mike Banning finds himself trapped inside the White House in the wake of a terrorist attack; using his inside knowledge, Banning works with national security to rescue the President from his kidnappers.	2013	119	6.5	214994	98.90	41	39
455	455	I Am Number Four	Aliens and their Guardians are hiding on Earth from intergalactic bounty hunters. They can only be killed in numerical order, and Number Four is next on the list. This is his story.	2011	109	6.1	202682	55.09	36	192
456	456	Jagten	A teacher lives a lonely life, all the while struggling over his son's custody. His life slowly gets better as he finds love and receives good news from his son, but his new luck is about to be brutally shattered by an innocent little lie.	2012	115	8.3	192263	0.61	76	336
457	457	The Proposal	A pushy boss forces her young assistant to marry her in order to keep her visa status in the U.S. and avoid deportation to Canada.	2009	108	6.7	241709	163.95	48	247
458	458	Get Hard	When millionaire James King is jailed for fraud and bound for San Quentin, he turns to Darnell Lewis to prep him to go behind bars.	2015	100	6.0	95119	90.35	34	337
459	459	Just Go with It	On a weekend trip to Hawaii, a plastic surgeon convinces his loyal assistant to pose as his soon-to-be-divorced wife in order to cover up a careless lie he told to his much-younger girlfriend.	2011	117	6.4	182069	103.03	33	293
460	460	Revolutionary Road	A young couple living in a Connecticut suburb during the mid-1950s struggle to come to terms with their personal problems while trying to raise their two children.	2008	119	7.3	159736	22.88	69	143
461	461	The Town	As he plans his next job, a longtime thief tries to balance his feelings for a bank manager connected to one of his earlier heists, as well as the FBI agent looking to bring him and his crew down.	2010	125	7.6	294553	92.17	74	81
462	462	The Boy	An American nanny is shocked that her new English family's boy is actually a life-sized doll. After she violates a list of strict rules, disturbing events make her believe that the doll is really alive.	2016	97	6.0	51235	35.79	42	338
906	906	In Dubious Battle	An activist gets caught up in the labor movement for farm workers in California during the 1930s.	2016	110	6.2	1455	\N	43	586
463	463	Denial	Acclaimed writer and historian Deborah E. Lipstadt must battle for historical truth to prove the Holocaust actually occurred when David Irving, a renowned denier, sues her for libel.	2016	109	6.6	8229	4.07	63	339
464	464	Predestination	For his final assignment, a top temporal agent must pursue the one criminal that has eluded him throughout time. The chase turns into a unique, surprising and mind-bending exploration of love, fate, identity and time travel taboos.	2014	97	7.5	187760	\N	69	340
465	465	Goosebumps	A teenager teams up with the daughter of young adult horror author R. L. Stine after the writer's imaginary demons are set free on the town of Madison, Delaware.	2015	103	6.3	57602	80.02	60	341
466	466	Sherlock Holmes: A Game of Shadows	Sherlock Holmes and his sidekick Dr. Watson join forces to outwit and bring down their fiercest adversary, Professor Moriarty.	2011	129	7.5	357436	186.83	48	93
467	467	Salt	A CIA agent goes on the run after a defector accuses her of being a Russian spy.	2010	100	6.4	255813	118.31	65	342
468	468	Enemy	A man seeks out his exact look-alike after spotting him in a movie.	2013	91	6.9	111558	1.01	61	20
469	469	District 9	An extraterrestrial race forced to live in slum-like conditions on Earth suddenly finds a kindred spirit in a government agent who is exposed to their biotechnology.	2009	112	8.0	556794	115.65	81	343
470	470	The Other Guys	Two mismatched New York City detectives seize an opportunity to step up like the city's top cops whom they idolize -- only things don't quite go as planned.	2010	107	6.7	199900	119.22	64	122
471	471	American Gangster	In 1970s America, a detective works to bring down the drug empire of Frank Lucas, a heroin kingpin from Manhattan, who is smuggling the drug into the country from the Far East.	2007	157	7.8	337835	130.13	76	2
472	472	Marie Antoinette	The retelling of France's iconic but ill-fated queen, Marie Antoinette. From her betrothal and marriage to Louis XVI at 15 to her reign as queen at 19 and to the end of her reign as queen, and ultimately the fall of Versailles.	2006	123	6.4	83941	15.96	65	344
473	473	2012	A frustrated writer struggles to keep his family alive when a series of global catastrophes threatens to annihilate mankind.	2009	158	5.8	297984	166.11	49	25
474	474	Harry Potter and the Half-Blood Prince	As Harry Potter begins his sixth year at Hogwarts, he discovers an old book marked as "the property of the Half-Blood Prince" and begins to learn more about Lord Voldemort's dark past.	2009	153	7.5	351059	301.96	78	11
475	475	Argo	Acting under the cover of a Hollywood producer scouting a location for a science fiction film, a CIA agent launches a dangerous operation to rescue six Americans in Tehran during the U.S. hostage crisis in Iran in 1980.	2012	120	7.7	481274	136.02	86	81
476	476	Eddie the Eagle	The story of Eddie Edwards, the notoriously tenacious British underdog ski jumper who charmed the world at the 1988 Winter Olympics.	2016	106	7.4	56332	15.79	54	345
477	477	The Lives of Others	In 1984 East Berlin, an agent of the secret police, conducting surveillance on a writer and his lover, finds himself becoming increasingly absorbed by their lives.	2006	137	8.5	278103	11.28	89	346
478	478	Pet	A psychological thriller about a man who bumps into an old crush and subsequently becomes obsessed with her, leading him to hold her captive underneath the animal shelter where he works. ... See full summary »	2016	94	5.7	8404	\N	48	347
479	479	Paint It Black	A young woman attempts to deal with the death of her boyfriend while continuously confronted by his mentally unstable mother.	2016	96	8.3	61	\N	71	348
480	480	Macbeth	Macbeth, the Thane of Glamis, receives a prophecy from a trio of witches that one day he will become King of Scotland. Consumed by ambition and spurred to action by his wife, Macbeth murders his king and takes the throne for himself.	2015	113	6.7	41642	\N	71	30
481	481	Forgetting Sarah Marshall	Devastated Peter takes a Hawaiian vacation in order to deal with the recent break-up with his TV star girlfriend, Sarah. Little does he know, Sarah's traveling to the same resort as her ex - and she's bringing along her new boyfriend.	2008	111	7.2	226619	62.88	67	230
482	482	The Giver	In a seemingly perfect community, without war, pain, suffering, differences or choice, a young boy is chosen to learn from an elderly man about the true pain and pleasure of the "real" world.	2014	97	6.5	93799	45.09	47	342
483	483	Triple 9	A gang of criminals and corrupt cops plan the murder of a police officer in order to pull off their biggest heist yet across town.	2016	115	6.3	48400	12.63	52	349
484	484	Perfetti sconosciuti	Seven long-time friends get together for a dinner. When they decide to share with each other the content of every text message, email and phone call they receive, many secrets start to unveil and the equilibrium trembles.	2016	97	7.7	17584	\N	43	350
485	485	Angry Birds	Find out why the birds are so angry. When an island populated by happy, flightless birds is visited by mysterious green piggies, it's up to three unlikely outcasts - Red, Chuck and Bomb - to figure out what the pigs are up to.	2016	97	6.3	55781	107.51	\N	351
486	486	Moonrise Kingdom	A pair of young lovers flee their New England town, which causes a local search party to fan out to find them.	2012	94	7.8	254446	45.51	84	193
487	487	Hairspray	Pleasantly plump teenager Tracy Turnblad teaches 1962 Baltimore a thing or two about integration after landing a spot on a local TV dance show.	2007	117	6.7	102954	118.82	81	352
488	488	Safe Haven	A young woman with a mysterious past lands in Southport, North Carolina where her bond with a widower forces her to confront the dark secret that haunts her.	2013	115	6.7	84765	71.35	34	353
489	489	Focus	In the midst of veteran con man Nicky's latest scheme, a woman from his past - now an accomplished femme fatale - shows up and throws his plans for a loop.	2015	105	6.6	166489	53.85	56	134
490	490	Ratatouille	A rat who can cook makes an unusual alliance with a young kitchen worker at a famous restaurant.	2007	111	8.0	504039	206.44	96	149
491	491	Stake Land	Martin was a normal teenage boy before the country collapsed in an empty pit of economic and political disaster. A vampire epidemic has swept across what is left of the nation's abandoned ... See full summary »	2010	98	6.5	36091	0.02	66	354
492	492	The Book of Eli	A post-apocalyptic tale, in which a lone man fights his way across America in order to protect a sacred book that holds the secrets to saving humankind.	2010	118	6.9	241359	94.82	53	355
493	493	Cloverfield	A group of friends venture deep into the streets of New York on a rescue mission during a rampaging monster attack.	2008	85	7.0	313803	80.03	64	150
494	494	Point Break	A young FBI agent infiltrates an extraordinary team of extreme sports athletes he suspects of masterminding a string of unprecedented, sophisticated corporate heists.	2015	114	5.3	44553	28.77	34	356
495	495	Under the Skin	A mysterious young woman seduces lonely men in the evening hours in Scotland. However, events lead her to begin a process of self-discovery.	2013	108	6.3	94707	2.61	78	357
496	496	I Am Legend	Years after a plague kills most of humanity and transforms the rest into monsters, the sole survivor in New York City struggles valiantly to find a cure.	2007	101	7.2	565721	256.39	65	304
497	497	Men in Black 3	Agent J travels in time to M.I.B.'s early days in 1969 to stop an alien from assassinating his friend Agent K and changing history.	2012	106	6.8	278379	179.02	58	358
498	498	Super 8	During the summer of 1979, a group of friends witness a train crash and investigate subsequent unexplained events in their small town.	2011	112	7.1	298913	126.98	72	51
499	499	Law Abiding Citizen	A frustrated man decides to take justice into his own hands after a plea bargain sets one of his family's killers free. He targets not only the killer but also the district attorney and others involved in the deal.	2009	109	7.4	228339	73.34	34	203
500	500	Up	Seventy-eight year old Carl Fredricksen travels to Paradise Falls in his home equipped with balloons, inadvertently taking a young stowaway.	2009	96	8.3	722203	292.98	88	195
501	501	Maze Runner: The Scorch Trials	After having escaped the Maze, the Gladers now face a new set of challenges on the open roads of a desolate landscape filled with unimaginable obstacles.	2015	131	6.3	159364	81.69	43	279
502	502	Carol	An aspiring photographer develops an intimate relationship with an older woman in 1950s New York.	2015	118	7.2	77995	0.25	95	359
503	503	Imperium	A young FBI agent, eager to prove himself in the field, goes undercover as a white supremacist.	2016	109	6.5	27428	\N	68	360
504	504	Youth	A retired orchestra conductor is on holiday with his daughter and his film director best friend in the Alps when he receives an invitation from Queen Elizabeth II to perform for Prince Philip's birthday.	2015	124	7.3	52636	2.70	64	361
505	505	Mr. Nobody	A boy stands on a station platform as a train is about to leave. Should he go with his mother or stay with his father? Infinite possibilities arise from this decision. As long as he doesn't choose, anything is possible.	2009	141	7.9	166872	\N	63	362
506	506	City of Tiny Lights	In the teeming, multicultural metropolis of modern-day London, a seemingly straightforward missing-person case launches a down-at-heel private eye into a dangerous world of religious fanaticism and political intrigue.	2016	110	5.7	291	\N	54	331
507	507	Savages	Pot growers Ben and Chon face off against the Mexican drug cartel who kidnapped their shared girlfriend.	2012	131	6.5	107960	47.31	59	167
508	508	(500) Days of Summer	An offbeat romantic comedy about a woman who doesn't believe true love exists, and the young man who falls for her.	2009	95	7.7	398972	32.39	76	204
509	509	Movie 43	A series of interconnected short films follows a washed-up producer as he pitches insane story lines featuring some of the biggest stars in Hollywood.	2013	94	4.3	83625	8.83	18	306
510	510	Gravity	Two astronauts work together to survive after an accident which leaves them alone in space.	2013	91	7.8	622089	274.08	96	199
511	511	The Boy in the Striped Pyjamas	Set during WWII, a story seen through the innocent eyes of Bruno, the eight-year-old son of the commandant at a German concentration camp, whose forbidden friendship with a Jewish boy on the other side of the camp fence has startling and unexpected consequences.	2008	94	7.8	144614	9.03	55	363
512	512	Shooter	A marksman living in exile is coaxed back into action after learning of a plot to kill the President. Ultimately double-crossed and framed for the attempt, he goes on the run to find the real killer and the reason he was set up.	2007	124	7.2	267820	46.98	53	39
513	513	The Happening	A science teacher, his wife, and a young girl struggle to survive a plague that causes those infected to commit suicide.	2008	91	5.0	170897	64.51	34	3
514	514	Bone Tomahawk	Four men set out in the Wild West to rescue a group of captives from cannibalistic cave dwellers.	2015	132	7.1	47289	66.01	72	364
515	515	Magic Mike XXL	Three years after Mike bowed out of the stripper life at the top of his game, he and the remaining Kings of Tampa hit the road to Myrtle Beach to put on one last blow-out performance.	2015	115	5.7	42506	\N	60	365
516	516	Easy A	A clean-cut high school student relies on the school's rumor mill to advance her social and financial standing.	2010	92	7.1	294950	58.40	72	366
517	517	Exodus: Gods and Kings	The defiant leader Moses rises up against the Egyptian Pharaoh Ramses, setting 600,000 slaves on a monumental journey of escape from Egypt and its terrifying cycle of deadly plagues.	2014	150	6.0	137299	65.01	52	2
518	518	Chappie	In the near future, crime is patrolled by a mechanized police force. When one police droid, Chappie, is stolen and given new programming, he becomes the first robot with the ability to think and feel for himself.	2015	120	6.9	188769	31.57	41	343
519	519	The Hobbit: The Desolation of Smaug	The dwarves, along with Bilbo Baggins and Gandalf the Grey, continue their quest to reclaim Erebor, their homeland, from Smaug. Bilbo Baggins is in possession of a mysterious and magical ring.	2013	161	7.9	513744	258.36	66	217
520	520	Half of a Yellow Sun	Sisters Olanna and Kainene return home to 1960s Nigeria, where they soon diverge on different paths. As civil war breaks out, political events loom larger than their differences as they join the fight to establish an independent republic.	2013	111	6.2	1356	0.05	51	367
521	521	Anthropoid	Based on the extraordinary true story of Operation Anthropoid, the WWII mission to assassinate SS General Reinhard Heydrich, the main architect behind the Final Solution and the Reich's third in command after Hitler and Himmler.	2016	120	7.2	24100	2.96	59	368
522	522	The Counselor	A lawyer finds himself in over his head when he gets involved in drug trafficking.	2013	117	5.3	84927	16.97	48	2
523	523	Viking	Kievan Rus, late 10th century. After the death of his father, the young Viking prince Vladimir of Novgorod is forced into exile across the frozen sea.	2016	133	4.7	1830	23.05	57	369
524	524	Whiskey Tango Foxtrot	A journalist recounts her wartime coverage in Afghanistan.	2016	112	6.6	36156	\N	\N	134
525	525	Trust	A teenage girl is targeted by an online sexual predator.	2010	106	7.0	36043	0.06	60	370
526	526	Birth of the Dragon	Young, up-and-coming martial artist, Bruce Lee, challenges legendary kung fu master Wong Jack Man to a no-holds-barred fight in Northern California.	2016	103	3.9	552	93.05	61	371
527	527	Elysium	In the year 2154, the very wealthy live on a man-made space station while the rest of the population resides on a ruined Earth. A man takes on a mission that could bring equality to the polarized worlds.	2013	109	6.6	358932	\N	\N	343
528	528	The Green Inferno	A group of student activists travels to the Amazon to save the rain forest and soon discover that they are not alone, and that no good deed goes unpunished.	2013	100	5.4	26461	7.19	38	212
529	529	Godzilla	The world is beset by the appearance of monstrous creatures, but one of them may be the only one who can save humanity.	2014	123	6.4	318058	200.66	62	13
530	530	The Bourne Legacy	An expansion of the universe from Robert Ludlum's novels, centered on a new hero whose stakes have been triggered by the events of the previous three films.	2012	135	6.7	245374	113.17	61	372
531	531	A Good Year	A British investment broker inherits his uncle's chateau and vineyard in Provence, where he spent much of his childhood. He discovers a new laid-back lifestyle as he tries to renovate the estate to be sold.	2006	117	6.9	74674	7.46	47	2
532	532	Friend Request	When a college student unfriends a mysterious girl online, she finds herself fighting a demonic presence that wants to make her lonely by killing her closest friends.	2016	92	5.4	12758	64.03	59	373
533	533	Deja Vu	After a ferry is bombed in New Orleans, an A.T.F. agent joins a unique investigation using experimental surveillance technology to find the bomber, but soon finds himself becoming obsessed with one of the victims.	2006	126	7.0	253858	\N	\N	374
534	534	Lucy	A woman, accidentally caught in a dark deal, turns the tables on her captors and transforms into a merciless warrior evolved beyond human logic.	2014	89	6.4	352698	126.55	61	375
535	535	A Quiet Passion	The story of American poet Emily Dickinson from her early days as a young schoolgirl to her later years as a reclusive, unrecognized artist.	2016	125	7.2	1024	1.08	77	376
536	536	Need for Speed	Fresh from prison, a street racer who was framed by a wealthy business associate joins a cross country race with revenge in mind. His ex-partner, learning of the plan, places a massive bounty on his head as the race begins.	2014	132	6.5	143389	43.57	39	377
537	537	Jack Reacher	A homicide investigator digs deeper into a case involving a trained military sniper who shot five random victims.	2012	130	7.0	250811	58.68	50	188
538	538	The Do-Over	Two down-on-their-luck guys decide to fake their own deaths and start over with new identities, only to find the people they're pretending to be are in even deeper trouble.	2016	108	5.7	24761	0.54	22	378
539	539	True Crimes	A murder investigation of a slain business man turns to clues found in an author's book about an eerily similar crime. Based on the 2008 article "True Crimes - A postmodern murder mystery" by David Grann.	2016	92	7.3	198	\N	43	379
540	540	American Pastoral	An All-American college star and his beauty queen wife watch their seemingly perfect life fall apart as their daughter joins the turmoil of '60s America.	2016	108	6.1	7115	\N	\N	380
541	541	The Ghost Writer	A ghostwriter hired to complete the memoirs of a former British prime minister uncovers secrets that put his own life in jeopardy.	2010	128	7.2	137964	15.52	77	381
542	542	Limitless	With the help of a mysterious pill that enables the user to access 100 percent of his brain abilities, a struggling writer becomes a financial wizard, but it also puts him in a new world with lots of dangers.	2011	105	7.4	444417	79.24	59	107
543	543	Spectral	A sci-fi/thriller story centered on a special-ops team that is dispatched to fight supernatural beings.	2016	107	6.3	27042	\N	39	382
544	544	P.S. I Love You	A young widow discovers that her late husband has left her 10 messages intended to help ease her pain and start a new life.	2007	126	7.1	177247	53.68	\N	383
545	545	Zipper	A successful family man with a blossoming political career loses all sense of morality when he becomes addicted to using an escort agency.	2015	103	5.7	4912	\N	39	384
546	546	Midnight Special	A father and son go on the run, pursued by the government and a cult drawn to the child's special powers.	2016	112	6.7	54787	3.71	76	385
547	547	Don't Think Twice	When a member of a popular New York City improv troupe gets a huge break, the rest of the group - all best friends - start to realize that not everyone is going to make it after all.	2016	92	6.8	10485	4.42	83	386
548	548	Alice in Wonderland	Nineteen-year-old Alice returns to the magical world from her childhood adventure, where she reunites with her old friends and learns of her true destiny: to end the Red Queen's reign of terror.	2010	108	6.5	324898	334.19	53	106
549	549	Chuck	A drama inspired by the life of heavyweight boxer Chuck Wepner.	2016	98	6.8	391	0.11	68	387
550	550	I, Daniel Blake	After having suffered a heart-attack, a 59-year-old carpenter must fight the bureaucratic forces of the system in order to receive Employment and Support Allowance.	2016	100	7.9	22941	\N	77	388
551	551	The Break-Up	In a bid to keep their luxurious condo from their significant other, a couple's break-up proceeds to get uglier and nastier by the moment.	2006	106	5.8	106381	118.68	45	152
552	552	Loving	The story of Richard and Mildred Loving, a couple whose arrest for interracial marriage in 1960s Virginia began a legal battle that would end with the Supreme Court's historic 1967 decision.	2016	123	7.1	17141	7.70	79	385
553	553	Fantastic Four	Four young outsiders teleport to an alternate and dangerous universe which alters their physical form in shocking ways. The four must learn to harness their new abilities and work together to save Earth from a former friend turned enemy.	2015	100	4.3	121847	56.11	27	389
554	554	The Survivalist	In a time of starvation, a survivalist lives off a small plot of land hidden deep in forest. When two women seeking food and shelter discover his farm, he finds his existence threatened.	2015	104	6.3	9187	\N	80	390
555	555	Colonia	A young woman's desperate search for her abducted boyfriend that draws her into the infamous Colonia Dignidad, a sect nobody has ever escaped from.	2015	106	7.1	30074	\N	33	391
556	556	The Boy Next Door	A woman, separated from her unfaithful husband, falls for a younger man who has moved in next door, but their torrid affair soon takes a dangerous turn.	2015	91	4.6	30180	35.39	30	392
557	557	The Gift	A young married couple's lives are thrown into a harrowing tailspin when an acquaintance from the husband's past brings mysterious gifts and a horrifying secret to light after more than 20 years.	2015	108	7.1	96688	43.77	77	393
589	589	Sunshine	A team of international astronauts are sent on a dangerous mission to reignite the dying Sun with a nuclear fission bomb in 2057.	2007	107	7.3	199860	3.68	64	274
558	558	Dracula Untold	As his kingdom is being threatened by the Turks, young prince Vlad Tepes must become a monster feared by his own people in order to obtain the power needed to protect his own family, and the families of his kingdom.	2014	92	6.3	148504	55.94	40	394
559	559	In the Heart of the Sea	A recounting of a New England whaling ship's sinking by a giant whale in 1820, an experience that later inspired the great novel Moby-Dick.	2015	122	6.9	90372	24.99	47	127
560	560	Idiocracy	Private Joe Bauers, the definition of "average American", is selected by the Pentagon to be the guinea pig for a top-secret hibernation program. Forgotten, he awakes five centuries in the future. He discovers a society so incredibly dumbed down that he's easily the most intelligent person alive.	2006	84	6.6	115355	0.44	66	395
561	561	The Expendables	A CIA operative hires a team of mercenaries to eliminate a Latin dictator and a renegade CIA agent.	2010	103	6.5	283282	102.98	45	396
562	562	Evil Dead	Five friends head to a remote cabin, where the discovery of a Book of the Dead leads them to unwittingly summon up demons living in the nearby woods.	2013	91	6.5	133113	54.24	57	56
563	563	Sinister	Washed-up true-crime writer Ellison Oswalt finds a box of super 8 home movies that suggest the murder he is currently researching is the work of a serial killer whose work dates back to the 1960s.	2012	110	6.8	171169	48.06	53	38
564	564	Wreck-It Ralph	A video game villain wants to be a hero and sets out to fulfill his dream, but his quest brings havoc to the whole arcade where he lives.	2012	101	7.8	290559	189.41	72	397
565	565	Snow White and the Huntsman	In a twist to the fairy tale, the Huntsman ordered to take Snow White into the woods to be killed winds up becoming her protector and mentor in a quest to vanquish the Evil Queen.	2012	127	6.1	239772	155.11	57	398
566	566	Pan	12-year-old orphan Peter is spirited away to the magical world of Neverland, where he finds both fun and danger, and ultimately discovers his destiny -- to become the hero who will be forever known as Peter Pan.	2015	111	5.8	47804	34.96	36	312
567	567	Transformers: Dark of the Moon	The Autobots learn of a Cybertronian spacecraft hidden on the moon, and race against the Decepticons to reach it and to learn its secrets.	2011	154	6.3	338369	352.36	42	111
568	568	Juno	Faced with an unplanned pregnancy, an offbeat young woman makes an unusual decision regarding her unborn child.	2007	96	7.5	432461	143.49	81	399
569	569	A Hologram for the King	A failed American sales rep looks to recoup his losses by traveling to Saudi Arabia and selling his company's product to a wealthy monarch.	2016	98	6.1	26521	4.20	58	214
570	570	Money Monster	Financial TV host Lee Gates and his producer Patty are put in an extreme situation when an irate investor takes over their studio.	2016	98	6.5	68654	41.01	55	400
571	571	The Other Woman	After discovering her boyfriend is married, Carly soon meets the wife he's been betraying. And when yet another love affair is discovered, all three women team up to plot revenge on the three-timing S.O.B.	2014	109	6.0	110825	83.91	39	401
572	572	Enchanted	A young maiden in a land called Andalasia, who is prepared to be wed, is sent away to New York City by an evil queen, where she falls in love with a lawyer.	2007	107	7.1	150353	127.71	75	402
573	573	The Intern	70-year-old widower Ben Whittaker has discovered that retirement isn't all it's cracked up to be. Seizing an opportunity to get back in the game, he becomes a senior intern at an online fashion site, founded and run by Jules Ostin.	2015	121	7.1	159582	75.27	51	403
574	574	Little Miss Sunshine	A family determined to get their young daughter into the finals of a beauty pageant take a cross-country trip in their VW bus.	2006	101	7.8	374044	59.89	80	404
575	575	Bleed for This	The inspirational story of World Champion Boxer Vinny Pazienza who, after a near fatal car crash which left him not knowing if he'd ever walk again, made one of sport's most incredible comebacks.	2016	117	6.8	11900	4.85	62	405
576	576	Clash of the Titans	Perseus demigod, son of Zeus, battles the minions of the underworld to stop them from conquering heaven and earth.	2010	106	5.8	238206	163.19	39	223
577	577	The Finest Hours	The Coast Guard makes a daring rescue attempt off the coast of Cape Cod after a pair of oil tankers are destroyed during a blizzard in 1952.	2016	117	6.8	44425	27.55	58	406
578	578	Tron	The son of a virtual world designer goes looking for his father and ends up inside the digital world that his father designed. He meets his father's corrupted creation and a unique ally who was born inside the digital world.	2010	125	6.8	273959	172.05	49	221
579	579	The Hunger Games: Catching Fire	Katniss Everdeen and Peeta Mellark become targets of the Capitol after their victory in the 74th Hunger Games sparks a rebellion in the Districts of Panem.	2013	146	7.6	525646	424.65	76	304
580	580	All Good Things	Mr. David Marks was suspected but never tried for killing his wife Katie who disappeared in 1982, but the truth is eventually revealed.	2010	101	6.3	44158	0.58	57	407
581	581	Kickboxer: Vengeance	A kick boxer is out to avenge his brother.	2016	90	4.9	6809	131.56	37	408
582	582	The Last Airbender	Follows the adventures of Aang, a young successor to a long line of Avatars, who must master all four elements and stop the Fire Nation from enslaving the Water Tribes and the Earth Kingdom.	2010	103	4.2	125129	\N	20	3
583	583	Sex Tape	A married couple wake up to discover that the sex tape they made the evening before has gone missing, leading to a frantic search for its whereabouts.	2014	94	5.1	89885	38.54	36	409
584	584	What to Expect When You're Expecting	Follows the lives of five interconnected couples as they experience the thrills and surprises of having a baby, and realize that no matter what you plan for, life does not always deliver what is expected.	2012	110	5.7	60059	41.10	41	410
585	585	Moneyball	Oakland A's general manager Billy Beane's successful attempt to assemble a baseball team on a lean budget by employing computer-generated analysis to acquire new players.	2011	133	7.6	297395	75.61	87	411
586	586	Ghost Rider	Stunt motorcyclist Johnny Blaze gives up his soul to become a hellblazing vigilante, to fight against power hungry Blackheart, the son of the devil himself.	2007	114	5.2	190673	115.80	35	412
587	587	Unbroken	After a near-fatal plane crash in WWII, Olympian Louis Zamperini spends a harrowing 47 days in a raft with two fellow crewmen before he's caught by the Japanese navy and sent to a prisoner-of-war camp.	2014	137	7.2	114006	115.60	59	413
588	588	Immortals	Theseus is a mortal man chosen by Zeus to lead the fight against the ruthless King Hyperion, who is on a rampage across Greece to obtain a weapon that can destroy humanity.	2011	110	6.0	142900	83.50	46	414
590	590	Brave	Determined to make her own path in life, Princess Merida defies a custom that brings chaos to her kingdom. Granted one wish, Merida must rely on her bravery and her archery skills to undo a beastly curse.	2012	93	7.2	293941	237.28	69	415
591	591	Män som hatar kvinnor	A journalist is aided in his search for a woman who has been missing -- or dead -- for forty years by a young female hacker.	2009	152	7.8	182074	10.10	76	416
592	592	Adoration	A pair of childhood friends and neighbors fall for each other's sons.	2013	112	6.2	25208	0.32	37	417
593	593	The Drop	Bob Saginowski finds himself at the center of a robbery gone awry and entwined in an investigation that digs deep into the neighborhood's past where friends, families, and foes all work together to make a living - no matter the cost.	2014	106	7.1	116118	10.72	69	418
594	594	She's the Man	When her brother decides to ditch for a couple weeks, Viola heads over to his elite boarding school, disguised as him, and proceeds to fall for one of his soccer teammates, and soon learns she's not the only one with romantic troubles.	2006	105	6.4	122864	2.34	45	419
595	595	Daddy's Home	Brad Whitaker is a radio host trying to get his stepchildren to love him and call him Dad. But his plans turn upside down when their biological father, Dusty Mayron, returns.	2015	96	6.1	68306	150.32	42	420
596	596	Let Me In	A bullied young boy befriends a young female vampire who lives in secrecy with her guardian.	2010	116	7.2	97141	12.13	79	150
597	597	Never Back Down	A frustrated and conflicted teenager arrives at a new high school to discover an underground fight club and meet a classmate who begins to coerce him into fighting.	2008	110	6.6	84083	24.85	39	325
598	598	Grimsby	A new assignment forces a top spy to team up with his football hooligan brother.	2016	83	6.2	63408	6.86	44	223
599	599	Moon	Astronaut Sam Bell has a quintessentially personal encounter toward the end of his three-year stint on the Moon, where he, working alongside his computer, GERTY, sends back to Earth parcels of a resource that has helped diminish our planet's power problems.	2009	97	7.9	277123	5.01	67	84
600	600	Megamind	The supervillain Megamind finally defeats his nemesis, the superhero Metro Man. But without a hero, he loses all purpose and must find new meaning to his life.	2010	95	7.3	183926	148.34	63	421
601	601	Gangster Squad	It's 1949 Los Angeles, the city is run by gangsters and a malicious mobster, Mickey Cohen. Determined to end the corruption, John O'Mara assembles a team of cops, ready to take down the ruthless leader and restore peace to the city.	2013	113	6.7	181432	46.00	40	273
602	602	Blood Father	An ex-con reunites with his estranged wayward 17-year old daughter to protect her from drug dealers who are trying to kill her.	2016	88	6.4	40357	93.95	66	422
603	603	He's Just Not That Into You	The Baltimore-set movie of interconnecting story arcs deals with the challenges of reading or misreading human behavior.	2009	129	6.4	137684	\N	47	423
604	604	Kung Fu Panda 3	Continuing his "legendary adventures of awesomeness", Po must face two hugely epic, but different threats: one supernatural and the other a little closer to his home.	2016	95	7.2	89791	143.52	66	424
605	605	The Rise of the Krays	Two brothers unleash a psychotic reign of terror on their journey to build an empire of unprecedented power in the British Mafia.	2015	110	5.1	1630	6.53	90	425
606	606	Handsome Devil	Ned and Conor are forced to share a bedroom at their boarding school. The loner and the star athlete at this rugby-mad school form an unlikely friendship until it's tested by the authorities.	2016	95	7.4	338	\N	\N	426
607	607	Winter's Bone	An unflinching Ozark Mountain girl hacks through dangerous social terrain as she hunts down her drug-dealing father while trying to keep her family intact.	2010	100	7.2	116435	\N	\N	427
608	608	Horrible Bosses	Three friends conspire to murder their awful bosses when they realize they are standing in the way of their happiness.	2011	98	6.9	368556	117.53	57	428
609	609	Mommy	A widowed single mother, raising her violent son alone, finds new hope when a mysterious neighbor inserts herself into their household.	2014	139	8.1	33560	3.49	74	429
610	610	Hellboy II: The Golden Army	The mythical world starts a rebellion against humanity in order to rule the Earth, so Hellboy and his team must save the world from the rebellious creatures.	2008	120	7.0	216932	75.75	78	133
611	611	Beautiful Creatures	Ethan longs to escape his small Southern town. He meets a mysterious new girl, Lena. Together, they uncover dark secrets about their respective families, their history and their town.	2013	124	6.2	71822	19.45	52	383
612	612	Toni Erdmann	A practical joking father tries to reconnect with his hard working daughter by creating an outrageous alter ego and posing as her CEO's life coach.	2016	162	7.6	24387	1.48	93	430
613	613	The Lovely Bones	Centers on a young girl who has been murdered and watches over her family - and her killer - from purgatory. She must weigh her desire for vengeance against her desire for her family to heal.	2009	135	6.7	130702	43.98	42	217
614	614	The Assassination of Jesse James by the Coward Robert Ford	Robert Ford, who's idolized Jesse James since childhood, tries hard to join the reforming gang of the Missouri outlaw, but gradually becomes resentful of the bandit leader.	2007	160	7.5	143564	3.90	68	431
615	615	Don Jon	A New Jersey guy dedicated to his family, friends, and church, develops unrealistic expectations from watching porn and works to find happiness and intimacy with his potential true love.	2013	90	6.6	199973	24.48	66	432
616	616	Bastille Day	A young con artist and an unruly CIA agent embark on an anti-terrorist mission in France.	2016	92	6.3	21089	0.04	48	433
617	617	2307: Winter's Dream	In 2307, a future soldier is sent on a mission to hunt down the leader of the humanoid rebellion.	2016	101	4.0	277	20.76	53	434
618	618	Free State of Jones	A disillusioned Confederate army deserter returns to Mississippi and leads a militia of fellow deserters, runaway slaves, and women in an uprising against the corrupt local Confederate government.	2016	139	6.9	29895	\N	\N	129
619	619	Mr. Right	A girl falls for the "perfect" guy, who happens to have a very fatal flaw: he's a hitman on the run from the crime cartels who employ him.	2015	95	6.3	30053	0.03	52	435
620	620	The Secret Life of Walter Mitty	When his job along with that of his co-worker are threatened, Walter takes action in the real world embarking on a global journey that turns into an adventure more extraordinary than anything he could have ever imagined.	2013	114	7.3	249877	58.23	54	151
653	653	Insidious	A family looks to prevent evil spirits from trapping their comatose child in a realm called The Further.	2010	103	6.8	219916	53.99	52	79
621	621	Dope	Life changes for Malcolm, a geek who's surviving life in a tough neighborhood, after a chance invitation to an underground party leads him and his friends into a Los Angeles adventure.	2015	103	7.3	66400	17.47	72	436
622	622	Underworld Awakening	When human forces discover the existence of the Vampire and Lycan clans, a war to eradicate both species commences. The vampire warrior Selene leads the battle against humankind.	2012	88	6.4	127157	62.32	39	437
623	623	Antichrist	A grieving couple retreat to their cabin in the woods, hoping to repair their broken hearts and troubled marriage. But nature takes its course and things go from bad to worse.	2009	108	6.6	94069	0.40	49	210
624	624	Friday the 13th	A group of young adults discover a boarded up Camp Crystal Lake, where they soon encounter Jason Voorhees and his deadly intentions.	2009	97	5.6	78631	65.00	34	438
625	625	Taken 3	Ex-government operative Bryan Mills is accused of a ruthless murder he never committed or witnessed. As he is tracked and pursued, Mills brings out his particular set of skills to find the true killer and clear his name.	2014	109	6.0	144715	89.25	26	439
626	626	Total Recall	A factory worker, Douglas Quaid, begins to suspect that he is a spy after visiting Rekall - a company that provides its clients with implanted fake memories of a life they would like to have led - goes wrong and he finds himself on the run.	2012	118	6.3	210965	58.88	43	440
627	627	X-Men: The Last Stand	When a cure is found to treat mutations, lines are drawn amongst the X-Men, led by Professor Charles Xavier, and the Brotherhood, a band of powerful mutants organized under Xavier's former ally, Magneto.	2006	104	6.7	406540	234.36	58	224
628	628	The Escort	Desperate for a good story, a sex-addicted journalist throws himself into the world of high-class escorts when he starts following a Stanford-educated prostitute.	2016	88	6.0	7181	\N	46	441
629	629	The Whole Truth	A defense attorney works to get his teenage client acquitted of murdering his wealthy father.	2016	93	6.1	10700	\N	\N	442
630	630	Night at the Museum: Secret of the Tomb	Larry spans the globe, uniting favorite and new characters while embarking on an epic quest to save the magic before it is gone forever.	2014	98	6.2	74886	113.73	47	443
631	631	Love & Other Drugs	A young woman suffering from Parkinson's befriends a drug rep working for Pfizer in 1990s Pittsburgh.	2010	112	6.7	151519	32.36	55	138
632	632	The Interview	Dave Skylark and his producer Aaron Rapoport run the celebrity tabloid show "Skylark Tonight". When they land an interview with a surprise fan, North Korean dictator Kim Jong-un, they are recruited by the CIA to turn their trip to Pyongyang into an assassination mission.	2014	112	6.6	261536	6.11	52	270
633	633	The Host	A monster emerges from Seoul's Han River and focuses its attention on attacking people. One victim's loving family does what it can to rescue her from its clutches.	2006	120	7.0	73491	2.20	85	244
634	634	Megan Is Missing	Two teenage girls encounter an Internet child predator.	2011	85	4.9	6683	\N	94	444
635	635	WALL·E	In the distant future, a small waste-collecting robot inadvertently embarks on a space journey that will ultimately decide the fate of mankind.	2008	98	8.4	776897	223.81	\N	105
636	636	Knocked Up	For fun-loving party animal Ben Stone, the last thing he ever expected was for his one-night stand to show up on his doorstep eight weeks later to tell him she's pregnant with his child.	2007	129	7.0	309398	148.73	85	159
637	637	Source Code	A soldier wakes up in someone else's body and discovers he's part of an experimental government program to find the bomber of a commuter train. A mission he has only 8 minutes to complete.	2011	93	7.5	404884	54.70	74	84
638	638	Lawless	Set in Depression-era Franklin County, Virginia, a trio of bootlegging brothers are threatened by a new special deputy and other authorities angling for a cut of their profits.	2012	116	7.3	195360	37.40	58	349
639	639	Unfriended	A group of online chat room friends find themselves haunted by a mysterious, supernatural force using the account of their dead friend.	2014	83	5.6	50402	31.54	59	445
640	640	American Reunion	Jim, Michelle, Stifler, and their friends reunite in East Great Falls, Michigan for their high school reunion.	2012	113	6.7	178471	56.72	49	446
641	641	The Pursuit of Happyness	A struggling salesman takes custody of his son as he's poised to begin a life-changing professional career.	2006	117	8.0	361105	162.59	64	447
642	642	Relatos salvajes	Six short stories that explore the extremities of human behavior involving people in distress.	2014	122	8.1	110100	3.08	77	448
643	643	The Ridiculous 6	An outlaw who was raised by Native Americans discovers that he has five half-brothers; together the men go on a mission to find their wayward, deadbeat dad.	2015	119	4.8	31149	\N	18	259
644	644	Frantz	In the aftermath of WWI, a young German who grieves the death of her fiancé in France meets a mysterious Frenchman who visits the fiancé's grave to lay flowers.	2016	113	7.5	4304	0.86	73	449
645	645	Viral	Following the outbreak of a virus that wipes out the majority of the human population, a young woman documents her family's new life in quarantine and tries to protect her infected sister.	2016	85	5.5	3564	\N	72	112
646	646	Gran Torino	Disgruntled Korean War veteran Walt Kowalski sets out to reform his neighbor, a Hmong teenager who tried to steal Kowalski's prized possession: a 1972 Gran Torino.	2008	116	8.2	595779	148.09	\N	59
647	647	Burnt	Adam Jones (Bradley Cooper) is a chef who destroyed his career with drugs and diva behavior. He cleans up and returns to London, determined to redeem himself by spearheading a top restaurant that can gain three Michelin stars.	2015	101	6.6	76469	13.65	42	450
648	648	Tall Men	A challenged man is stalked by tall phantoms in business suits after he purchases a car with a mysterious black credit card.	2016	133	3.2	173	\N	57	451
649	649	Sleeping Beauty	A haunting portrait of Lucy, a young university student drawn into a mysterious hidden world of unspoken desires.	2011	101	5.3	27006	0.03	\N	452
650	650	Vampire Academy	Rose Hathaway is a Dhampir, half human-half vampire, a guardian of the Moroi, peaceful, mortal vampires living discreetly within our world. Her calling is to protect the Moroi from bloodthirsty, immortal Vampires, the Strigoi.	2014	104	5.6	44111	7.79	30	453
651	651	Sweeney Todd: The Demon Barber of Fleet Street	The infamous story of Benjamin Barker, a.k.a. Sweeney Todd, who sets up a barber shop down in London which is the basis for a sinister partnership with his fellow tenant, Mrs. Lovett. Based on the hit Broadway musical.	2007	116	7.4	296289	52.88	83	106
652	652	Solace	A psychic works with the FBI in order to hunt down a serial killer.	2015	101	6.4	36300	\N	36	454
654	654	Popstar: Never Stop Never Stopping	When it becomes clear that his solo album is a failure, a former boy band member does everything in his power to maintain his celebrity status.	2016	87	6.7	30875	9.39	68	455
655	655	The Levelling	Somerset, October 2014. When Clover Catto (Ellie Kendrick) receives a call telling her that her younger brother Harry (Joe Blakemore) is dead, she must return to her family farm and face ... See full summary »	2016	83	6.4	482	\N	82	456
656	656	Public Enemies	The Feds try to take down notorious American gangsters John Dillinger, Baby Face Nelson and Pretty Boy Floyd during a booming crime wave in the 1930s.	2009	140	7.0	240323	97.03	70	253
657	657	Boyhood	The life of Mason, from early childhood to his arrival at college.	2014	165	7.9	286722	25.36	100	222
658	658	Teenage Mutant Ninja Turtles	When a kingpin threatens New York City, a group of mutated turtle warriors must emerge from the shadows to protect their home.	2014	101	5.9	178527	190.87	31	457
659	659	Eastern Promises	A Russian teenager living in London who dies during childbirth leaves clues to a midwife in her journal that could tie her child to a rape involving a violent Russian mob family.	2007	100	7.7	198006	17.11	82	458
660	660	The Daughter	The story follows a man who returns home to discover a long-buried family secret, and whose attempts to put things right threaten the lives of those he left home years before.	2015	96	6.7	2798	0.03	62	459
661	661	Pineapple Express	A process server and his marijuana dealer wind up on the run from hitmen and a corrupt police officer after he witnesses his dealer's boss murder a competitor while trying to serve papers on him.	2008	111	7.0	267872	87.34	64	460
662	662	The First Time	A shy senior and a down-to-earth junior fall in love over one weekend.	2012	95	6.9	54027	0.02	55	461
663	663	Gone Baby Gone	Two Boston area detectives investigate a little girl's kidnapping, which ultimately turns into a crisis both professionally and personally.	2007	114	7.7	206707	20.30	72	81
664	664	The Heat	An uptight FBI Special Agent is paired with a foul-mouthed Boston cop to take down a ruthless drug lord.	2013	117	6.6	140151	159.58	60	76
665	665	L'avenir	A philosophy teacher soldiers through the death of her mother, getting fired from her job, and dealing with a husband who is cheating on her.	2016	102	7.1	5796	0.28	88	462
666	666	Anna Karenina	In late-19th-century Russian high society, St. Petersburg aristocrat Anna Karenina enters into a life-changing affair with the dashing Count Alexei Vronsky.	2012	129	6.6	75291	12.80	63	312
667	667	Regression	A detective and a psychoanalyst uncover evidence of a satanic cult while investigating the rape of a young woman.	2015	106	5.7	26320	0.05	32	463
668	668	Ted 2	Newlywed couple Ted and Tami-Lynn want to have a baby, but in order to qualify to be a parent, Ted will have to prove he's a person in a court of law.	2015	115	6.3	136323	81.26	48	464
669	669	Pain & Gain	A trio of bodybuilders in Florida get caught up in an extortion ring and a kidnapping scheme that goes terribly wrong.	2013	129	6.5	168875	49.87	45	111
670	670	Blood Diamond	A fisherman, a smuggler, and a syndicate of businessmen match wits over the possession of a priceless diamond.	2006	143	8.0	422014	57.37	64	138
671	671	Devil's Knot	The savage murders of three young children sparks a controversial trial of three teenagers accused of killing the kids as part of a satanic ritual.	2013	114	6.1	15514	\N	42	465
672	672	Child 44	A disgraced member of the Russian military police investigates a series of child murders during the Stalin-era Soviet Union.	2015	137	6.5	47703	1.21	41	466
673	673	The Hurt Locker	During the Iraq War, a Sergeant recently assigned to an army bomb squad is put at odds with his squad mates due to his maverick way of handling his work.	2008	131	7.6	352023	15.70	94	302
674	674	Green Lantern	Reckless test pilot Hal Jordan is granted an alien ring that bestows him with otherworldly powers that inducts him into an intergalactic police force, the Green Lantern Corps.	2011	114	5.6	231907	116.59	39	139
675	675	War on Everyone	Two corrupt cops set out to blackmail and frame every criminal unfortunate enough to cross their path. Events, however, are complicated by the arrival of someone who appears to be even more dangerous than they are.	2016	98	5.9	9285	\N	50	467
676	676	The Mist	A freak storm unleashes a species of bloodthirsty creatures on a small town, where a small band of citizens hole up in a supermarket and fight for their lives.	2007	126	7.2	233346	25.59	58	468
677	677	Escape Plan	When a structural-security authority finds himself set up and incarcerated in the world's most secret and secure prison, he has to use his skills to escape with help from the inside.	2013	115	6.7	188004	25.12	49	469
678	678	Love, Rosie	Rosie and Alex have been best friends since they were 5, so they couldn't possibly be right for one another...or could they? When it comes to love, life and making the right choices, these two are their own worst enemies.	2014	102	7.2	80415	0.01	44	241
679	679	The DUFF	A high school senior instigates a social pecking order revolution after finding out that she has been labeled the DUFF - Designated Ugly Fat Friend - by her prettier, more popular counterparts.	2015	101	6.5	57874	34.02	56	470
680	680	The Age of Shadows	Japanese agents close in as members of the Korean resistance plan an attack in 1920's Seoul.	2016	140	7.2	2403	0.54	78	471
681	681	The Hunger Games: Mockingjay - Part 1	Katniss Everdeen is in District 13 after she shatters the games forever. Under the leadership of President Coin and the advice of her trusted friends, Katniss spreads her wings as she fights to save Peeta and a nation moved by her courage.	2014	123	6.7	331902	337.10	64	304
682	682	We Need to Talk About Kevin	Kevin's mother struggles to love her strange child, despite the increasingly vicious things he says and does as he grows up. But Kevin is just getting started, and his final act will be beyond anything anyone imagined.	2011	112	7.5	104953	1.74	68	472
683	683	Love & Friendship	Lady Susan Vernon takes up temporary residence at her in-laws' estate and, while there, is determined to be a matchmaker for her daughter Frederica -- and herself too, naturally.	2016	90	6.5	16164	14.01	87	473
684	684	The Mortal Instruments: City of Bones	When her mother disappears, Clary Fray learns that she descends from a line of warriors who protect our world from demons. She joins forces with others like her and heads into a dangerous alternate New York called the Shadow World.	2013	130	5.9	112313	31.17	33	474
685	685	Seven Pounds	A man with a fateful secret embarks on an extraordinary journey of redemption by forever changing the lives of seven strangers.	2008	123	7.7	245144	69.95	36	447
686	686	The King's Speech	The story of King George VI of the United Kingdom of Great Britain and Northern Ireland, his impromptu ascension to the throne and the speech therapist who helped the unsure monarch become worthy of it.	2010	118	8.0	534388	138.80	88	198
687	687	Hunger	Irish republican Bobby Sands leads the inmates of a Northern Irish prison in a hunger strike.	2008	96	7.6	54486	0.15	82	99
688	688	Jumper	A teenager with teleportation abilities suddenly finds himself in the middle of an ancient war between those like him and their sworn annihilators.	2008	88	6.1	252503	80.17	35	166
689	689	Toy Story 3	The toys are mistakenly delivered to a day-care center instead of the attic right before Andy leaves for college, and it's up to Woody to convince the other toys that they weren't abandoned and to return home.	2010	103	8.3	586669	414.98	92	475
690	690	Tinker Tailor Soldier Spy	In the bleak days of the Cold War, espionage veteran George Smiley is forced from semi-retirement to uncover a Soviet agent within MI6.	2011	122	7.1	157053	24.10	85	476
691	691	Resident Evil: Retribution	Alice fights alongside a resistance movement to regain her freedom from an Umbrella Corporation testing facility.	2012	96	5.4	114144	42.35	39	35
692	692	Dear Zindagi	Kaira is a budding cinematographer in search of a perfect life. Her encounter with Jug, an unconventional thinker, helps her gain a new perspective on life. She discovers that happiness is all about finding comfort in life's imperfections.	2016	151	7.8	23540	1.40	56	477
693	693	Genius	A chronicle of Max Perkins's time as the book editor at Scribner, where he oversaw works by Thomas Wolfe, Ernest Hemingway, F. Scott Fitzgerald and others.	2016	104	6.5	10708	1.36	\N	478
694	694	Pompeii	A slave-turned-gladiator finds himself in a race against time to save his true love, who has been betrothed to a corrupt Roman Senator. As Mount Vesuvius erupts, he must fight to save his beloved as Pompeii crumbles around him.	2014	105	5.5	90188	23.22	39	35
695	695	Life of Pi	A young man who survives a disaster at sea is hurtled into an epic journey of adventure and discovery. While cast away, he forms an unexpected connection with another survivor: a fearsome Bengal tiger.	2012	127	7.9	471109	124.98	79	158
696	696	Hachi: A Dog's Tale	A college professor's bond with the abandoned dog he takes into his home.	2009	93	8.1	177602	\N	61	353
697	697	10 Years	The night before their high school reunion, a group of friends realize they still haven't quite grown up in some ways.	2011	100	6.1	19636	0.20	\N	479
698	698	I Origins	A molecular biologist and his laboratory partner uncover evidence that may fundamentally change society as we know it.	2014	106	7.3	86271	0.33	57	480
699	699	Live Free or Die Hard	John McClane and a young hacker join forces to take down master cyber-terrorist Thomas Gabriel in Washington D.C.	2007	128	7.2	347567	134.52	69	440
700	700	The Matchbreaker	When an idealistic romantic gets fired from his day job, he is offered a "one-time gig" to break up a girl's relationship for her disapproving parents. This "one-time" gig spreads through ... See full summary »	2016	94	5.5	1427	\N	44	481
701	701	Funny Games	Two psychopathic young men take a family hostage in their cabin.	2007	111	6.5	73835	1.29	\N	482
702	702	Ted	John Bennett, a man whose childhood wish of bringing his teddy bear to life came true, now must decide between keeping the relationship with the bear or his girlfriend, Lori.	2012	106	7.0	494641	218.63	62	464
703	703	RED	When his peaceful life is threatened by a high-tech assassin, former black-ops agent Frank Moses reassembles his old team in a last ditch effort to survive and uncover his assailants.	2010	111	7.1	250012	90.36	60	168
704	704	Australia	Set in northern Australia before World War II, an English aristocrat who inherits a sprawling ranch reluctantly pacts with a stock-man in order to protect her new property from a takeover plot. As the pair drive 2,000 head of cattle over unforgiving landscape, they experience the bombing of Darwin, Australia, by Japanese forces firsthand.	2008	165	6.6	106115	49.55	53	119
705	705	Faster	An ex-con gets on a series of apparently unrelated killings. He gets tracked by a veteran cop with secrets of his own and an egocentric hit man.	2010	98	6.5	83788	23.23	44	324
706	706	The Neighbor	Set in Cutter Mississippi, the film follows a man who discovers the dark truth about his neighbor and the secrets he may be keeping in the cellar.	2016	87	5.8	4754	\N	60	483
707	707	The Adjustment Bureau	The affair between a politician and a contemporary dancer is affected by mysterious forces keeping the lovers apart.	2011	106	7.1	208632	62.45	\N	371
708	708	The Hollars	A man returns to his small hometown after learning that his mother has fallen ill and is about to undergo surgery.	2016	88	6.5	5908	1.02	53	484
709	709	The Judge	Big-city lawyer Hank Palmer returns to his childhood home where his father, the town's judge, is suspected of murder. Hank sets out to discover the truth and, along the way, reconnects with his estranged family.	2014	141	7.4	146812	47.11	48	485
710	710	Closed Circuit	A high-profile terrorism case unexpectedly binds together two ex-lovers on the defense team - testing the limits of their loyalties and placing their lives in jeopardy.	2013	96	6.2	18437	5.73	50	327
711	711	Transformers: Revenge of the Fallen	Sam Witwicky leaves the Autobots behind for a normal life. But when his mind is filled with cryptic symbols, the Decepticons target him and he is dragged back into the Transformers' war.	2009	150	6.0	335757	402.08	35	111
712	712	La tortue rouge	A man is shipwrecked on a deserted island and encounters a red turtle, which changes his life.	2016	80	7.6	11482	0.92	86	486
713	713	The Book of Life	Manolo, a young man who is torn between fulfilling the expectations of his family and following his heart, embarks on an adventure that spans three fantastic worlds where he must face his greatest fears.	2014	95	7.3	50388	50.15	67	487
714	714	Incendies	Twins journey to the Middle East to discover their family history, and fulfill their mother's last wishes.	2010	131	8.2	92863	6.86	80	20
715	715	The Heartbreak Kid	A newly wed man who believes he's just gotten hitched to the perfect woman encounters another lady on his honeymoon.	2007	116	5.8	74664	36.77	46	488
716	716	Happy Feet	Into the world of the Emperor Penguins, who find their soul mates through song, a penguin is born who cannot sing. But he can tap dance something fierce!	2006	108	6.5	141141	197.99	77	66
717	717	Entourage	Movie star Vincent Chase, together with his boys Eric, Turtle, and Johnny, are back - and back in business with super agent-turned-studio head Ari Gold on a risky project that will serve as Vince's directorial debut.	2015	104	6.6	64557	32.36	38	489
719	719	Noah	A man is chosen by his world's creator to undertake a momentous mission before an apocalyptic flood cleanses the world.	2014	138	5.8	209700	101.16	68	208
720	720	Neighbors	After they are forced to live next to a fraternity house, a couple with a newborn baby do whatever they can to take them down.	2014	97	6.4	236500	150.06	68	230
721	721	Nymphomaniac: Vol. II	The continuation of Joe's sexually dictated life delves into the darker aspects of her adulthood, obsessions and what led to her being in Seligman's care.	2013	123	6.7	65824	0.33	60	210
722	722	Wild	A chronicle of one woman's 1,100-mile solo hike undertaken as a way to recover from a recent personal tragedy.	2014	115	7.1	95553	37.88	76	254
723	723	Grown Ups	After their high school basketball coach passes away, five good friends and former teammates reunite for a Fourth of July holiday weekend.	2010	102	6.0	190385	162.00	30	293
724	724	Blair Witch	After discovering a video showing what he believes to be his vanished sister Heather, James and a group of friends head to the forest believed to be inhabited by the Blair Witch.	2016	89	5.1	26088	20.75	47	491
725	725	The Karate Kid	Work causes a single mother to move to China with her young son; in his new home, the boy embraces kung fu, taught to him by a master.	2010	140	6.2	127983	176.59	61	474
726	726	Dark Shadows	An imprisoned vampire, Barnabas Collins, is set free and returns to his ancestral home, where his dysfunctional descendants are in need of his protection.	2012	113	6.2	209326	79.71	55	106
727	727	Friends with Benefits	A young man and woman decide to take their friendship to the next level without becoming a couple, but soon discover that adding sex only leads to complications.	2011	109	6.6	286543	55.80	63	366
728	728	The Illusionist	In turn-of-the-century Vienna, a magician uses his abilities to secure the love of a woman far above his social standing.	2006	110	7.6	309934	39.83	68	107
729	729	The A-Team	A group of Iraq War veterans looks to clear their name with the U.S. military, who suspect the four men of committing a crime for which they were framed.	2010	117	6.8	219116	77.21	47	492
730	730	The Guest	A soldier introduces himself to the Peterson family, claiming to be a friend of their son who died in action. After the young man is welcomed into their home, a series of accidental deaths seem to be connected to his presence.	2014	100	6.7	71069	0.32	76	491
731	731	The Internship	Two salesmen whose careers have been torpedoed by the digital age find their way into a coveted internship at Google, where they must compete with a group of young, tech-savvy geniuses for a shot at employment.	2013	119	6.3	166342	44.67	42	443
732	732	Paul	Two British comic-book geeks traveling across the U.S. encounter an alien outside Area 51.	2011	104	7.0	201707	37.37	57	126
733	733	This Beautiful Fantastic	A young woman who dreams of being a children's author makes an unlikely friendship with a cantankerous, rich old widower.	2016	100	6.9	688	\N	51	493
734	734	The Da Vinci Code	A murder inside the Louvre and clues in Da Vinci paintings lead to the discovery of a religious mystery protected by a secret society for two thousand years -- which could shake the foundations of Christianity.	2006	149	6.6	338280	217.54	46	127
735	735	Mr. Church	"Mr. Church" tells the story of a unique friendship that develops when a little girl and her dying mother retain the services of a talented cook - Henry Joseph Church. What begins as a six month arrangement instead spans into fifteen years and creates a family bond that lasts forever.	2016	104	7.7	16163	0.69	37	494
736	736	Hugo	In Paris in 1931, an orphan named Hugo Cabret who lives in the walls of a train station is wrapped up in a mystery involving his late father and an automaton.	2011	126	7.5	259182	73.82	83	55
737	737	The Blackcoat's Daughter	Two girls must battle a mysterious evil force when they get left behind at their boarding school over winter break.	2015	93	5.6	4155	0.02	68	495
738	738	Body of Lies	A CIA agent on the ground in Jordan hunts down a powerful terrorist leader while being caught between the unclear intentions of his American supervisors and Jordan Intelligence.	2008	128	7.1	182305	39.38	57	2
739	739	Knight of Cups	A writer indulging in all that Los Angeles and Las Vegas has to offer undertakes a search for love and self via a series of adventures with six different women.	2015	118	5.7	17439	0.56	53	496
740	740	The Mummy: Tomb of the Dragon Emperor	In the Far East, Alex O'Connell, the son of famed mummy fighters Rick and Evy O'Connell, unearths the mummy of the first Emperor of Qin -- a shape-shifting entity cursed by a witch centuries ago.	2008	112	5.2	124554	102.18	31	392
741	741	The Boss	A titan of industry is sent to prison after she's caught insider trading. When she emerges ready to rebrand herself as America's latest sweetheart, not everyone she screwed over is so quick to forgive and forget.	2016	99	5.4	29642	63.03	40	497
742	742	Hands of Stone	The legendary Roberto Duran and his equally legendary trainer Ray Arcel change each other's lives.	2016	111	6.6	8998	4.71	54	498
743	743	El secreto de sus ojos	A retired legal counselor writes a novel hoping to find closure for one of his past unresolved homicide cases and for his unreciprocated love with his superior - both of which still haunt him decades later.	2009	129	8.2	144524	20.17	80	499
744	744	True Grit	A tough U.S. Marshal helps a stubborn teenager track down her father's murderer.	2010	110	7.6	254904	171.03	80	118
745	745	We Are Your Friends	Caught between a forbidden romance and the expectations of his friends, aspiring DJ Cole Carter attempts to find the path in life that leads to fame and fortune.	2015	96	6.2	25903	3.59	46	500
746	746	A Million Ways to Die in the West	As a cowardly farmer begins to fall for the mysterious new woman in town, he must put his new-found courage to the test when her husband, a notorious gun-slinger, announces his arrival.	2014	116	6.1	144779	42.62	44	464
747	747	Only for One Night	A married womans husband with a perfect life cheats with her sister with extreme consequences befalling them all.	2016	86	4.6	313	\N	60	501
748	748	Rules Don't Apply	The unconventional love story of an aspiring actress, her determined driver, and their boss, eccentric billionaire Howard Hughes.	2016	127	5.7	3731	3.65	\N	502
749	749	Ouija: Origin of Evil	In 1967 Los Angeles, a widowed mother and her 2 daughters add a new stunt to bolster their seance scam business, inviting an evil presence into their home.	2016	99	6.1	30035	34.90	65	255
750	750	Percy Jackson: Sea of Monsters	In order to restore their dying safe haven, the son of Poseidon and his friends embark on a quest to the Sea of Monsters to find the mythical Golden Fleece while trying to stop an ancient evil from rising.	2013	106	5.9	91684	68.56	39	121
751	751	Fracture	An attorney, intent on climbing the career ladder toward success, finds an unlikely opponent in a manipulative criminal he is trying to prosecute.	2007	113	7.2	148943	39.00	68	503
752	752	Oculus	A woman tries to exonerate her brother, who was convicted of murder, by proving that the crime was committed by a supernatural phenomenon.	2013	104	6.5	92875	27.69	61	255
753	753	In Bruges	Guilt-stricken after a job gone wrong, hitman Ray and his partner await orders from their ruthless boss in Bruges, Belgium, the last place in the world Ray wants to be.	2008	107	7.9	322536	7.76	67	504
754	754	This Means War	Two top CIA operatives wage an epic battle against one another after they discover they are dating the same woman.	2012	103	6.3	154400	54.76	31	505
755	755	Lída Baarová	A film about the black-and-white era actress Lída Baarová and her doomed love affair.	2016	106	5.0	353	\N	64	506
756	756	The Road	In a dangerous post-apocalyptic world, an ailing father defends his son as they slowly travel to the sea.	2009	111	7.3	187302	0.06	\N	349
757	757	Lavender	After losing her memory, a woman begins to see unexplained things after her psychiatrist suggests she visit her childhood home.	2016	92	5.2	2083	\N	46	507
758	758	Deuces	An agent infiltrates a crime ring ran by a charismatic boss.	2016	87	6.6	256	\N	36	508
759	759	Conan the Barbarian	A vengeful barbarian warrior sets off to get his revenge on the evil warlord who attacked his village and murdered his father when he was a boy.	2011	113	5.2	84893	21.27	\N	438
760	760	The Fighter	A look at the early years of boxer "Irish" Micky Ward and his brother who helped train him before going pro in the mid 1980s.	2010	116	7.8	290056	93.57	79	256
761	761	August Rush	A drama with fairy tale elements, where an orphaned musical prodigy uses his gift as a clue to finding his birth parents.	2007	114	7.5	91229	31.66	38	509
762	762	Chef	A head chef quits his restaurant job and buys a food truck in an effort to reclaim his creative promise, while piecing back together his estranged family.	2014	114	7.3	151970	31.24	68	110
763	763	Eye in the Sky	Col. Katherine Powell, a military officer in command of an operation to capture terrorists in Kenya, sees her mission escalate when a girl enters the kill zone triggering an international dispute over the implications of modern warfare.	2015	102	7.3	57826	18.70	73	215
764	764	Eagle Eye	Jerry and Rachel are two strangers thrown together by a mysterious phone call from a woman they have never met. Threatening their lives and family, she pushes Jerry and Rachel into a series of increasingly dangerous situations, using the technology of everyday life to track and control their every move.	2008	118	6.6	156158	101.11	43	192
765	765	The Purge	A wealthy family are held hostage for harboring the target of a murderous syndicate during the Purge, a 12-hour period in which any and all crime is legal.	2013	85	5.7	154588	64.42	41	319
766	766	PK	A stranger in the city asks questions no one has asked before. His childlike curiosity will take him on a journey of love, laughter, and letting go.	2014	153	8.2	103279	10.57	51	320
767	767	Ender's Game	Young Ender Wiggin is recruited by the International Military to lead the fight against the Formics, a genocidal alien race which nearly annihilated the human race in a previous invasion.	2013	114	6.7	194236	61.66	\N	215
768	768	Indiana Jones and the Kingdom of the Crystal Skull	Famed archaeologist/adventurer Dr. Henry "Indiana" Jones is called back into action when he becomes entangled in a Soviet plot to uncover the secret behind mysterious artifacts known as the Crystal Skulls.	2008	122	6.2	351361	317.01	65	128
769	769	Paper Towns	After an all night adventure, Quentin's life-long crush, Margo, disappears, leaving behind clues that Quentin and his friends follow on the journey of a lifetime.	2015	109	6.3	72515	31.99	56	510
770	770	High-Rise	Life for the residents of a tower block begins to run out of control.	2015	119	5.7	25928	0.34	65	137
771	771	Quantum of Solace	James Bond descends into mystery as he tries to stop a mysterious organization from eliminating a country's most valuable resource. All the while, he still tries to seek revenge over the death of his love.	2008	106	6.6	347798	168.37	58	321
772	772	The Assignment	After waking up and discovering that he has undergone gender reassignment surgery, an assassin seeks to find the doctor responsible.	2016	95	4.5	2043	\N	34	511
773	773	How to Train Your Dragon	A hapless young Viking who aspires to hunt dragons becomes the unlikely friend of a young dragon himself, and learns there may be more to the creatures than he assumed.	2010	98	8.1	523893	217.39	74	512
774	774	Lady in the Water	Apartment building superintendent Cleveland Heep rescues what he thinks is a young woman from the pool he maintains. When he discovers that she is actually a character from a bedtime story who is trying to make the journey back to her home, he works with his tenants to protect his new friend from the creatures that are determined to keep her in our world.	2006	110	5.6	82701	42.27	36	3
775	775	The Fountain	As a modern-day scientist, Tommy is struggling with mortality, desperately searching for the medical breakthrough that will save the life of his cancer-stricken wife, Izzi.	2006	96	7.3	199193	10.14	51	208
776	776	Cars 2	Star race car Lightning McQueen and his pal Mater head overseas to compete in the World Grand Prix race. But the road to the championship becomes rocky as Mater gets caught up in an intriguing adventure of his own: international espionage.	2011	106	6.2	110490	191.45	57	180
777	777	31	Five carnival workers are kidnapped and held hostage in an abandoned, Hell-like compound where they are forced to participate in a violent game, the goal of which is to survive twelve hours against a gang of sadistic clowns.	2016	102	5.1	10871	0.78	35	513
778	778	Final Girl	A man teaches a young woman how to become a complete weapon. Later she is approached by a group of sadistic teens who kill blonde women for unknown reasons. The hunting season begins.	2015	90	4.7	9026	\N	56	514
779	779	Chalk It Up	When a super girly-girl is dumped by her boyfriend; she decides to do everything she can to get him back by building a college gymnastics team, quickly learning that she is capable of a lot more than just getting an MRS degree.	2016	90	4.8	499	\N	\N	515
780	780	The Man Who Knew Infinity	The story of the life and academic career of the pioneer Indian mathematician, Srinivasa Ramanujan, and his friendship with his mentor, Professor G.H. Hardy.	2015	108	7.2	29912	3.86	\N	516
781	781	Unknown	A man awakens from a coma, only to discover that someone has taken on his identity and that no one, (not even his wife), believes him. With the help of a young woman, he sets out to prove who he is.	2011	113	6.9	218679	61.09	56	116
782	782	Self/less	A dying real estate mogul transfers his consciousness into a healthy young body, but soon finds that neither the procedure nor the company that performed it are quite what they seem.	2015	117	6.5	67196	12.28	34	414
783	783	Mr. Brooks	A psychological thriller about a man who is sometimes controlled by his murder-and-mayhem-loving alter ego.	2007	120	7.3	128146	28.48	45	517
784	784	Tramps	A young man and woman find love in an unlikely place while carrying out a shady deal.	2016	82	6.5	1031	\N	77	518
785	785	Before We Go	Two strangers stuck in Manhattan for the night grow into each other's most trusted confidants when an evening of unexpected adventure forces them to confront their fears and take control of their lives.	2014	95	6.9	31370	0.04	31	519
786	786	Captain Phillips	The true story of Captain Richard Phillips and the 2009 hijacking by Somali pirates of the U.S.-flagged MV Maersk Alabama, the first American cargo ship to be hijacked in two hundred years.	2013	134	7.8	346154	107.10	83	18
787	787	The Secret Scripture	A woman keeps a diary of her extended stay at a mental hospital.	2016	108	6.8	378	\N	37	520
788	788	Max Steel	The adventures of teenager Max McGrath and his alien companion, Steel, who must harness and combine their tremendous new powers to evolve into the turbo-charged superhero Max Steel.	2016	92	4.6	11555	3.77	22	521
789	789	Hotel Transylvania 2	Dracula and his friends try to bring out the monster in his half human, half vampire grandson in order to keep Mavis from leaving the hotel.	2015	89	6.7	69157	169.69	44	522
790	790	Hancock	Hancock is a superhero whose ill considered behavior regularly causes damage in the millions. He changes when the person he saves helps him improve his public image.	2008	92	6.4	366138	227.95	49	65
791	791	Sisters	Two sisters decide to throw one last house party before their parents sell their family home.	2015	118	6.0	50241	87.03	58	229
792	792	The Family	The Manzoni family, a notorious mafia clan, is relocated to Normandy, France under the witness protection program, where fitting in soon becomes challenging as their old habits die hard.	2013	111	6.3	92868	36.92	42	375
793	793	Zack and Miri Make a Porno	Lifelong platonic friends Zack and Miri look to solve their respective cash-flow problems by making an adult film together. As the cameras roll, however, the duo begin to sense that they may have more feelings for each other than they previously thought.	2008	101	6.6	154936	31.45	56	310
794	794	Ma vie de Courgette	After losing his mother, a young boy is sent to a foster home with other orphans his age where he begins to learn the meaning of trust and true love.	2016	66	7.8	4370	0.29	85	523
795	795	Man on a Ledge	As a police psychologist works to talk down an ex-con who is threatening to jump from a Manhattan hotel rooftop, the biggest diamond heist ever committed is in motion.	2012	102	6.6	129252	18.60	40	524
796	796	No Strings Attached	A guy and girl try to keep their relationship strictly physical, but it's not long before they learn that they want something more.	2011	108	6.2	178243	70.63	50	525
797	797	Rescue Dawn	A U.S. fighter pilot's epic struggle of survival after being shot down on a mission over Laos during the Vietnam War.	2006	120	7.3	87887	5.48	77	526
798	798	Despicable Me 2	When Gru, the world's most super-bad turned super-dad has been recruited by a team of officials to stop lethal muscle and a host of Gru's own, He has to fight back with new gadgetry, cars, and more minion madness.	2013	98	7.4	304837	368.05	62	300
799	799	A Walk Among the Tombstones	Private investigator Matthew Scudder is hired by a drug kingpin to find out who kidnapped and murdered his wife.	2014	114	6.5	93883	25.98	57	527
800	800	The World's End	Five friends who reunite in an attempt to top their epic pub crawl from twenty years earlier unwittingly become humanity's only hope for survival.	2013	109	7.0	199813	26.00	81	135
801	801	Yoga Hosers	Two teenage yoga enthusiasts team up with a legendary man-hunter to battle with an ancient evil presence that is threatening their major party plans.	2016	88	4.3	7091	\N	23	310
802	802	Seven Psychopaths	A struggling screenwriter inadvertently becomes entangled in the Los Angeles criminal underworld after his oddball friends kidnap a gangster's beloved Shih Tzu.	2012	110	7.2	196652	14.99	66	504
803	803	Beowulf	The warrior Beowulf must fight and defeat the monster Grendel who is terrorizing Denmark, and later, Grendel's mother, who begins killing out of revenge.	2007	115	6.2	146566	82.16	59	69
804	804	Jack Ryan: Shadow Recruit	Jack Ryan, as a young covert CIA analyst, uncovers a Russian plot to crash the U.S. economy with a terrorist attack.	2014	105	6.2	103681	50.55	57	91
805	805	1408	A man who specializes in debunking paranormal occurrences checks into the fabled room 1408 in the Dolphin Hotel. Soon after settling in, he confronts genuine terror.	2007	104	6.8	221073	71.98	64	469
806	806	The Gambler	Lit professor and gambler Jim Bennett's debt causes him to borrow money from his mother and a loan shark. Further complicating his situation is his relationship with one of his students. Will Bennett risk his life for a second chance?	2014	111	6.0	52537	33.63	55	205
807	807	Prince of Persia: The Sands of Time	A young fugitive prince and princess must stop a villain who unknowingly threatens to destroy the world with a special dagger that enables the magic sand inside to reverse time.	2010	116	6.6	233148	90.76	50	528
808	808	The Spectacular Now	A hard-partying high school senior's philosophy on life changes when he meets the not-so-typical "nice girl."	2013	95	7.1	115751	6.85	82	529
809	809	A United Kingdom	The story of King Seretse Khama of Botswana and how his loving but controversial marriage to a British white woman, Ruth Williams, put his kingdom into political and diplomatic turmoil.	2016	111	6.8	4771	3.90	65	530
810	810	USS Indianapolis: Men of Courage	During World War II, an American navy ship is sunk by a Japanese submarine leaving 300 crewmen stranded in shark infested waters.	2016	128	5.2	4964	\N	30	531
811	811	Turbo Kid	In a post-apocalyptic wasteland in 1997, a comic book fan adopts the persona of his favourite hero to save his enthusiastic friend and fight a tyrannical overlord.	2015	93	6.7	19309	0.05	60	532
812	812	Mama	A young couple take in their two nieces only to suspect that a foreboding evil has latched itself to their family.	2013	100	6.2	142560	71.59	57	533
813	813	Orphan	A husband and wife who recently lost their baby adopt a nine year-old girl who is not nearly as innocent as she claims to be.	2009	123	7.0	153448	41.57	42	116
814	814	To Rome with Love	The lives of some visitors and residents of Rome and the romances, adventures and predicaments they get into.	2012	112	6.3	72050	16.68	54	264
815	815	Fantastic Mr. Fox	An urbane fox cannot resist returning to his farm raiding ways and then must help his community survive the farmers' retaliation.	2009	87	7.8	149779	21.00	83	193
816	816	Inside Man	A police detective, a bank robber, and a high-power broker enter high-stakes negotiations after the criminal's brilliant heist spirals into a hostage situation.	2006	129	7.6	285441	88.50	76	174
817	817	I.T.	A self-proclaimed millionaire, has his life turned upside down after firing his I.T. consultant.	2016	95	5.4	8755	\N	27	534
818	818	127 Hours	An adventurous mountain climber becomes trapped under a boulder while canyoneering alone near Moab, Utah and resorts to desperate measures in order to survive.	2010	94	7.6	294010	18.33	82	274
819	819	Annabelle	A couple begins to experience terrifying supernatural occurrences involving a vintage doll shortly after their home is invaded by satanic cultists.	2014	99	5.4	91106	84.26	37	535
820	820	Wolves at the Door	Four friends gather at an elegant home during the Summer of Love, 1969. Unbeknownst to them, deadly visitors are waiting outside. What begins as a simple farewell party turns to a night of ... See full summary »	2016	73	4.6	564	\N	63	535
821	821	Suite Française	During the early years of Nazi occupation of France in World War II, romance blooms between Lucile Angellier (Michelle Williams), a French villager, and Bruno von Falk (Matthias Schoenaerts), a German soldier.	2014	107	6.9	13711	\N	\N	536
822	822	The Imaginarium of Doctor Parnassus	A traveling theater company gives its audience much more than they were expecting.	2009	123	6.8	130153	7.69	65	537
823	823	G.I. Joe: The Rise of Cobra	An elite military unit comprised of special operatives known as G.I. Joe, operating out of The Pit, takes on an evil organization led by a notorious arms dealer.	2009	118	5.8	180105	150.17	32	538
824	824	Christine	The story of Christine Chubbuck, a 1970s TV reporter struggling with depression and professional frustrations as she tries to advance her career.	2016	119	7.0	5855	0.30	72	539
825	825	Man Down	In a post-apocalyptic America, former U.S. Marine Gabriel Drummer searches desperately for the whereabouts of his son, accompanied by his best friend and a survivor.	2015	90	5.8	4779	\N	27	540
826	826	Crawlspace	A thriller centered around a widower who moves into a seemingly perfect new home with his daughter and new wife.	2016	88	5.3	1427	\N	25	541
827	827	Shut In	A heart-pounding thriller about a widowed child psychologist who lives in an isolated existence in rural New England. Caught in a deadly winter storm, she must find a way to rescue a young boy before he disappears forever.	2016	91	4.6	5715	6.88	\N	542
828	828	The Warriors Gate	A teenager is magically transported to China and learns to convert his video game skills into those of a Kung Fu warrior.	2016	108	5.3	1391	\N	77	543
829	829	Grindhouse	Quentin Tarantino and Robert Rodriguez's homage to exploitation double features in the 60s and 70s with two back-to-back cult films that include previews of coming attractions between them.	2007	191	7.6	160350	25.03	\N	544
830	830	Disaster Movie	Over the course of one evening, an unsuspecting group of twenty-somethings find themselves bombarded by a series of natural disasters and catastrophic events.	2008	87	1.9	77207	14.17	15	545
831	831	Rocky Balboa	Thirty years after the ring of the first bell, Rocky Balboa comes out of retirement and dons his gloves for his final fight; against the reigning heavyweight champ Mason 'The Line' Dixon.	2006	102	7.2	171356	70.27	63	396
832	832	Diary of a Wimpy Kid: Dog Days	School's out. Summer vacation is on. However, Greg may not have the best summer vacation ever. What could go wrong?	2012	94	6.4	16917	49.00	54	546
833	833	Jane Eyre	A mousy governess who softens the heart of her employer soon discovers that he's hiding a terrible secret.	2011	120	7.4	67464	11.23	76	547
834	834	Fool's Gold	A new clue to the whereabouts of a lost treasure rekindles a married couple's sense of adventure -- and their estranged romance.	2008	112	5.7	62719	70.22	29	548
835	835	The Dictator	The heroic story of a dictator who risked his life to ensure that democracy would never come to the country he so lovingly oppressed.	2012	83	6.4	225394	59.62	58	549
836	836	The Loft	Five married guys conspire to secretly share a penthouse loft in the city--a place where they can carry out hidden affairs and indulge in their deepest fantasies. But the fantasy becomes a nightmare when they discover the dead body of an unknown woman in the loft, and they realize one of the group must be involved.	2014	108	6.3	38804	5.98	24	550
837	837	Bacalaureat	A film about compromises and the implications of the parent's role.	2016	128	7.5	5531	0.13	84	551
838	838	You Don't Mess with the Zohan	An Israeli Special Forces Soldier fakes his death so he can re-emerge in New York City as a hair stylist.	2008	113	5.5	163144	100.02	54	293
839	839	Exposed	A police detective investigates the truth behind his partner's death. The mysterious case reveals disturbing police corruption and a dangerous secret involving an unlikely young woman.	2016	102	4.2	8409	\N	23	552
840	840	Maudie	An arthritic Nova Scotia woman works as a housekeeper while she hones her skills as an artist and eventually becomes a beloved figure in the community.	2016	115	7.8	346	\N	60	553
841	841	Horrible Bosses 2	Dale, Kurt and Nick decide to start their own business but things don't go as planned because of a slick investor, prompting the trio to pull off a harebrained and misguided kidnapping scheme.	2014	108	6.3	125190	54.41	40	420
842	842	A Bigger Splash	The vacation of a famous rock star and a filmmaker in Italy is disrupted by the unexpected visit of an old friend and his daughter.	2015	125	6.4	15232	1.98	74	554
843	843	Melancholia	Two sisters find their already strained relationship challenged as a mysterious new planet threatens to collide with Earth.	2011	135	7.1	137117	3.03	80	210
844	844	The Princess and the Frog	A waitress, desperate to fulfill her dreams as a restaurant owner, is set on a journey to turn a frog prince back into a human being, but she has to face the same problem after she kisses him.	2009	97	7.1	95480	104.37	73	14
845	845	Unstoppable	With an unmanned, half-mile-long freight train barreling toward a city, a veteran engineer and a young conductor race against the clock to prevent a catastrophe.	2010	98	6.8	157499	81.56	69	374
846	846	Flight	An airline pilot saves almost all his passengers on his malfunctioning airliner which eventually crashed, but an investigation into the accident reveals something troubling.	2012	138	7.3	276347	93.75	76	69
907	907	Hello, My Name Is Doris	A self-help seminar inspires a sixty-something woman to romantically pursue her younger co-worker.	2015	95	6.7	12361	14.44	63	587
847	847	Home	An alien on the run from his own people makes friends with a girl. He tries to help her on her quest, but can be an interference.	2015	94	6.7	77447	177.34	55	555
848	848	La migliore offerta	In the world of high-end art auctions and antiques, Virgil Oldman is an elderly and esteemed but eccentric genius art-expert, known and appreciated by the world. Oldman is hired by a ... See full summary »	2013	131	7.8	77986	0.09	49	556
849	849	Mean Dreams	Follows Casey and Jonas, two teenagers desperate to escape their broken and abusive homes and examines the desperation of life on the run and the beauty of first love.	2016	108	6.3	1066	\N	64	557
850	850	42	This movie is about Jackie Robinson and his journey to becoming a Brooklyn Dodger and his life during that time.	2013	128	7.5	69659	95.00	62	90
851	851	21	"21" is the fact-based story about six MIT students who were trained to become experts in card counting and subsequently took Vegas casinos for millions in winnings.	2008	123	6.8	198395	81.16	48	558
852	852	Begin Again	A chance encounter between a disgraced music-business executive and a young singer-songwriter new to Manhattan turns into a promising collaboration between the two talents.	2013	104	7.4	111875	16.17	62	219
853	853	Out of the Furnace	When Rodney Baze mysteriously disappears and law enforcement doesn't follow through fast enough, his older brother, Russell, takes matters into his own hands to find justice.	2013	116	6.8	88829	11.33	63	283
854	854	Vicky Cristina Barcelona	Two girlfriends on a summer holiday in Spain become enamored with the same painter, unaware that his ex-wife, with whom he has a tempestuous relationship, is about to re-enter the picture.	2008	96	7.1	208770	23.21	70	264
855	855	Kung Fu Panda	The Dragon Warrior has to clash against the savage Tai Lung as China's fate hangs in the balance: However, the Dragon Warrior mantle is supposedly mistaken to be bestowed upon an obese panda who is a tyro in martial arts.	2008	92	7.6	329788	215.40	73	559
856	856	Barbershop: The Next Cut	As their surrounding community has taken a turn for the worse, the crew at Calvin's Barbershop come together to bring some much needed change to their neighborhood.	2016	111	5.9	9993	54.01	67	560
857	857	Terminator Salvation	In 2018, a mysterious new weapon in the war against the machines, half-human and half-machine, comes to John Connor on the eve of a resistance attack on Skynet. But whose side is he on, and can he be trusted?	2009	115	6.6	297093	125.32	49	505
858	858	Freedom Writers	A young teacher inspires her class of at-risk students to learn tolerance, apply themselves, and pursue education beyond high school.	2007	123	7.5	55648	36.58	64	383
859	859	The Hills Have Eyes	A suburban American family is being stalked by a group of psychotic people who live in the desert, far away from civilization.	2006	107	6.4	136642	41.78	52	561
860	860	Changeling	A grief-stricken mother takes on the LAPD to her own detriment when it stubbornly tries to pass off an obvious impostor as her missing child, while also refusing to give up hope that she will find him one day.	2008	141	7.8	206793	35.71	63	59
861	861	Remember Me	A romantic drama centered on two new lovers: Tyler, whose parents have split in the wake of his brother's suicide, and Ally, who lives each day to the fullest since witnessing her mother's murder.	2010	113	7.2	119376	19.06	40	562
862	862	Koe no katachi	The story revolves around Nishimiya Shoko, a grade school student who has impaired hearing. She transfers into a new school, where she is bullied by her classmates, especially Ishida Shouya... See full summary »	2016	129	8.4	2421	\N	80	563
863	863	Alexander and the Terrible, Horrible, No Good, Very Bad Day	Alexander's day begins with gum stuck in his hair, followed by more calamities. However, he finds little sympathy from his family and begins to wonder if bad things only happen to him, his mom, dad, brother and sister - who all find themselves living through their own terrible, horrible, no good, very bad day.	2014	81	6.2	32310	66.95	54	564
864	864	Locke	Ivan Locke, a dedicated family man and successful construction manager, receives a phone call on the eve of the biggest challenge of his career that sets in motion a series of events that threaten his carefully cultivated existence.	2013	85	7.1	100890	1.36	81	565
865	865	The 9th Life of Louis Drax	A psychologist who begins working with a young boy who has suffered a near-fatal fall finds himself drawn into a mystery that tests the boundaries of fantasy and reality.	2016	108	6.3	6175	\N	41	561
866	866	Horns	In the aftermath of his girlfriend's mysterious death, a young man awakens to find strange horns sprouting from his temples.	2013	120	6.5	61060	0.16	46	561
867	867	Indignation	In 1951, Marcus, a working-class Jewish student from New Jersey, attends a small Ohio college, where he struggles with sexual repression and cultural disaffection, amid the ongoing Korean War.	2016	110	6.9	7402	3.40	78	566
868	868	The Stanford Prison Experiment	Twenty-four male students out of seventy-five were selected to take on randomly assigned roles of prisoners and guards in a mock prison situated in the basement of the Stanford psychology building.	2015	122	6.9	20907	0.64	67	567
869	869	Diary of a Wimpy Kid: Rodrick Rules	Back in middle school after summer vacation, Greg Heffley and his older brother Rodrick must deal with their parents' misguided attempts to have them bond.	2011	99	6.6	20194	52.69	51	546
870	870	Mission: Impossible III	Agent Ethan Hunt comes into conflict with a dangerous and sadistic arms dealer who threatens his life and his fianceé in response .	2006	126	6.9	270429	133.38	66	51
871	871	En man som heter Ove	Ove, an ill-tempered, isolated retiree who spends his days enforcing block association rules and visiting his wife's grave, has finally given up on life just as an unlikely friendship develops with his boisterous new neighbors.	2015	116	7.7	21569	3.36	70	568
872	872	Dragonball Evolution	The young warrior Son Goku sets out on a quest, racing against time and the vengeful King Piccolo, to collect a set of seven magical orbs that will grant their wielder unlimited power.	2009	85	2.7	59512	9.35	45	569
873	873	Red Dawn	A group of teenagers look to save their town from an invasion of North Korean soldiers.	2012	93	5.4	64584	44.80	31	570
874	874	One Day	After spending the night together on the night of their college graduation Dexter and Em are shown each year on the same date to see where they are in their lives. They are sometimes together, sometimes not, on that day.	2011	107	7.0	113599	13.77	48	58
875	875	Life as We Know It	Two single adults become caregivers to an orphaned girl when their mutual best friends die in an accident.	2010	114	6.6	101301	53.36	39	571
1000	1000	Nine Lives	A stuffy businessman finds himself trapped inside the body of his family's cat.	2016	87	5.3	12435	19.64	11	358
876	876	28 Weeks Later	Six months after the rage virus was inflicted on the population of Great Britain, the US Army helps to secure a small area of London for the survivors to repopulate and start again. But not everything goes to plan.	2007	100	7.0	221858	28.64	78	572
877	877	Warm Bodies	After a highly unusual zombie saves a still-living girl from an attack, the two form a relationship that sets in motion events that might transform the entire lifeless world.	2013	98	6.9	193579	66.36	59	573
878	878	Blue Jasmine	A New York socialite, deeply troubled and in denial, arrives in San Francisco to impose upon her sister. She looks a million, but isn't bringing money, peace, or love...	2013	98	7.3	160592	33.40	78	264
879	879	G.I. Joe: Retaliation	The G.I. Joes are not only fighting their mortal enemy Cobra; they are forced to contend with threats from within the government that jeopardize their very existence.	2013	110	5.8	152145	122.51	41	141
880	880	Wrath of the Titans	Perseus braves the treacherous underworld to rescue his father, Zeus, captured by his son, Ares, and brother Hades who unleash the ancient Titans upon the world.	2012	99	5.8	159230	83.64	37	457
881	881	Shin Gojira	Japan is plunged into chaos upon the appearance of a giant monster.	2016	120	6.9	8365	1.91	68	574
882	882	Saving Mr. Banks	Author P.L. Travers reflects on her childhood after reluctantly meeting with Walt Disney, who seeks to adapt her Mary Poppins books for the big screen.	2013	125	7.5	125693	83.30	65	44
883	883	Transcendence	A scientist's drive for artificial intelligence, takes on dangerous implications when his consciousness is uploaded into one such program.	2014	119	6.3	184564	23.01	42	575
884	884	Rio	When Blu, a domesticated macaw from small-town Minnesota, meets the fiercely independent Jewel, he takes off on an adventure to Rio de Janeiro with the bird of his dreams.	2011	96	6.9	173919	143.62	63	576
885	885	Equals	In an emotionless utopia, two people fall in love when they regain their feelings from a mysterious disease, causing tensions between them and their society.	2015	101	6.1	16361	0.03	43	577
886	886	Babel	Tragedy strikes a married couple on vacation in the Moroccan desert, touching off an interlocking story involving four different families.	2006	143	7.5	253417	34.30	69	114
887	887	The Tree of Life	The story of a family in Waco, Texas in 1956. The eldest son witnesses the loss of innocence and struggles with his parents' conflicting teachings.	2011	139	6.8	143517	13.30	85	496
888	888	The Lucky One	A Marine travels to Louisiana after serving three tours in Iraq and searches for the unknown woman he believes was his good luck charm during the war.	2012	101	6.5	82874	60.44	39	48
889	889	Piranha 3D	After a sudden underwater tremor sets free scores of the prehistoric man-eating fish, an unlikely group of strangers must band together to stop themselves from becoming fish food for the area's new razor-toothed residents.	2010	88	5.5	75262	25.00	53	561
890	890	50/50	Inspired by a true story, a comedy centered on a 27-year-old guy who learns of his cancer diagnosis, and his subsequent struggle to beat the disease.	2011	100	7.7	281625	34.96	72	573
891	891	The Intent	Gunz (Dylan Duffus) is thrust into a world of excitement when he joins the TIC crew. The crew, led by the ruthless Hoodz (Scorcher), goes from low level weed peddling to full on armed ... See full summary »	2016	104	3.5	202	\N	59	578
892	892	This Is 40	Pete and Debbie are both about to turn 40, their kids hate each other, both of their businesses are failing, they're on the verge of losing their house, and their relationship is threatening to fall apart.	2012	134	6.2	108156	67.52	\N	159
893	893	Real Steel	In the near future, robot boxing is a top sport. A struggling promoter feels he's found a champion in a discarded robot.	2011	127	7.1	264480	85.46	56	443
894	894	Sex and the City	A New York writer on sex and love is finally getting married to her Mr. Big. But her three best girlfriends must console her after one of them inadvertently leads Mr. Big to jilt her.	2008	145	5.5	102547	152.64	53	579
895	895	Rambo	In Thailand, John Rambo joins a group of missionaries to venture into war-torn Burma, and rescue a group of Christian aid workers who were kidnapped by the ruthless local infantry unit.	2008	92	7.1	187077	42.72	46	396
896	896	Planet Terror	After an experimental bio-weapon is released, turning thousands into zombie-like creatures, it's up to a rag-tag group of survivors to stop the infected and those behind its release.	2007	105	7.1	174553	\N	55	544
897	897	Concussion	In Pittsburgh, accomplished pathologist Dr. Bennet Omalu uncovers the truth about brain damage in football players who suffer repeated concussions in the course of normal play.	2015	123	7.1	61274	34.53	\N	580
898	898	The Fall	In a hospital on the outskirts of 1920s Los Angeles, an injured stuntman begins to tell a fellow patient, a little girl with a broken arm, a fantastic story of five mythical heroes. Thanks to his fractured state of mind and her vivid imagination, the line between fiction and reality blurs as the tale advances.	2006	117	7.9	93036	2.28	64	414
899	899	The Ugly Truth	A romantically challenged morning show producer is reluctantly embroiled in a series of outrageous tests by her chauvinistic correspondent to prove his theories on relationships and help ... See full summary »	2009	96	6.5	172558	88.92	28	558
900	900	Bride Wars	Two best friends become rivals when they schedule their respective weddings on the same day.	2009	89	5.5	83976	58.72	24	581
901	901	Sleeping with Other People	A good-natured womanizer and a serial cheater form a platonic relationship that helps reform them in ways, while a mutual attraction sets in.	2015	101	6.5	27730	0.81	64	582
902	902	Snakes on a Plane	An FBI agent takes on a plane full of deadly and venomous snakes, deliberately released to kill a witness being flown from Honolulu to Los Angeles to testify against a mob boss.	2006	105	5.6	118905	34.01	58	583
903	903	What If	Wallace, who is burned out from a string of failed relationships, forms an instant bond with Chantry, who lives with her longtime boyfriend. Together, they puzzle out what it means if your best friend is also the love of your life.	2013	98	6.8	55243	3.45	59	584
904	904	How to Train Your Dragon 2	When Hiccup and Toothless discover an ice cave that is home to hundreds of new wild dragons and the mysterious Dragon Rider, the two friends find themselves at the center of a battle to protect the peace.	2014	102	7.9	237565	177.00	76	512
905	905	RoboCop	In 2028 Detroit, when Alex Murphy - a loving husband, father and good cop - is critically injured in the line of duty, the multinational conglomerate OmniCorp sees their chance for a part-man, part-robot police officer.	2014	117	6.2	190833	58.61	52	585
908	908	Ocean's Thirteen	Danny Ocean rounds up the boys for a third heist, after casino owner Willy Bank double-crosses one of the original eleven, Reuben Tishkoff.	2007	122	6.9	269581	117.14	62	297
909	909	Slither	A small town is taken over by an alien plague, turning residents into zombies and all forms of mutant monsters.	2006	95	6.5	64351	7.77	69	1
910	910	Contagion	Healthcare professionals, government officials and everyday people find themselves in the midst of a worldwide epidemic as the CDC works to find a cure.	2011	106	6.6	187004	75.64	70	297
911	911	Il racconto dei racconti - Tale of Tales	From the bitter quest of the Queen of Longtrellis, to two mysterious sisters who provoke the passion of a king, to the King of Highhills obsessed with a giant Flea, these tales are inspired by the fairytales by Giambattista Basile.	2015	133	6.4	17565	0.08	72	588
912	912	I Am the Pretty Thing That Lives in the House	A young nurse takes care of elderly author who lives in a haunted house.	2016	87	4.7	4204	\N	68	495
913	913	Bridge to Terabithia	A preteen's life turns upside down when he befriends the new girl in school and they imagine a whole new fantasy world to escape reality.	2007	96	7.2	117297	82.23	74	589
914	914	Coherence	Strange things begin to happen when a group of friends gather for a dinner party on an evening when a comet is passing overhead.	2013	89	7.2	66265	0.07	65	590
915	915	Notorious	The life and death story of Notorious B.I.G. (a.k.a. Christopher Wallace), who came straight out of Brooklyn to take the world of rap music by storm.	2009	122	6.7	33007	36.84	60	324
916	916	Goksung	A stranger arrives in a little village and soon after a mysterious sickness starts spreading. A policeman is drawn into the incident and is forced to solve the mystery in order to save his daughter.	2016	156	7.5	17962	0.79	81	591
917	917	The Expendables 2	Mr. Church reunites the Expendables for what should be an easy paycheck, but when one of their men is murdered on the job, their quest for revenge puts them deep in enemy territory and up against an unexpected threat.	2012	103	6.6	257395	85.02	51	592
918	918	The Girl Next Door	Based on the Jack Ketchum novel of the same name, The Girl Next Door follows the unspeakable torture and abuses committed on a teenage girl in the care of her aunt...and the boys who witness and fail to report the crime.	2007	91	6.7	19351	\N	29	593
919	919	Perfume: The Story of a Murderer	Jean-Baptiste Grenouille, born with a superior olfactory sense, creates the world's finest perfume. His work, however, takes a dark turn as he searches for the ultimate scent.	2006	147	7.5	199387	2.21	56	214
920	920	The Golden Compass	In a parallel universe, young Lyra Belacqua journeys to the far North to save her best friend and other kidnapped children from terrible experiments by a mysterious organization.	2007	113	6.1	155078	70.08	51	594
921	921	Centurion	A splinter group of Roman soldiers fight for their lives behind enemy lines after their legion is decimated in a devastating guerrilla attack.	2010	97	6.4	67801	0.12	62	595
922	922	Scouts Guide to the Zombie Apocalypse	Three scouts, on the eve of their last camp-out, discover the true meaning of friendship when they attempt to save their town from a zombie outbreak.	2015	93	6.3	31651	3.64	32	596
923	923	17 Again	Mike O'Donnell is ungrateful for how his life turned out. He gets a chance to rewrite his life when he tried to save a janitor near a bridge and jumped after him into a time vortex.	2009	102	6.4	152808	64.15	48	314
924	924	No Escape	In their new overseas home, an American family soon finds themselves caught in the middle of a coup, and they frantically look for a safe escape from an environment where foreigners are being immediately executed.	2015	103	6.8	57921	27.29	38	597
925	925	Superman Returns	Superman reappears after a long absence, but is challenged by an old foe who uses Kryptonian technology for world domination.	2006	154	6.1	246797	200.07	72	33
926	926	The Twilight Saga: Breaking Dawn - Part 1	The Quileutes close in on expecting parents Edward and Bella, whose unborn child poses a threat to the Wolf Pack and the towns people of Forks.	2011	117	4.9	190244	281.28	45	275
927	927	Precious	In New York City's Harlem circa 1987, an overweight, abused, illiterate teen who is pregnant with her second child is invited to enroll in an alternative school in hopes that her life can head in a new direction.	2009	110	7.3	91623	47.54	79	598
928	928	The Sea of Trees	A suicidal American befriends a Japanese man lost in a forest near Mt. Fuji and the two search for a way out.	2015	110	5.9	7475	0.02	23	599
929	929	Good Kids	Four high school students look to redefine themselves after graduation.	2016	86	6.1	3843	\N	86	600
930	930	The Master	A Naval veteran arrives home from war unsettled and uncertain of his future - until he is tantalized by The Cause and its charismatic leader.	2012	144	7.1	112902	16.38	\N	235
931	931	Footloose	City teenager Ren MacCormack moves to a small town where rock music and dancing have been banned, and his rebellious spirit shakes up the populace.	2011	113	5.9	39380	51.78	58	601
932	932	If I Stay	Life changes in an instant for young Mia Hall after a car accident puts her in a coma. During an out-of-body experience, she must decide whether to wake up and live a life far different than she had imagined. The choice is hers if she can go on.	2014	107	6.8	92170	50.46	46	602
933	933	The Ticket	A blind man who regains his vision finds himself becoming metaphorically blinded by his obsession for the superficial.	2016	97	5.4	924	\N	52	603
934	934	Detour	A young law student blindly enters into a pact with a man who offers to kill his stepfather, whom he feels is responsible for the accident that sent his mother into a coma.	2016	97	6.3	2205	\N	46	604
935	935	The Love Witch	A modern-day witch uses spells and magic to get men to fall in love with her.	2016	120	6.2	4669	0.22	82	605
936	936	Talladega Nights: The Ballad of Ricky Bobby	#1 NASCAR driver Ricky Bobby stays atop the heap thanks to a pact with his best friend and teammate, Cal Naughton, Jr. But when a French Formula One driver, makes his way up the ladder, Ricky Bobby's talent and devotion are put to the test.	2006	108	6.6	137502	148.21	66	122
937	937	The Human Centipede (First Sequence)	A mad scientist kidnaps and mutilates a trio of tourists in order to reassemble them into a human centipede, created by stitching their mouths to each others' rectums.	2009	92	4.4	60655	0.18	33	606
938	938	Super	After his wife falls under the influence of a drug dealer, an everyday guy transforms himself into Crimson Bolt, a superhero with the best intentions, but lacking in heroic skills.	2010	96	6.8	64535	0.32	50	1
939	939	The Siege of Jadotville	Irish Commandant Pat Quinlan leads a stand off with troops against French and Belgian Mercenaries in the Congo during the early 1960s.	2016	108	7.3	14689	\N	83	607
940	940	Up in the Air	Ryan Bingham enjoys living out of a suitcase for his job traveling around the country firing people, but finds that lifestyle threatened by the presence of a potential love interest and a new hire.	2009	109	7.4	279694	83.81	\N	399
941	941	The Midnight Meat Train	A photographer's obsessive pursuit of dark subject matter leads him into the path of a serial killer who stalks late night commuters, ultimately butchering them in the most gruesome ways imaginable.	2008	98	6.1	50255	0.07	58	608
942	942	The Twilight Saga: Eclipse	As a string of mysterious killings grips Seattle, Bella, whose high school graduation is fast approaching, is forced to choose between her love for vampire Edward and her friendship with werewolf Jacob.	2010	124	4.9	192740	300.52	58	609
943	943	Transpecos	For three Border Patrol agents working a remote desert checkpoint, the contents of one car will reveal an insidious plot within their own ranks. The next 24 hours will take them on a treacherous journey that could cost them their lives.	2016	86	5.8	1292	\N	73	610
944	944	What's Your Number?	A woman looks back at the past nineteen men she's had relationships with in her life and wonders if one of them might be her one true love.	2011	106	6.1	62095	13.99	35	611
945	945	Riddick	Left for dead on a sun-scorched planet, Riddick finds himself up against an alien race of predators. Activating an emergency beacon alerts two ships: one carrying a new breed of mercenary, the other captained by a man from Riddick's past.	2013	119	6.4	132098	42.00	49	612
946	946	Triangle	The story revolves around the passengers of a yachting trip in the Atlantic Ocean who, when struck by mysterious weather conditions, jump to another ship only to experience greater havoc on the open seas.	2009	99	6.9	72533	\N	66	604
947	947	The Butler	As Cecil Gaines serves eight presidents during his tenure as a butler at the White House, the civil rights movement, Vietnam, and other major events affect this man's life, family, and American society.	2013	132	7.2	93322	116.63	\N	598
948	948	King Cobra	This ripped-from-the-headlines drama covers the early rise of gay porn headliner Sean Paul Lockhart a.k.a. Brent Corrigan, before his falling out with the producer who made him famous. When... See full summary »	2016	91	5.6	3990	0.03	48	613
949	949	After Earth	A crash landing leaves Kitai Raige and his father Cypher stranded on Earth, a millennium after events forced humanity's escape. With Cypher injured, Kitai must embark on a perilous journey to signal for help.	2013	100	4.9	166512	60.52	33	3
950	950	Kicks	Brandon is a 15 year old whose dream is a pair of fresh Air Jordans. Soon after he gets his hands on them, they're stolen by a local hood, causing Brandon and his two friends to go on a dangerous mission through Oakland to retrieve them.	2016	80	6.1	2417	0.15	69	614
951	951	Me and Earl and the Dying Girl	High schooler Greg, who spends most of his time making parodies of classic movies with his co-worker Earl, finds his outlook forever altered after befriending a classmate who has just been diagnosed with cancer.	2015	105	7.8	92076	6.74	74	615
952	952	The Descendants	A land baron tries to reconnect with his two daughters after his wife is seriously injured in a boating accident.	2011	115	7.3	211348	82.62	84	616
953	953	Sex and the City 2	While wrestling with the pressures of life, love, and work in Manhattan, Carrie, Miranda, and Charlotte join Samantha for a trip to Abu Dhabi (United Arab Emirates), where Samantha's ex is filming a new movie.	2010	146	4.3	62403	95.33	27	579
954	954	The Kings of Summer	Three teenage friends, in the ultimate act of independence, decide to spend their summer building a house in the woods and living off the land.	2013	95	7.2	65653	1.29	61	617
955	955	Death Race	Ex-con Jensen Ames is forced by the warden of a notorious prison to compete in our post-industrial world's most popular sport: a car race in which inmates must brutalize and kill one another on the road to victory.	2008	105	6.4	173731	36.06	43	35
956	956	That Awkward Moment	Three best friends find themselves where we've all been - at that confusing moment in every dating relationship when you have to decide "So...where is this going?"	2014	94	6.2	81823	26.05	36	618
957	957	Legion	When a group of strangers at a dusty roadside diner come under attack by demonic forces, their only chance for survival lies with an archangel named Michael, who informs a pregnant waitress that her unborn child is humanity's last hope.	2010	100	5.2	84158	40.17	32	619
958	958	End of Watch	Shot documentary-style, this film follows the daily grind of two young police officers in LA who are partners and friends, and what happens when they meet criminal forces greater than themselves.	2012	109	7.7	192190	40.98	68	5
959	959	3 Days to Kill	A dying CIA agent trying to reconnect with his estranged daughter is offered an experimental drug that could save his life in exchange for one last assignment.	2014	117	6.2	73567	30.69	40	505
960	960	Lucky Number Slevin	A case of mistaken identity lands Slevin into the middle of a war being plotted by two of the city's most rival crime bosses: The Rabbi and The Boss. Slevin is under constant surveillance by relentless Detective Brikowski as well as the infamous assassin Goodkat and finds himself having to hatch his own ingenious plot to get them before they get him.	2006	110	7.8	271940	22.49	53	250
961	961	Trance	An art auctioneer who has become mixed up with a group of criminals partners with a hypnotherapist in order to recover a lost painting.	2013	101	7.0	97141	2.32	61	274
962	962	Into the Forest	After a massive power outage, two sisters learn to survive on their own in their isolated woodland home.	2015	101	5.9	10220	0.01	59	620
963	963	The Other Boleyn Girl	Two sisters contend for the affection of King Henry VIII.	2008	115	6.7	88260	26.81	50	621
964	964	I Spit on Your Grave	A writer who is brutalized during her cabin retreat seeks revenge on her attackers, who left her for dead.	2010	108	6.3	60133	0.09	27	622
965	965	Custody	The lives of three women are unexpectedly changed when they cross paths at a New York Family Court.	2016	104	6.9	280	\N	72	623
966	966	Inland Empire	As an actress starts to adopt the persona of her character in a film, her world starts to become nightmarish and surreal.	2006	180	7.0	44227	\N	\N	131
967	967	L'odyssée	Highly influential and a fearlessly ambitious pioneer, innovator, filmmaker, researcher and conservationist, Jacques-Yves Cousteau's aquatic adventure covers roughly thirty years of an inarguably rich in achievements life.	2016	122	6.7	1810	\N	70	624
968	968	The Walk	In 1974, high-wire artist Philippe Petit recruits a team of people to help him realize his dream: to walk the immense void between the World Trade Center towers.	2015	123	7.3	92378	10.14	\N	69
969	969	Wrecker	Best friends Emily and Lesley go on a road trip to the desert. When Emily decides to get off the highway and take a "short cut," they become the target of a relentless and psychotic trucker... See full summary »	2015	83	3.5	1210	\N	37	625
970	970	The Lone Ranger	Native American warrior Tonto recounts the untold tales that transformed John Reid, a man of the law, into a legend of justice.	2013	150	6.5	190855	89.29	\N	73
971	971	Texas Chainsaw 3D	A young woman travels to Texas to collect an inheritance; little does she know that an encounter with a chainsaw-wielding killer is part of the reward.	2013	92	4.8	37060	34.33	62	626
972	972	Disturbia	A teen living under house arrest becomes convinced his neighbor is a serial killer.	2007	105	6.9	193491	80.05	\N	192
973	973	Rock of Ages	A small town girl and a city boy meet on the Sunset Strip, while pursuing their Hollywood dreams.	2012	123	5.9	64513	38.51	47	352
974	974	Scream 4	Ten years have passed, and Sidney Prescott, who has put herself back together thanks in part to her writing, is visited by the Ghostface Killer.	2011	111	6.2	108544	38.18	52	627
975	975	Queen of Katwe	A Ugandan girl sees her world rapidly change after being introduced to the game of chess.	2016	124	7.4	6753	8.81	73	628
976	976	My Big Fat Greek Wedding 2	A Portokalos family secret brings the beloved characters back together for an even bigger and Greeker wedding.	2016	94	6.0	20966	59.57	37	410
977	977	Dark Places	Libby Day was only eight years old when her family was brutally murdered in their rural Kansas farmhouse. Almost thirty years later, she reluctantly agrees to revisit the crime and uncovers the wrenching truths that led up to that tragic night.	2015	113	6.2	31634	\N	39	629
978	978	Amateur Night	Guy Carter is an award-winning graduate student of architecture. He's got a beautiful wife and a baby on the way. The problem? He doesn't have "his ducks in a row," which only fuels his ... See full summary »	2016	92	5.0	2229	\N	38	630
979	979	It's Only the End of the World	Louis (Gaspard Ulliel), a terminally ill writer, returns home after a long absence to tell his family that he is dying.	2016	97	7.0	10658	\N	48	429
980	980	The Skin I Live In	A brilliant plastic surgeon, haunted by past tragedies, creates a type of synthetic skin that withstands any kind of damage. His guinea pig: a mysterious and volatile woman who holds the key to his obsession.	2011	120	7.6	108772	3.19	70	631
981	981	Miracles from Heaven	A young girl suffering from a rare digestive disorder finds herself miraculously cured after surviving a terrible accident.	2016	109	7.0	12048	61.69	44	632
982	982	Annie	A foster kid, who lives with her mean foster mom, sees her life change when business tycoon and New York mayoral candidate Will Stacks makes a thinly-veiled campaign move and takes her in.	2014	118	5.3	27312	85.91	33	366
983	983	Across the Universe	The music of the Beatles and the Vietnam War form the backdrop for the romance between an upper-class American girl and a poor Liverpudlian artist.	2007	133	7.4	95172	24.34	56	633
984	984	Let's Be Cops	Two struggling pals dress as police officers for a costume party and become neighborhood sensations. But when these newly-minted "heroes" get tangled in a real life web of mobsters and dirty detectives, they must put their fake badges on the line.	2014	104	6.5	112729	82.39	30	634
985	985	Max	A Malinois dog that helped American Marines in Afghanistan returns to the United States and is adopted by his handler's family after suffering a traumatic experience.	2015	111	6.8	21405	42.65	47	635
986	986	Your Highness	When Prince Fabious's bride is kidnapped, he goes on a quest to rescue her... accompanied by his lazy useless brother Thadeous.	2011	102	5.6	87904	21.56	31	460
987	987	Final Destination 5	Survivors of a suspension-bridge collapse learn there's no way you can cheat Death.	2011	92	5.9	88000	42.58	50	636
988	988	Endless Love	The story of a privileged girl and a charismatic boy whose instant desire sparks a love affair made only more reckless by parents trying to keep them apart.	2014	104	6.3	33688	23.39	30	637
989	989	Martyrs	A young woman's quest for revenge against the people who kidnapped and tormented her as a child leads her and a friend, who is also a victim of child abuse, on a terrifying journey into a living hell of depravity.	2008	99	7.1	63785	\N	89	638
990	990	Selma	A chronicle of Martin Luther King's campaign to secure equal voting rights via an epic march from Selma to Montgomery, Alabama in 1965.	2014	128	7.5	67637	52.07	\N	639
991	991	Underworld: Rise of the Lycans	An origins story centered on the centuries-old feud between the race of aristocratic vampires and their onetime slaves, the Lycans.	2009	92	6.6	129708	45.80	44	640
992	992	Taare Zameen Par	An eight-year-old boy is thought to be a lazy trouble-maker, until the new art teacher has the patience and compassion to discover the real problem behind his struggles in school.	2007	165	8.5	102697	1.20	42	641
993	993	Take Me Home Tonight	Four years after graduation, an awkward high school genius uses his sister's boyfriend's Labor Day party as the perfect opportunity to make his move on his high school crush.	2011	97	6.3	45419	6.92	\N	584
994	994	Resident Evil: Afterlife	While still out to destroy the evil Umbrella Corporation, Alice joins a group of survivors living in a prison surrounded by the infected who also want to relocate to the mysterious but supposedly unharmed safe haven known only as Arcadia.	2010	97	5.9	140900	60.13	37	35
995	995	Project X	3 high school seniors throw a birthday party to make a name for themselves. As the night progresses, things spiral out of control as word of the party spreads.	2012	88	6.7	164088	54.72	48	642
996	996	Secret in Their Eyes	A tight-knit team of rising investigators, along with their supervisor, is suddenly torn apart when they discover that one of their own teenage daughters has been brutally murdered.	2015	111	6.2	27585	\N	45	643
997	997	Hostel: Part II	Three American college students studying abroad are lured to a Slovakian hostel, and discover the grim reality behind it.	2007	94	5.5	73152	17.54	46	212
998	998	Step Up 2: The Streets	Romantic sparks occur between two dance students from different backgrounds at the Maryland School of the Arts.	2008	98	6.2	70699	58.01	50	141
999	999	Search Party	A pair of friends embark on a mission to reunite their pal with the woman he was going to marry.	2014	93	5.6	4881	\N	22	644
\.


--
-- Data for Name: pelicula_actor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelicula_actor (id_pelicula, id_actor, orden_reparto) FROM stdin;
1	1	1
1	2	2
1	3	3
1	4	4
2	5	1
2	6	2
2	7	3
2	8	4
3	9	1
3	10	2
3	11	3
3	12	4
4	13	1
4	14	2
4	15	3
4	16	4
5	17	1
5	18	2
5	19	3
5	20	4
6	21	1
6	22	2
6	23	3
6	24	4
7	25	1
7	26	2
7	27	3
7	28	4
8	29	1
8	30	2
8	31	3
8	32	4
9	33	1
9	34	2
9	35	3
9	36	4
10	37	1
10	1	2
10	38	3
10	39	4
11	40	1
11	41	2
11	42	3
11	43	4
12	44	1
12	45	2
12	46	3
12	47	4
13	48	1
13	49	2
13	50	3
13	51	4
14	52	1
14	53	2
14	54	3
14	55	4
15	56	1
15	57	2
15	58	3
15	59	4
16	60	1
16	61	2
16	62	3
16	63	4
17	64	1
17	65	2
17	66	3
17	67	4
18	21	1
18	68	2
18	69	3
18	70	4
19	71	1
19	72	2
19	73	3
19	74	4
20	75	1
20	76	2
20	77	3
20	78	4
21	13	1
21	79	2
21	80	3
21	81	4
22	82	1
22	83	2
22	84	3
22	85	4
23	86	1
23	87	2
23	88	3
23	89	4
24	90	1
24	91	2
24	92	3
24	93	4
25	94	1
25	95	2
25	96	3
25	97	4
26	98	1
26	99	2
26	100	3
26	101	4
27	102	1
27	103	2
27	104	3
27	105	4
28	106	1
28	107	2
28	108	3
28	109	4
29	110	1
29	111	2
29	112	3
29	113	4
30	7	1
30	114	2
30	115	3
30	116	4
31	117	1
31	118	2
31	119	3
31	120	4
32	75	1
32	121	2
32	122	3
32	123	4
33	9	1
33	7	2
33	37	3
33	124	4
34	125	1
34	126	2
34	127	3
34	128	4
35	129	1
35	130	2
35	131	3
35	132	4
36	133	1
36	134	2
36	16	3
36	135	4
37	13	1
37	56	2
37	136	3
37	137	4
38	138	1
38	139	2
38	140	3
38	141	4
39	142	1
39	1	2
39	143	3
39	144	4
40	145	1
40	146	2
40	147	3
40	148	4
41	149	1
41	150	2
41	151	3
41	152	4
42	153	1
42	154	2
42	155	3
42	156	4
43	157	1
43	158	2
43	159	3
43	160	4
44	161	1
44	162	2
44	163	3
44	164	4
45	165	1
45	166	2
45	167	3
45	168	4
46	169	1
46	170	2
46	171	3
46	172	4
47	136	1
47	173	2
47	174	3
47	78	4
48	175	1
48	176	2
48	177	3
48	178	4
49	179	1
49	180	2
49	181	3
49	4	4
50	8	1
50	182	2
50	183	3
50	184	4
51	185	1
51	186	2
51	187	3
51	188	4
52	189	1
52	190	2
52	191	3
52	192	4
53	193	1
53	194	2
53	195	3
53	57	4
54	196	1
54	197	2
54	198	3
54	23	4
55	199	1
55	200	2
55	201	3
55	202	4
56	64	1
56	203	2
56	204	3
56	205	4
57	206	1
57	207	2
57	208	3
57	209	4
58	210	1
58	211	2
58	212	3
58	213	4
59	214	1
59	211	2
59	215	3
59	216	4
60	217	1
60	201	2
60	218	3
60	219	4
61	220	1
61	221	2
61	75	3
61	222	4
62	223	1
62	224	2
62	225	3
62	226	4
63	227	1
63	228	2
63	229	3
63	230	4
64	231	1
64	232	2
64	233	3
64	234	4
65	199	1
65	235	2
65	16	3
65	202	4
66	236	1
66	237	2
66	238	3
66	202	4
67	239	1
67	240	2
67	28	3
67	241	4
68	242	1
68	8	2
68	124	3
68	243	4
69	244	1
69	245	2
69	246	3
69	247	4
70	239	1
70	248	2
70	249	3
70	250	4
71	187	1
71	251	2
71	199	3
71	252	4
72	253	1
72	114	2
72	184	3
72	254	4
73	255	1
73	256	2
73	48	3
73	257	4
74	17	1
74	258	2
74	259	3
74	260	4
75	261	1
75	262	2
75	263	3
75	264	4
76	169	1
76	265	2
76	266	3
76	172	4
77	134	1
77	133	2
77	16	3
77	76	4
78	253	1
78	267	2
78	268	3
78	269	4
79	169	1
79	265	2
79	266	3
79	270	4
80	271	1
80	150	2
80	272	3
80	273	4
81	274	1
81	275	2
81	276	3
81	277	4
82	278	1
82	279	2
82	280	3
82	281	4
83	274	1
83	151	2
83	19	3
83	13	4
84	220	1
84	282	2
84	283	3
84	284	4
85	2	1
85	285	2
85	53	3
85	286	4
86	1	1
86	80	2
86	287	3
86	288	4
87	220	1
87	289	2
87	116	3
87	290	4
88	65	1
88	4	2
88	256	3
88	291	4
89	238	1
89	248	2
89	292	3
89	293	4
90	220	1
90	90	2
90	28	3
90	294	4
91	235	1
91	121	2
91	20	3
91	295	4
92	296	1
92	297	2
92	298	3
92	299	4
93	26	1
93	20	2
93	45	3
93	80	4
94	151	1
94	300	2
94	301	3
94	302	4
95	134	1
95	133	2
95	303	3
95	304	4
96	305	1
96	25	2
96	306	3
96	307	4
97	308	1
97	309	2
97	310	3
97	311	4
98	312	1
98	313	2
98	314	3
98	315	4
99	316	1
99	317	2
99	318	3
99	319	4
100	274	1
100	21	2
100	320	3
100	239	4
101	242	1
101	321	2
101	237	3
101	322	4
102	304	1
102	323	2
102	324	3
102	325	4
103	21	1
103	136	2
103	150	3
103	326	4
104	327	1
104	328	2
104	329	3
104	330	4
105	221	1
105	331	2
105	69	3
105	332	4
106	179	1
106	298	2
106	333	3
106	334	4
107	335	1
107	336	2
107	337	3
107	338	4
108	339	1
108	340	2
108	341	3
108	342	4
109	343	1
109	344	2
109	345	3
109	346	4
110	69	1
110	188	2
110	187	3
110	347	4
111	348	1
111	349	2
111	350	3
111	351	4
112	139	1
112	352	2
112	7	3
112	253	4
113	196	1
113	353	2
113	354	3
113	49	4
114	355	1
114	356	2
114	357	3
114	358	4
115	359	1
115	360	2
115	361	3
115	362	4
116	262	1
116	363	2
116	127	3
116	193	4
117	289	1
117	364	2
117	196	3
117	365	4
118	366	1
118	367	2
118	368	3
118	369	4
119	241	1
119	370	2
119	348	3
119	249	4
120	371	1
120	372	2
120	373	3
120	374	4
121	375	1
121	376	2
121	238	3
121	377	4
122	378	1
122	190	2
122	259	3
122	379	4
123	380	1
123	381	2
123	90	3
123	382	4
124	383	1
124	384	2
124	385	3
124	386	4
125	199	1
125	242	2
125	56	3
125	387	4
126	388	1
126	389	2
126	390	3
126	263	4
127	239	1
127	391	2
127	392	3
127	393	4
128	394	1
128	395	2
128	396	3
128	397	4
129	398	1
129	399	2
129	400	3
129	401	4
130	274	1
130	242	2
130	402	3
130	188	4
131	142	1
131	20	2
131	403	3
131	404	4
132	90	1
132	398	2
132	179	3
132	227	4
133	405	1
133	406	2
133	407	3
133	408	4
134	300	1
134	28	2
134	409	3
134	410	4
135	2	1
135	285	2
135	53	3
135	291	4
136	25	1
136	3	2
136	411	3
136	412	4
137	68	1
137	182	2
137	413	3
137	414	4
138	274	1
138	415	2
138	416	3
138	417	4
139	274	1
139	418	2
139	303	3
139	390	4
140	419	1
140	420	2
140	421	3
140	422	4
141	179	1
141	180	2
141	423	3
141	424	4
142	425	1
142	426	2
142	427	3
142	428	4
143	199	1
143	429	2
143	25	3
143	253	4
144	430	1
144	431	2
144	432	3
144	433	4
145	434	1
145	342	2
145	274	3
145	435	4
146	436	1
146	437	2
146	438	3
146	439	4
147	440	1
147	11	2
147	441	3
147	442	4
148	443	1
148	444	2
148	445	3
148	446	4
149	447	1
149	151	2
149	93	3
149	448	4
150	217	1
150	48	2
150	449	3
150	298	4
151	450	1
151	451	2
151	452	3
151	453	4
152	37	1
152	454	2
152	94	3
152	393	4
153	455	1
153	456	2
153	457	3
153	458	4
154	227	1
154	413	2
154	459	3
154	294	4
155	460	1
155	461	2
155	462	3
155	463	4
156	464	1
156	465	2
156	466	3
156	467	4
157	263	1
157	33	2
157	468	3
157	469	4
158	429	1
158	25	2
158	470	3
158	26	4
159	447	1
159	370	2
159	471	3
159	472	4
160	423	1
160	473	2
160	474	3
160	215	4
161	331	1
161	475	2
161	476	3
161	477	4
162	478	1
162	430	2
162	331	3
162	479	4
163	480	1
163	481	2
163	235	3
163	9	4
164	482	1
164	483	2
164	484	3
164	485	4
165	486	1
165	375	2
165	377	3
165	487	4
166	316	1
166	34	2
166	488	3
166	489	4
167	222	1
167	303	2
167	414	3
167	395	4
168	490	1
168	125	2
168	491	3
168	492	4
169	493	1
169	494	2
169	495	3
169	496	4
170	486	1
170	342	2
170	497	3
170	498	4
171	121	1
171	499	2
171	500	3
171	501	4
172	8	1
172	502	2
172	13	3
172	498	4
173	503	1
173	504	2
173	505	3
173	506	4
174	507	1
174	75	2
174	16	3
174	73	4
175	112	1
175	508	2
175	509	3
175	510	4
176	511	1
176	512	2
176	513	3
176	514	4
177	387	1
177	515	2
177	516	3
177	517	4
178	518	1
178	519	2
178	134	3
178	520	4
179	521	1
179	444	2
179	522	3
179	523	4
180	524	1
180	525	2
180	81	3
180	526	4
181	527	1
181	528	2
181	529	3
181	530	4
182	10	1
182	531	2
182	532	3
182	533	4
183	534	1
183	535	2
183	536	3
183	537	4
184	538	1
184	251	2
184	539	3
184	540	4
185	541	1
185	542	2
185	543	3
185	544	4
186	545	1
186	365	2
186	546	3
186	547	4
187	548	1
187	549	2
187	550	3
187	551	4
188	552	1
188	136	2
188	325	3
188	33	4
189	25	1
189	415	2
189	244	3
189	372	4
190	553	1
190	448	2
190	430	3
190	554	4
191	7	1
191	69	2
191	555	3
191	556	4
192	557	1
192	558	2
192	559	3
192	560	4
193	303	1
193	161	2
193	140	3
193	561	4
194	326	1
194	10	2
194	562	3
194	563	4
195	242	1
195	564	2
195	416	3
195	565	4
196	133	1
196	566	2
196	238	3
196	567	4
197	568	1
197	569	2
197	570	3
197	571	4
198	224	1
198	572	2
198	573	3
198	574	4
199	138	1
199	266	2
199	575	3
199	576	4
200	53	1
200	62	2
200	577	3
200	578	4
201	482	1
201	227	2
201	500	3
201	116	4
202	579	1
202	580	2
202	581	3
202	582	4
203	275	1
203	378	2
203	295	3
203	180	4
204	134	1
204	583	2
204	584	3
204	333	4
205	378	1
205	190	2
205	585	3
205	586	4
206	9	1
206	7	2
206	37	3
206	587	4
207	588	1
207	589	2
207	590	3
207	591	4
208	203	1
208	592	2
208	593	3
208	594	4
209	150	1
209	595	2
209	596	3
209	597	4
210	214	1
210	598	2
210	599	3
210	600	4
211	53	1
211	445	2
211	601	3
211	602	4
212	603	1
212	604	2
212	605	3
212	606	4
213	607	1
213	608	2
213	609	3
213	610	4
214	413	1
214	611	2
214	238	3
214	478	4
215	304	1
215	324	2
215	325	3
215	401	4
216	612	1
216	613	2
216	355	3
216	614	4
217	133	1
217	238	2
217	16	3
217	615	4
218	616	1
218	207	2
218	617	3
218	618	4
219	619	1
219	620	2
219	621	3
219	622	4
220	123	1
220	623	2
220	624	3
220	625	4
221	478	1
221	626	2
221	228	3
221	627	4
222	628	1
222	629	2
222	630	3
222	631	4
223	97	1
223	632	2
223	633	3
223	634	4
224	486	1
224	73	2
224	635	3
224	401	4
225	57	1
225	193	2
225	394	3
225	636	4
226	637	1
226	607	2
226	638	3
226	639	4
227	640	1
227	555	2
227	641	3
227	642	4
228	643	1
228	39	2
228	644	3
228	645	4
229	646	1
229	289	2
229	478	3
229	647	4
230	5	1
230	648	2
230	649	3
230	650	4
231	651	1
231	652	2
231	653	3
231	654	4
232	444	1
232	655	2
232	228	3
232	656	4
233	657	1
233	658	2
233	659	3
233	660	4
234	482	1
234	229	2
234	76	3
234	423	4
235	304	1
235	136	2
235	8	3
235	227	4
236	661	1
236	360	2
236	662	3
236	524	4
237	324	1
237	663	2
237	664	3
237	665	4
238	189	1
238	666	2
238	667	3
238	616	4
239	498	1
239	668	2
239	669	3
239	643	4
240	670	1
240	671	2
240	672	3
240	267	4
241	253	1
241	607	2
241	661	3
241	260	4
242	673	1
242	448	2
242	674	3
242	675	4
243	676	1
243	677	2
243	28	3
243	674	4
244	678	1
244	679	2
244	210	3
244	379	4
245	661	1
245	680	2
245	681	3
245	682	4
246	235	1
246	305	2
246	56	3
246	400	4
247	470	1
247	683	2
247	139	3
247	202	4
248	684	1
248	289	2
248	664	3
248	665	4
249	271	1
249	596	2
249	685	3
249	286	4
250	686	1
250	687	2
250	688	3
250	689	4
251	690	1
251	691	2
251	692	3
251	693	4
252	694	1
252	695	2
252	696	3
252	697	4
253	698	1
253	699	2
253	700	3
253	701	4
254	64	1
254	26	2
254	434	3
254	702	4
255	444	1
255	521	2
255	703	3
255	704	4
256	705	1
256	3	2
256	457	3
256	636	4
257	339	1
257	706	2
257	204	3
257	707	4
258	118	1
258	516	2
258	708	3
258	709	4
259	67	1
259	710	2
259	711	3
259	488	4
260	712	1
260	713	2
260	38	3
260	714	4
261	161	1
261	705	2
261	258	3
261	30	4
262	324	1
262	110	2
262	70	3
262	715	4
263	716	1
263	717	2
263	718	3
263	719	4
264	714	1
264	401	2
264	720	3
264	607	4
265	608	1
265	721	2
265	284	3
265	218	4
266	196	1
266	722	2
266	723	3
266	724	4
267	335	1
267	380	2
267	117	3
267	382	4
268	217	1
268	725	2
268	726	3
268	566	4
269	235	1
269	561	2
269	125	3
269	727	4
270	728	1
270	729	2
270	730	3
270	731	4
271	486	1
271	182	2
271	732	3
271	377	4
272	474	1
272	481	2
272	733	3
272	516	4
273	151	1
273	734	2
273	735	3
273	430	4
274	736	1
274	737	2
274	738	3
274	392	4
275	289	1
275	579	2
275	739	3
275	740	4
276	482	1
276	741	2
276	30	3
276	742	4
277	734	1
277	151	2
277	735	3
277	162	4
278	121	1
278	134	2
278	303	3
278	743	4
279	441	1
279	744	2
279	745	3
279	117	4
280	134	1
280	420	2
280	583	3
280	746	4
281	222	1
281	747	2
281	303	3
281	414	4
282	134	1
282	685	2
282	140	3
282	173	4
283	248	1
283	748	2
283	749	3
283	750	4
284	40	1
284	69	2
284	751	3
284	752	4
285	53	1
285	753	2
285	171	3
285	754	4
286	321	1
286	603	2
286	755	3
286	756	4
287	705	1
287	757	2
287	758	3
287	759	4
288	734	1
288	110	2
288	40	3
288	760	4
289	705	1
289	150	2
289	628	3
289	761	4
290	762	1
290	251	2
290	763	3
290	764	4
291	765	1
291	766	2
291	767	3
291	768	4
292	90	1
292	769	2
292	770	3
292	771	4
293	149	1
293	596	2
293	380	3
293	624	4
294	534	1
294	379	2
294	635	3
294	772	4
295	221	1
295	75	2
295	122	3
295	690	4
296	773	1
296	67	2
296	601	3
296	774	4
297	775	1
297	776	2
297	777	3
297	778	4
298	56	1
298	398	2
298	779	3
298	227	4
299	244	1
299	777	2
299	267	3
299	578	4
300	780	1
300	781	2
300	782	3
300	783	4
301	142	1
301	784	2
301	624	3
301	785	4
302	239	1
302	786	2
302	224	3
302	298	4
303	787	1
303	304	2
303	788	3
303	789	4
304	790	1
304	791	2
304	26	3
304	792	4
305	793	1
305	794	2
305	127	3
305	795	4
306	507	1
306	413	2
306	628	3
306	41	4
307	552	1
307	169	2
307	537	3
307	56	4
308	224	1
308	243	2
308	117	3
308	796	4
309	797	1
309	798	2
309	799	3
309	800	4
310	231	1
310	770	2
310	336	3
310	801	4
311	802	1
311	803	2
311	804	3
311	805	4
312	497	1
312	183	2
312	806	3
312	807	4
313	29	1
313	808	2
313	809	3
313	810	4
314	481	1
314	474	2
314	733	3
314	535	4
315	359	1
315	360	2
315	361	3
315	116	4
316	133	1
316	811	2
316	812	3
316	813	4
317	624	1
317	814	2
317	815	3
317	816	4
318	817	1
318	818	2
318	819	3
318	820	4
319	821	1
319	822	2
319	823	3
319	824	4
320	2	1
320	285	2
320	53	3
320	825	4
321	734	1
321	826	2
321	827	3
321	828	4
322	638	1
322	756	2
322	829	3
322	830	4
323	355	1
323	831	2
323	263	3
323	832	4
324	91	1
324	400	2
324	479	3
324	833	4
325	222	1
325	64	2
325	91	3
325	73	4
326	2	1
326	562	2
326	834	3
326	835	4
327	359	1
327	9	2
327	836	3
327	837	4
328	838	1
328	839	2
328	840	3
328	841	4
329	842	1
329	843	2
329	844	3
329	480	4
330	304	1
330	20	2
330	845	3
330	846	4
331	847	1
331	848	2
331	849	3
331	193	4
332	3	1
332	35	2
332	718	3
332	850	4
333	13	1
333	245	2
333	18	3
333	428	4
334	780	1
334	851	2
334	852	3
334	275	4
335	491	1
335	304	2
335	833	3
335	853	4
336	854	1
336	855	2
336	431	3
336	856	4
337	3	1
337	37	2
337	335	3
337	857	4
338	858	1
338	859	2
338	860	3
338	861	4
339	378	1
339	862	2
339	863	3
339	864	4
340	865	1
340	866	2
340	867	3
340	868	4
341	2	1
341	285	2
341	291	3
341	825	4
342	275	1
342	869	2
342	227	3
342	781	4
343	734	1
343	434	2
343	870	3
343	679	4
344	80	1
344	615	2
344	871	3
344	872	4
345	417	1
345	873	2
345	644	3
345	874	4
346	661	1
346	875	2
346	876	3
346	129	4
347	877	1
347	878	2
347	35	3
347	481	4
348	199	1
348	75	2
348	3	3
348	37	4
349	608	1
349	400	2
349	879	3
349	880	4
350	628	1
350	140	2
350	881	3
350	882	4
351	883	1
351	884	2
351	885	3
351	886	4
352	37	1
352	335	2
352	3	3
352	79	4
353	259	1
353	887	2
353	94	3
353	566	4
354	222	1
354	316	2
354	429	3
354	405	4
355	378	1
355	862	2
355	190	3
355	259	4
356	888	1
356	470	2
356	333	3
356	69	4
357	687	1
357	889	2
357	890	3
357	891	4
358	40	1
358	48	2
358	892	3
358	893	4
359	118	1
359	151	2
359	149	3
359	793	4
360	188	1
360	140	2
360	215	3
360	894	4
361	895	1
361	896	2
361	897	3
361	898	4
362	899	1
362	900	2
362	650	3
362	901	4
363	179	1
363	180	2
363	4	3
363	138	4
364	222	1
364	26	2
364	414	3
364	902	4
365	413	1
365	511	2
365	903	3
365	498	4
366	71	1
366	708	2
366	904	3
366	905	4
367	316	1
367	34	2
367	906	3
367	907	4
368	908	1
368	909	2
368	910	3
368	911	4
369	64	1
369	26	2
369	912	3
369	449	4
370	216	1
370	257	2
370	913	3
370	914	4
371	915	1
371	916	2
371	917	3
371	918	4
372	919	1
372	920	2
372	402	3
372	921	4
373	47	1
373	125	2
373	759	3
373	387	4
374	646	1
374	9	2
374	741	3
374	922	4
375	398	1
375	726	2
375	923	3
375	229	4
376	124	1
376	48	2
376	323	3
376	390	4
377	169	1
377	138	2
377	231	3
377	416	4
378	924	1
378	925	2
378	717	3
378	926	4
379	781	1
379	359	2
379	370	3
379	927	4
380	925	1
380	286	2
380	928	3
380	929	4
381	453	1
381	930	2
381	931	3
381	932	4
382	121	1
382	140	2
382	872	3
382	77	4
383	348	1
383	933	2
383	934	3
383	935	4
384	217	1
384	450	2
384	936	3
384	578	4
385	1	1
385	895	2
385	937	3
385	721	4
386	679	1
386	938	2
386	939	3
386	940	4
387	865	1
387	941	2
387	240	3
387	942	4
388	305	1
388	535	2
388	875	3
388	943	4
389	235	1
389	944	2
389	945	3
389	946	4
390	786	1
390	947	2
390	23	3
390	948	4
391	949	1
391	950	2
391	951	3
391	952	4
392	953	1
392	263	2
392	954	3
392	182	4
393	7	1
393	259	2
393	149	3
393	585	4
394	955	1
394	956	2
394	957	3
394	958	4
395	865	1
395	941	2
395	959	3
395	960	4
396	405	1
396	961	2
396	962	3
396	963	4
397	258	1
397	964	2
397	626	3
397	965	4
398	572	1
398	446	2
398	966	3
398	262	4
399	423	1
399	189	2
399	967	3
399	968	4
400	734	1
400	969	2
400	363	3
400	13	4
401	803	1
401	758	2
401	161	3
401	970	4
402	971	1
402	972	2
402	973	3
402	974	4
403	242	1
403	975	2
403	976	3
403	977	4
404	429	1
404	978	2
404	979	3
404	980	4
405	981	1
405	240	2
405	66	3
405	982	4
406	6	1
406	983	2
406	961	3
406	984	4
407	136	1
407	416	2
407	1	3
407	173	4
408	985	1
408	986	2
408	987	3
408	988	4
409	37	1
409	454	2
409	94	3
409	414	4
410	636	1
410	113	2
410	989	3
410	990	4
411	204	1
411	774	2
411	991	3
411	992	4
412	90	1
412	770	2
412	440	3
412	769	4
413	993	1
413	241	2
413	994	3
413	490	4
414	995	1
414	996	2
414	997	3
414	998	4
415	286	1
415	999	2
415	68	3
415	1000	4
416	1001	1
416	1002	2
416	1003	3
416	1004	4
417	801	1
417	355	2
417	23	3
417	1005	4
418	266	1
418	9	2
418	1006	3
418	670	4
419	359	1
419	360	2
419	361	3
419	215	4
420	7	1
420	415	2
420	495	3
420	1007	4
421	670	1
421	535	2
421	1008	3
421	1009	4
422	1010	1
422	1011	2
422	1012	3
422	1013	4
423	534	1
423	1014	2
423	216	3
423	1015	4
424	1016	1
424	375	2
424	356	3
424	1017	4
425	355	1
425	201	2
425	741	3
425	1018	4
426	253	1
426	535	2
426	812	3
426	1019	4
427	1020	1
427	999	2
427	413	3
427	275	4
428	21	1
428	79	2
428	1021	3
428	1022	4
429	1023	1
429	1024	2
429	1025	3
429	1026	4
430	1027	1
430	1028	2
430	1029	3
430	1030	4
431	366	1
431	1031	2
431	1032	3
431	1033	4
432	518	1
432	628	2
432	170	3
432	895	4
433	253	1
433	1034	2
433	1035	3
433	495	4
434	482	1
434	76	2
434	423	3
434	297	4
435	1036	1
435	1037	2
435	1038	3
435	1039	4
436	9	1
436	811	2
436	1040	3
436	843	4
437	1041	1
437	512	2
437	936	3
437	216	4
438	586	1
438	1042	2
438	36	3
438	1043	4
439	123	1
439	624	2
439	93	3
439	354	4
440	1044	1
440	1045	2
440	1046	3
440	1047	4
441	118	1
441	83	2
441	555	3
441	110	4
442	670	1
442	796	2
442	188	3
442	529	4
443	419	1
443	1048	2
443	1049	3
443	1050	4
444	25	1
444	83	2
444	1051	3
444	1052	4
445	1053	1
445	1054	2
445	910	3
445	1055	4
446	1056	1
446	1057	2
446	760	3
446	1058	4
447	181	1
447	1059	2
447	356	3
447	1060	4
448	1061	1
448	1062	2
448	1063	3
448	54	4
449	1064	1
449	1065	2
449	1066	3
449	127	4
450	624	1
450	470	2
450	1067	3
450	1068	4
451	134	1
451	1020	2
451	583	3
451	746	4
452	121	1
452	586	2
452	1069	3
452	1070	4
453	1071	1
453	298	2
453	1072	3
453	1073	4
454	355	1
454	201	2
454	741	3
454	1018	4
455	969	1
455	1074	2
455	1075	3
455	67	4
456	1076	1
456	1077	2
456	1078	3
456	1079	4
457	803	1
457	125	2
457	897	3
457	1080	4
458	895	1
458	62	2
458	801	3
458	1081	4
459	865	1
459	193	2
459	706	3
459	72	4
460	274	1
460	259	2
460	1082	3
460	1083	4
461	220	1
461	1084	2
461	758	3
461	76	4
462	1085	1
462	1086	2
462	1087	3
462	1088	4
463	555	1
463	831	2
463	1089	3
463	837	4
464	143	1
464	1090	2
464	1091	3
464	1092	4
465	519	1
465	208	2
465	1093	3
465	1094	4
466	134	1
466	685	2
466	184	3
466	140	4
467	646	1
467	561	2
467	139	3
467	1095	4
468	121	1
468	269	2
468	1096	3
468	1097	4
469	478	1
469	1098	2
469	1099	3
469	1100	4
470	895	1
470	239	2
470	1101	3
470	411	4
471	142	1
471	305	2
471	139	3
471	413	4
472	873	1
472	1102	2
472	1103	3
472	887	4
473	1104	1
473	832	2
473	139	3
473	1105	4
474	359	1
474	360	2
474	361	3
474	362	4
475	220	1
475	244	2
475	241	3
475	1106	4
476	237	1
476	235	2
476	1107	3
476	1108	4
477	1109	1
477	1110	2
477	1111	3
477	1112	4
478	1113	1
478	1114	2
478	1115	3
478	1116	4
479	844	1
479	1117	2
479	1118	3
479	1119	4
480	7	1
480	114	2
480	1120	3
480	1121	4
481	112	1
481	978	2
481	524	3
481	110	4
482	612	1
482	333	2
482	398	3
482	1122	4
483	82	1
483	139	2
483	1123	3
483	1124	4
484	1125	1
484	1126	2
484	1127	3
484	1128	4
485	57	1
485	510	2
485	1129	3
485	595	4
486	1130	1
486	1131	2
486	869	3
486	389	4
487	1132	1
487	1133	2
487	1134	3
487	1135	4
488	1136	1
488	609	2
488	483	3
488	1137	4
489	17	1
489	19	2
489	913	3
489	458	4
490	1138	1
490	1139	2
490	1140	3
490	1141	4
491	817	1
491	818	2
491	1142	3
491	1143	4
492	142	1
492	110	2
492	876	3
492	387	4
493	795	1
493	1144	2
493	1145	3
493	127	4
494	79	1
494	66	2
494	1146	3
494	67	4
495	16	1
495	1147	2
495	1148	3
495	1149	4
496	17	1
496	645	2
496	1150	3
496	1151	4
497	17	1
497	68	2
497	413	3
497	453	4
498	289	1
498	1152	2
498	84	3
498	1153	4
499	355	1
499	434	2
499	1154	3
499	1155	4
500	1156	1
500	1157	2
500	1158	3
500	635	4
501	919	1
501	920	2
501	921	3
501	1159	4
502	535	1
502	73	2
502	1160	3
502	84	4
503	359	1
503	1161	2
503	1162	3
503	1163	4
504	202	1
504	1164	2
504	555	3
504	1165	4
505	18	1
505	1166	2
505	267	3
505	1167	4
506	501	1
506	1168	2
506	1169	3
506	1170	4
507	123	1
507	786	2
507	405	3
507	459	4
508	92	1
508	275	2
508	1171	3
508	624	4
509	26	1
509	1172	2
509	712	3
509	561	4
510	803	1
510	511	2
510	813	3
510	1173	4
511	376	1
511	1174	2
511	1175	3
511	1176	4
512	239	1
512	260	2
512	1177	3
512	1178	4
513	239	1
513	92	2
513	777	3
513	1179	4
514	248	1
514	444	2
514	1180	3
514	898	4
515	734	1
515	1181	2
515	307	3
515	1182	4
516	26	1
516	1183	2
516	1184	3
516	1185	4
517	199	1
517	416	2
517	390	3
517	256	4
518	478	1
518	71	2
518	235	3
518	256	4
519	481	1
519	474	2
519	733	3
519	1186	4
520	139	1
520	832	2
520	1187	3
520	1188	4
521	232	1
521	479	2
521	1189	3
521	1190	4
522	7	1
522	170	2
522	1191	3
522	182	4
523	1192	1
523	1193	2
523	1194	3
523	1195	4
524	1196	1
524	19	2
524	474	3
524	1119	4
525	683	1
525	573	2
525	982	3
525	679	4
526	1197	1
526	1198	2
526	1199	3
526	1200	4
527	21	1
527	1201	2
527	478	3
527	645	4
528	722	1
528	1202	2
528	724	3
528	1203	4
529	123	1
529	611	2
529	244	3
529	277	4
530	76	1
530	555	2
530	258	3
530	1204	4
531	305	1
531	755	2
531	1205	3
531	114	4
532	1206	1
532	1207	2
532	817	3
532	1208	4
533	142	1
533	297	2
533	1209	3
533	1210	4
534	16	1
534	741	2
534	1211	3
534	1212	4
535	1213	1
535	233	2
535	1214	3
535	1215	4
536	1124	1
536	299	2
536	843	3
536	1216	4
537	482	1
537	282	2
537	898	3
537	1217	4
538	865	1
538	960	2
538	297	3
538	111	4
539	354	1
539	714	2
539	784	3
539	1218	4
540	1042	1
540	1219	2
540	419	3
540	1220	4
541	1042	1
541	399	2
541	1221	3
541	294	4
542	3	1
542	1222	2
542	755	3
542	335	4
543	495	1
543	418	2
543	1223	3
543	1224	4
544	1225	1
544	355	2
544	1226	3
544	1227	4
545	444	1
545	356	2
545	1146	3
545	1228	4
546	122	1
546	416	2
546	873	3
546	203	4
547	949	1
547	1229	2
547	1230	3
547	1231	4
548	552	1
548	169	2
548	537	3
548	56	4
549	1232	1
549	586	2
549	988	3
549	561	4
550	1233	1
550	1234	2
550	1235	3
550	1236	4
551	193	1
551	572	2
551	966	3
551	1237	4
552	1238	1
552	416	2
552	1239	3
552	1240	4
553	300	1
553	326	2
553	924	3
553	811	4
554	581	1
554	1241	2
554	540	3
554	1242	4
555	360	1
555	491	2
555	197	3
555	1243	4
556	1244	1
556	745	2
556	1245	3
556	1246	4
557	262	1
557	1084	2
557	416	3
557	1247	4
558	1248	1
558	299	2
558	1096	3
558	502	4
559	304	1
559	479	2
559	116	3
559	752	4
560	676	1
560	595	2
560	1249	3
560	597	4
561	925	1
561	286	2
561	928	3
561	1250	4
562	207	1
562	1251	2
562	1144	3
562	1252	4
563	143	1
563	1253	2
563	1254	3
563	1255	4
564	896	1
564	1256	2
564	1257	3
564	1258	4
565	316	1
565	304	2
565	8	3
565	211	4
566	1259	1
566	235	2
566	549	3
566	73	4
567	607	1
567	1260	2
567	610	3
567	609	4
568	276	1
568	447	2
568	245	3
568	262	4
569	217	1
569	1261	2
569	752	3
569	1262	4
570	511	1
570	195	2
570	1263	3
570	358	4
571	1191	1
571	336	2
571	1264	3
571	613	4
572	75	1
572	1265	2
572	981	3
572	1266	4
573	335	1
573	56	2
573	499	3
573	1267	4
574	429	1
574	1161	2
574	1268	3
574	902	4
575	300	1
575	201	2
575	1269	3
575	782	4
576	65	1
576	204	2
576	498	3
576	1270	4
577	179	1
577	82	2
577	298	3
577	1008	4
578	333	1
578	549	2
578	833	3
578	1271	4
579	37	1
579	454	2
579	94	3
579	1272	4
580	25	1
580	873	2
580	1273	3
580	1274	4
581	1275	1
581	1276	2
581	1277	3
581	1278	4
582	1279	1
582	391	2
582	1280	3
582	71	4
583	978	1
583	1191	2
583	1281	3
583	1282	4
584	1191	1
584	1283	2
584	1284	3
584	1071	4
585	253	1
585	1285	2
585	151	3
585	1272	4
586	623	1
586	411	2
586	1286	3
586	1287	4
587	1263	1
587	1288	2
587	188	3
587	549	4
588	221	1
588	1020	2
588	753	3
588	1289	4
589	479	1
589	596	2
589	133	3
589	1000	4
590	1290	1
590	1291	2
590	1292	3
590	1293	4
591	197	1
591	5	2
591	1294	3
591	1295	4
592	586	1
592	1285	2
592	1296	3
592	1297	4
593	242	1
593	5	2
593	1298	3
593	1299	4
594	1183	1
594	1300	2
594	734	3
594	1301	4
595	895	1
595	239	2
595	164	3
595	874	4
596	517	1
596	624	2
596	898	3
596	1302	4
597	1303	1
597	1304	2
597	751	3
597	1072	4
598	1305	1
598	173	2
598	770	3
598	1306	4
599	1307	1
599	1308	2
599	1309	3
599	1310	4
600	895	1
600	151	2
600	253	3
600	1196	4
601	953	1
601	25	2
601	26	3
601	1311	4
602	1312	1
602	1313	2
602	49	3
602	1002	4
603	193	1
603	1219	2
603	1314	3
603	1315	4
604	519	1
604	244	2
604	1316	3
604	646	4
605	1317	1
605	1318	2
605	1319	3
605	1320	4
606	1321	1
606	1322	2
606	837	3
606	1323	4
607	37	1
607	1324	2
607	1325	3
607	1326	4
608	262	1
608	469	2
608	57	3
608	1327	4
609	1328	1
609	1329	2
609	1330	3
609	1331	4
610	988	1
610	1332	2
610	1333	3
610	1334	4
611	1335	1
611	20	2
611	1292	3
611	903	4
612	1336	1
612	1337	2
612	1338	3
612	1339	4
613	555	1
613	239	2
613	670	3
613	1265	4
614	253	1
614	82	2
614	1340	3
614	1341	4
615	275	1
615	16	2
615	470	3
615	1342	4
616	263	1
616	536	2
616	251	3
616	1343	4
617	1344	1
617	1345	2
617	1346	3
617	1347	4
618	13	1
618	174	2
618	153	3
618	515	4
619	90	1
619	1307	2
619	626	3
619	1254	4
620	518	1
620	150	2
620	1348	3
620	111	4
621	1349	1
621	168	2
621	1350	3
621	1351	4
622	189	1
622	1352	2
622	1353	3
622	1354	4
623	23	1
623	714	2
623	1355	3
624	1356	1
624	1357	2
624	1358	3
624	1359	4
625	204	1
625	77	2
625	774	3
625	991	4
626	640	1
626	1360	2
626	244	3
626	189	4
627	480	1
627	235	2
627	725	3
627	991	4
628	1361	1
628	1362	2
628	1363	3
628	1364	4
629	196	1
629	527	2
629	174	3
629	911	4
630	518	1
630	1365	2
630	628	3
630	1366	4
631	121	1
631	56	2
631	288	3
631	1367	4
632	118	1
632	149	2
632	1368	3
632	1145	4
633	1369	1
633	1370	2
633	1371	3
633	1372	4
634	1373	1
634	1374	2
634	1375	3
634	1376	4
635	1377	1
635	1378	2
635	1379	3
635	1380	4
636	149	1
636	1381	2
636	524	3
636	336	4
637	121	1
637	240	2
637	521	3
637	487	4
638	242	1
638	607	2
638	420	3
638	679	4
639	1382	1
639	1383	2
639	1384	3
639	1385	4
640	1386	1
640	1387	2
640	1388	3
640	1389	4
641	17	1
641	832	2
641	1390	3
641	1391	4
642	1392	1
642	1393	2
642	1394	3
642	1395	4
643	865	1
643	597	2
643	1396	3
643	906	4
644	1397	1
644	1398	2
644	1399	3
644	1400	4
645	1401	1
645	1402	2
645	1403	3
645	1404	4
646	1405	1
646	1406	2
646	1407	3
646	1408	4
647	3	1
647	35	2
647	491	3
647	1409	4
648	1410	1
648	1411	2
648	1412	3
648	1413	4
649	321	1
649	1414	2
649	1415	3
649	1416	4
650	117	1
650	1417	2
650	627	3
650	1418	4
651	169	1
651	537	2
651	1419	3
651	1089	4
652	323	1
652	1420	2
652	755	3
652	640	4
653	444	1
653	596	2
653	287	3
653	973	4
654	847	1
654	1421	2
654	1422	3
654	1258	4
655	957	1
655	1423	2
655	1424	3
655	1425	4
656	199	1
656	169	2
656	1426	3
656	679	4
657	1427	1
657	1428	2
657	143	3
657	1429	4
658	608	1
658	721	2
658	908	3
658	1430	4
659	586	1
659	278	2
659	1431	3
659	1432	4
660	172	1
660	1433	2
660	1061	3
660	1415	4
661	149	1
661	118	2
661	1434	3
661	1129	4
662	919	1
662	512	2
662	1435	3
662	1297	4
663	741	1
663	813	2
663	82	3
663	240	4
664	803	1
664	1436	2
664	271	3
664	166	4
665	995	1
665	1437	2
665	1438	3
665	1439	4
666	266	1
666	685	2
666	123	3
666	875	4
667	143	1
667	1174	2
667	360	3
667	1440	4
668	239	1
668	15	2
668	400	3
668	1441	4
669	239	1
669	53	2
669	1123	3
669	1442	4
670	274	1
670	1304	2
670	1219	3
670	1443	4
671	236	1
671	14	2
671	1444	3
671	1445	4
672	242	1
672	387	2
672	5	3
672	1446	4
673	76	1
673	1123	2
673	1447	3
673	420	4
674	125	1
674	405	2
674	663	3
674	173	4
675	339	1
675	260	2
675	190	3
675	717	4
676	855	1
676	574	2
676	1057	3
676	1448	4
677	925	1
677	678	2
677	1449	3
677	144	4
678	1450	1
678	211	2
678	1451	3
678	1452	4
679	1453	1
679	1454	2
679	1455	3
679	1456	4
680	1457	1
680	765	2
680	1369	3
680	1458	4
681	37	1
681	454	2
681	94	3
681	414	4
682	812	1
682	896	2
682	662	3
682	1459	4
683	189	1
683	1460	2
683	1296	3
683	1461	4
684	1450	1
684	1462	2
684	1463	3
684	1464	4
685	17	1
685	749	2
685	414	3
685	1352	4
686	236	1
686	172	2
686	537	3
686	1465	4
687	1466	1
687	1467	2
687	1468	3
687	1469	4
688	1470	1
688	238	2
688	811	3
688	1471	4
689	217	1
689	1472	2
689	1473	3
689	1474	4
690	387	1
690	236	2
690	242	3
690	173	4
691	129	1
691	1475	2
691	291	3
691	1476	4
692	1477	1
692	1478	2
692	1479	3
692	1480	4
693	236	1
693	685	2
693	72	3
693	218	4
694	421	1
694	321	2
694	461	3
694	1481	4
695	1482	1
695	449	2
695	1483	3
695	1484	4
696	712	1
696	1021	2
696	1485	3
696	1486	4
697	734	1
697	749	2
697	1	3
697	826	4
698	1487	1
698	1488	2
698	1489	3
698	1490	4
699	869	1
699	1001	2
699	1074	3
699	1491	4
700	1492	1
700	1493	2
700	1494	3
700	1495	4
701	586	1
701	626	2
701	1487	3
701	1496	4
702	239	1
702	110	2
702	15	3
702	1497	4
703	869	1
703	490	2
703	741	3
703	1341	4
704	72	1
704	235	2
704	1498	3
704	1499	4
705	53	1
705	1500	2
705	774	3
705	1501	4
706	1502	1
706	1503	2
706	1504	3
706	1505	4
707	21	1
707	227	2
707	1506	3
707	1507	4
708	478	1
708	469	2
708	898	3
708	90	4
709	134	1
709	1508	2
709	521	3
709	1500	4
710	1008	1
710	1084	2
710	529	3
710	782	4
711	607	1
711	608	2
711	609	3
711	610	4
712	1509	1
712	1510	2
712	1511	3
712	1512	4
713	49	1
713	4	2
713	734	3
713	988	4
714	1513	1
714	1514	2
714	1515	3
714	1516	4
715	518	1
715	240	2
715	446	3
715	1517	4
716	834	1
716	1518	2
716	235	3
716	1365	4
717	779	1
717	1519	2
717	1520	3
717	1521	4
718	1522	1
718	964	2
718	1523	3
718	1524	4
719	305	1
719	1219	2
719	323	3
719	360	4
720	149	1
720	596	2
720	380	3
720	1227	4
721	714	1
721	401	2
721	23	3
721	811	4
722	14	1
722	864	2
722	1525	3
722	961	4
723	865	1
723	1526	2
723	941	3
723	959	4
724	1527	1
724	1528	2
724	1529	3
724	1530	4
725	1531	1
725	1390	2
725	44	3
725	1532	4
726	169	1
726	1135	2
726	375	3
726	537	4
727	110	1
727	91	2
727	1533	3
727	1534	4
728	258	1
728	655	2
728	702	3
728	1535	4
729	204	1
729	3	2
729	478	3
729	655	4
730	1536	1
730	1537	2
730	97	3
730	1538	4
731	572	1
731	628	2
731	596	3
731	1539	4
732	423	1
732	473	2
732	149	3
732	1540	4
733	836	1
733	837	2
733	178	3
733	831	4
734	217	1
734	1541	2
734	1542	3
734	481	4
735	1543	1
735	512	2
735	1544	3
735	1296	4
736	376	1
736	624	2
736	1545	3
736	390	4
737	394	1
737	1546	2
737	1547	3
737	1548	4
738	274	1
738	305	2
738	173	3
738	592	4
739	199	1
739	535	2
739	324	3
739	1549	4
740	1550	1
740	928	2
740	711	3
740	1000	4
741	271	1
741	112	2
741	942	3
741	1551	4
742	79	1
742	1552	2
742	335	3
742	1553	4
743	1554	1
743	1555	2
743	1556	3
743	1557	4
744	333	1
744	21	2
744	440	3
744	413	4
745	380	1
745	1558	2
745	1559	3
745	1560	4
746	15	1
746	8	2
746	204	3
746	400	4
747	1561	1
747	1562	2
747	1563	3
747	1564	4
748	1450	1
748	228	2
748	1565	3
748	1566	4
749	1567	1
749	1568	2
749	281	3
749	1569	4
750	661	1
750	601	2
750	682	3
750	1570	4
751	323	1
751	25	2
751	852	3
751	282	4
752	1571	1
752	612	2
752	1572	3
752	1573	4
753	640	1
753	116	2
753	782	3
753	1574	4
754	14	1
754	179	2
754	242	3
754	1575	4
755	1576	1
755	1577	2
755	1578	3
755	1579	4
756	278	1
756	8	2
756	517	3
756	1508	4
757	755	1
757	1580	2
757	1001	3
757	1581	4
758	1582	1
758	1583	2
758	1584	3
758	1585	4
759	353	1
759	988	2
759	1586	3
759	206	4
760	239	1
760	199	2
760	75	3
760	295	4
761	1587	1
761	515	2
761	1588	3
761	584	4
762	966	1
762	134	2
762	16	3
762	1316	4
763	490	1
763	1124	2
763	1419	3
763	1589	4
764	607	1
764	240	2
764	749	3
764	648	4
765	143	1
765	356	2
765	1590	3
765	1591	4
766	366	1
766	1592	2
766	1593	3
766	1594	4
767	962	1
767	376	2
767	440	3
767	902	4
768	962	1
768	535	2
768	607	3
768	1595	4
769	863	1
769	1596	2
769	1597	3
769	1598	4
770	325	1
770	115	2
770	35	3
770	1248	4
771	486	1
771	742	2
771	669	3
771	377	4
772	256	1
772	291	2
772	1442	3
772	1599	4
773	793	1
773	355	2
773	93	3
773	1600	4
774	702	1
774	80	2
774	487	3
774	1601	4
775	235	1
775	555	2
775	1602	3
775	1603	4
776	628	1
776	631	2
776	202	3
776	418	4
777	1604	1
777	1605	2
777	1606	3
777	1607	4
778	902	1
778	1558	2
778	1608	3
778	1609	4
779	1610	1
779	1611	2
779	1612	3
779	1613	4
780	71	1
780	115	2
780	1614	3
780	1615	4
781	204	1
781	267	2
781	1616	3
781	1617	4
782	125	1
782	1618	2
782	575	3
782	390	4
783	47	1
783	1619	2
783	965	3
783	1620	4
784	1621	1
784	1622	2
784	1623	3
784	1230	4
785	133	1
785	794	2
785	1624	3
785	1625	4
786	217	1
786	1589	2
786	1626	3
786	573	4
787	73	1
787	1008	2
787	190	3
787	1627	4
788	1628	1
788	1629	2
788	711	3
788	1630	4
789	865	1
789	847	2
789	604	3
789	941	4
790	17	1
790	8	2
790	262	3
790	805	4
791	673	1
791	1196	2
791	595	3
791	1631	4
792	335	1
792	1135	2
792	1075	3
792	1632	4
793	149	1
793	937	2
793	1633	3
793	1634	4
794	1635	1
794	1636	2
794	1637	3
794	1638	4
795	65	1
795	937	2
795	811	3
795	1639	4
796	324	1
796	1640	2
796	1641	3
796	1642	4
797	199	1
797	428	2
797	1643	3
797	1644	4
798	429	1
798	150	2
798	1645	3
798	1646	4
799	204	1
799	1536	2
799	785	3
799	1647	4
800	423	1
800	473	2
800	474	3
800	282	4
801	1648	1
801	1649	2
801	169	3
801	879	4
802	640	1
802	414	2
802	1307	3
802	1650	4
803	1146	1
803	1651	2
803	646	3
803	1285	4
804	179	1
804	47	2
804	266	3
804	32	4
805	1104	1
805	238	2
805	1652	3
805	1653	4
806	239	1
806	1654	2
806	241	3
806	430	4
807	121	1
807	214	2
807	390	3
807	1119	4
808	300	1
808	378	2
808	84	3
808	292	4
809	1655	1
809	282	2
809	1656	3
809	270	4
810	623	1
810	1657	2
810	855	3
810	1658	4
811	1659	1
811	1660	2
811	1661	3
811	1662	4
812	136	1
812	613	2
812	1663	3
812	1664	4
813	521	1
813	663	2
813	1665	3
813	1666	4
814	1667	1
814	170	2
814	222	3
814	276	4
815	511	1
815	398	2
815	389	3
815	1102	4
816	142	1
816	683	2
816	1201	3
816	635	4
817	399	1
817	1668	2
817	1669	3
817	1670	4
818	118	1
818	1671	2
818	326	3
818	1672	4
819	1673	1
819	475	2
819	1674	3
819	1675	4
820	1676	1
820	1677	2
820	1678	3
820	1679	4
821	83	1
821	1680	2
821	19	3
821	1681	4
822	635	1
822	1682	2
822	200	3
822	64	4
823	1071	1
823	734	2
823	1683	3
823	1481	4
824	1084	1
824	1684	2
824	1162	3
824	1685	4
825	607	1
825	379	2
825	387	3
825	326	4
826	1686	1
826	1313	2
826	1687	3
826	1505	4
827	586	1
827	1688	2
827	431	3
827	1367	4
828	1689	1
828	1690	2
828	1275	3
828	1475	4
829	248	1
829	1586	2
829	1691	3
829	748	4
830	1692	1
830	1693	2
830	1694	3
830	1658	4
831	925	1
831	1695	2
831	1696	3
831	1697	4
832	425	1
832	426	2
832	1698	3
832	428	4
833	552	1
833	7	2
833	811	3
833	1699	4
834	13	1
834	194	2
834	1700	3
834	1701	4
835	1305	1
835	790	2
835	896	3
835	390	4
836	181	1
836	981	2
836	1702	3
836	61	4
837	1703	1
837	1704	2
837	1705	3
837	1706	4
838	865	1
838	1707	2
838	1708	3
838	1709	4
839	723	1
839	196	2
839	1710	3
839	1711	4
840	143	1
840	1712	2
840	1713	3
840	1714	4
841	262	1
841	57	2
841	469	3
841	193	4
842	812	1
842	1299	2
842	498	3
842	231	4
843	873	1
843	714	2
843	461	3
843	339	4
844	1187	1
844	1715	2
844	1716	3
844	1717	4
845	142	1
845	179	2
845	749	3
845	1718	4
846	142	1
846	1687	2
846	746	3
846	241	4
847	1719	1
847	707	2
847	1720	3
847	1244	4
848	172	1
848	1721	2
848	1722	3
848	1700	4
849	1723	1
849	1724	2
849	1725	3
849	500	4
850	614	1
850	1726	2
850	962	3
850	1727	4
851	1721	1
851	854	2
851	1308	3
851	1728	4
852	266	1
852	303	2
852	1729	3
852	440	4
853	199	1
853	82	2
853	4	3
853	414	4
854	1084	1
854	16	2
854	182	3
854	1730	4
855	519	1
855	171	2
855	646	3
855	1316	4
856	735	1
856	1731	2
856	1732	3
856	1733	4
857	199	1
857	65	2
857	842	3
857	1734	4
858	1225	1
858	1735	2
858	1266	3
858	1204	4
859	1736	1
859	1737	2
859	1185	3
859	1738	4
860	646	1
860	1739	2
860	578	3
860	1740	4
861	34	1
861	1738	2
861	1741	3
861	1742	4
862	1743	1
862	1744	2
862	311	3
862	1745	4
863	429	1
863	245	2
863	822	3
863	208	4
864	242	1
864	642	2
864	1746	3
864	837	4
865	232	1
865	1747	2
865	1096	3
865	1124	4
866	359	1
866	1748	2
866	1749	3
866	1750	4
867	661	1
867	1096	2
867	1751	3
867	1752	4
868	662	1
868	1753	2
868	665	3
868	1059	4
869	425	1
869	1698	2
869	426	3
869	427	4
870	482	1
870	240	2
870	1754	3
870	1272	4
871	1755	1
871	1756	2
871	1757	3
871	1758	4
872	1759	1
872	1760	2
872	1761	3
872	1762	4
873	304	1
873	1763	2
873	454	3
873	1764	4
874	56	1
874	1721	2
874	1533	3
874	1765	4
875	1381	1
875	609	2
875	1766	3
875	1767	4
876	76	1
876	596	2
876	1768	3
876	1769	4
877	124	1
877	67	2
877	1770	3
877	1402	4
878	535	1
878	691	2
878	663	3
878	1712	4
879	53	1
879	734	2
879	1771	3
879	1457	4
880	65	1
880	204	2
880	282	3
880	498	4
881	1772	1
881	1773	2
881	1774	3
881	1775	4
882	1292	1
882	217	2
882	1776	3
882	640	4
883	169	1
883	1084	2
883	741	3
883	479	4
884	222	1
884	56	2
884	1777	3
884	1778	4
885	124	1
885	316	2
885	1779	3
885	1780	4
886	253	1
886	535	2
886	1781	3
886	1782	4
887	253	1
887	953	2
887	136	3
887	1783	4
888	380	1
888	1784	2
888	1785	3
888	1786	4
889	1787	1
889	1788	2
889	1228	3
889	1754	4
890	275	1
890	149	2
890	90	3
890	80	4
891	1789	1
891	1790	2
891	1791	3
891	1792	4
892	524	1
892	336	2
892	1793	3
892	1794	4
893	235	1
893	526	2
893	1795	3
893	1123	4
894	1796	1
894	1797	2
894	1213	3
894	1798	4
895	925	1
895	1799	2
895	1800	3
895	1801	4
896	1586	1
896	1802	2
896	413	3
896	1803	4
897	17	1
897	691	2
897	372	3
897	1804	4
898	1805	1
898	1806	2
898	1807	3
898	1808	4
899	1381	1
899	355	2
899	1809	3
899	1810	4
900	194	1
900	56	2
900	1811	3
900	1812	4
901	57	1
901	801	2
901	1813	3
901	1814	4
902	238	1
902	1815	2
902	1816	3
902	1817	4
903	359	1
903	1818	2
903	1819	3
903	203	4
904	793	1
904	535	2
904	355	3
904	1600	4
905	1446	1
905	387	2
905	161	3
905	755	4
906	863	1
906	118	2
906	144	3
906	604	4
907	851	1
907	1820	2
907	1821	3
907	867	4
908	511	1
908	253	2
908	21	3
908	1822	4
909	1570	1
909	937	2
909	1823	3
909	1824	4
910	21	1
910	259	2
910	685	3
910	583	4
911	1526	1
911	70	2
911	1825	3
911	896	4
912	1746	1
912	1826	2
912	1548	3
912	1601	4
913	454	1
913	1827	2
913	92	3
913	1828	4
914	1829	1
914	1830	2
914	1831	3
914	1832	4
915	1833	1
915	1123	2
915	1834	3
915	1835	4
916	1836	1
916	1837	2
916	1838	3
916	1839	4
917	925	1
917	94	2
917	1840	3
917	1278	4
918	1841	1
918	1842	2
918	1843	3
918	1844	4
919	752	1
919	1316	2
919	1419	3
919	1845	4
920	72	1
920	486	2
920	1846	3
920	1847	4
921	7	1
921	358	2
921	742	3
921	1848	4
922	1753	1
922	1849	2
922	1850	3
922	1851	4
923	380	1
923	1852	2
923	336	3
923	617	4
924	63	1
924	399	2
924	628	3
924	1853	4
925	1854	1
925	1308	2
925	854	3
925	981	4
926	316	1
926	34	2
926	906	3
926	334	4
927	1855	1
927	1856	2
927	297	3
927	1857	4
928	13	1
928	586	2
928	277	3
928	1858	4
929	117	1
929	1859	2
929	1860	3
929	1861	4
930	1272	1
930	507	2
930	75	3
930	1862	4
931	1863	1
931	1136	2
931	1071	3
931	1864	4
932	624	1
932	1034	2
932	1865	3
932	1866	4
933	1536	1
933	446	2
933	1367	3
933	649	4
934	1753	1
934	796	2
934	1867	3
934	1868	4
935	1869	1
935	1870	2
935	1871	3
935	1872	4
936	895	1
936	896	2
936	1305	3
936	1434	4
937	1873	1
937	1874	2
937	1875	3
937	1876	4
938	1877	1
938	276	2
938	964	3
938	587	4
939	232	1
939	173	2
939	247	3
939	226	4
940	511	1
940	521	2
940	90	3
940	262	4
941	1301	1
941	3	2
941	1154	3
941	1878	4
942	316	1
942	34	2
942	906	3
942	1296	4
943	880	1
943	1879	2
943	571	3
943	1880	4
944	790	1
944	133	2
944	1881	3
944	1785	4
945	2	1
945	181	2
945	1572	3
945	1882	4
946	1883	1
946	1884	2
946	1885	3
946	1886	4
947	77	1
947	1716	2
947	1104	3
947	1165	4
948	1887	1
948	1888	2
948	1889	3
948	1890	4
949	1390	1
949	496	2
949	17	3
949	1891	4
950	1892	1
950	1893	2
950	1894	3
950	1895	4
951	1896	1
951	1897	2
951	1898	3
951	162	4
952	511	1
952	378	2
952	1899	3
952	1900	4
953	1796	1
953	1797	2
953	1798	3
953	1213	4
954	1901	1
954	911	2
954	1902	3
954	162	4
955	286	1
955	1021	2
955	610	3
955	171	4
956	380	1
956	924	2
956	300	3
956	843	4
957	1903	1
957	1071	2
957	1904	3
957	797	4
958	121	1
958	260	2
958	90	3
958	1905	4
959	47	1
959	440	2
959	1906	3
959	751	4
960	1907	1
960	390	2
960	741	3
960	1908	4
961	9	1
961	749	2
961	70	3
961	1909	4
962	276	1
962	1910	2
962	1749	3
962	1911	4
963	324	1
963	16	2
963	1008	3
963	1721	4
964	1912	1
964	1913	2
964	1914	3
964	1915	4
965	20	1
965	1916	2
965	1917	3
965	1603	4
966	864	1
966	115	2
966	230	3
966	1918	4
967	1919	1
967	1397	2
967	1541	3
967	591	4
968	275	1
968	251	2
968	1920	3
968	1921	4
969	788	1
969	1922	2
969	1923	3
969	1924	4
970	169	1
970	331	2
970	908	3
970	831	4
971	601	1
971	1925	2
971	1041	3
971	1926	4
972	607	1
972	1804	2
972	1927	3
972	1486	4
973	1136	1
973	1928	2
973	482	3
973	691	4
974	1929	1
974	1930	2
974	1931	3
974	1932	4
975	1933	1
975	1655	2
975	1934	3
975	1935	4
976	1936	1
976	1246	2
976	1937	3
976	1938	4
977	8	1
977	124	2
977	364	3
977	624	4
978	1386	1
978	1939	2
978	1940	3
978	1941	4
979	1942	1
979	70	2
979	114	3
979	497	4
980	929	1
980	1943	2
980	1944	3
980	1945	4
981	245	1
981	1946	2
981	940	3
981	1947	4
982	1948	1
982	1191	2
982	434	3
982	596	4
983	1910	1
983	1721	2
983	1750	3
983	1949	4
984	1950	1
984	1951	2
984	968	3
984	1952	4
985	874	1
985	1724	2
985	1953	3
985	1954	4
986	1129	1
986	324	2
986	118	3
986	1955	4
987	1956	1
987	1957	2
987	1958	3
987	1679	4
988	1067	1
988	969	2
988	1223	3
988	1828	4
989	1959	1
989	1960	2
989	1961	3
989	1962	4
990	1655	1
990	1963	2
990	626	3
990	1964	4
991	1177	1
991	38	2
991	215	3
991	1965	4
992	1966	1
992	366	2
992	1967	3
992	1968	4
993	644	1
993	790	2
993	43	3
993	67	4
994	129	1
994	131	2
994	1702	3
994	1969	4
995	1896	1
995	1970	2
995	1971	3
995	1972	4
996	139	1
996	72	2
996	195	3
996	1973	4
997	1974	1
997	1975	2
997	1976	3
997	1977	4
998	1978	1
998	1979	2
998	1980	3
998	1981	4
999	1982	1
999	127	2
999	1983	3
999	1984	4
1000	1308	1
1000	245	2
1000	1455	3
1000	1985	4
\.


--
-- Data for Name: pelicula_auditoria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelicula_auditoria (id_auditoria, id_pelicula_eliminada, titulo_eliminado, fecha_eliminacion, accion) FROM stdin;
\.


--
-- Data for Name: pelicula_genero; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelicula_genero (id_pelicula, id_genero) FROM stdin;
1	1
1	2
1	3
2	2
2	4
2	3
3	5
3	6
4	7
4	8
4	9
5	1
5	2
5	10
6	1
6	2
6	10
7	8
7	11
7	12
8	8
9	1
9	2
9	13
10	2
10	11
10	14
11	2
11	9
11	10
12	13
12	11
12	15
13	1
13	2
13	3
14	7
14	2
14	8
15	1
15	8
15	11
16	7
16	2
16	8
17	13
17	11
17	15
18	1
18	6
19	13
19	11
20	11
20	4
20	3
21	2
21	11
21	6
22	11
23	16
23	11
23	5
24	7
24	2
24	8
25	1
25	2
25	3
26	8
27	1
27	2
27	11
28	5
28	6
29	8
30	1
30	2
30	11
31	8
32	11
32	6
33	1
33	2
33	3
34	1
34	2
34	8
35	1
35	5
35	3
36	1
36	2
36	3
37	2
37	11
37	3
38	1
38	2
38	10
39	1
39	2
39	17
40	8
40	11
41	7
41	2
41	8
42	11
43	5
44	13
44	11
44	15
45	11
46	1
46	2
46	10
47	11
47	6
48	2
48	11
48	10
49	1
49	2
49	3
50	11
51	1
51	2
51	10
52	1
52	2
52	10
53	8
53	11
54	1
54	16
54	6
55	1
55	16
55	11
56	2
56	11
56	15
57	16
57	5
57	6
58	11
58	14
59	8
59	11
59	14
60	13
60	11
61	1
61	2
61	3
62	5
62	4
62	6
63	16
63	11
63	4
64	11
64	14
64	6
65	11
65	4
65	3
66	1
66	2
66	8
67	11
67	15
67	6
68	1
68	2
68	3
69	11
70	1
70	11
70	6
71	11
71	15
72	1
72	11
72	14
73	11
73	10
74	11
74	14
75	7
75	2
75	8
76	1
76	2
76	10
77	1
77	3
78	2
78	11
78	18
79	1
79	2
79	10
80	1
80	8
80	10
81	1
81	2
81	3
82	8
82	11
83	13
83	8
83	16
84	16
84	11
84	4
85	1
85	16
85	6
86	1
86	2
86	3
87	16
87	11
88	1
88	2
88	10
89	16
89	11
89	4
90	1
90	16
90	11
91	16
91	11
91	4
92	1
92	2
92	10
93	11
94	8
94	16
94	11
95	1
95	2
95	3
96	1
96	8
96	16
97	7
97	11
97	10
98	5
98	4
98	3
99	11
99	4
99	6
100	16
100	11
100	6
101	13
101	16
101	11
102	1
102	2
102	10
103	2
103	11
103	3
104	16
104	4
104	6
105	1
105	2
105	8
106	16
106	11
106	6
107	8
108	1
108	2
108	11
109	11
110	11
110	4
110	3
111	1
111	5
111	6
112	13
112	11
112	15
113	14
113	3
114	1
114	10
114	18
115	2
115	11
115	10
116	8
117	5
117	6
118	1
118	13
118	11
119	11
119	5
119	4
120	7
120	2
120	8
121	2
121	11
121	9
122	2
122	4
122	3
123	2
123	8
123	14
124	1
125	1
125	6
126	2
126	11
126	9
127	1
127	2
127	3
128	2
128	16
128	4
129	8
129	9
129	19
130	2
130	11
130	6
131	11
132	2
132	8
132	11
133	11
133	5
133	6
134	11
134	12
135	1
135	16
135	6
136	16
136	11
136	6
137	16
137	11
137	6
138	11
138	14
139	4
139	6
140	4
140	6
140	17
141	1
141	2
141	3
142	8
142	9
143	13
143	8
143	11
144	11
145	11
145	17
146	11
146	4
146	14
147	8
147	11
148	1
148	11
148	4
149	8
150	1
150	2
150	16
151	2
151	9
151	10
152	2
152	3
152	6
153	11
154	1
154	16
154	11
155	11
155	5
155	4
156	1
156	5
156	3
157	1
157	2
157	3
158	8
158	11
158	14
159	1
159	8
159	10
160	1
160	8
160	4
161	6
161	18
162	1
162	8
162	16
163	1
163	2
163	3
164	1
164	2
164	16
165	1
165	2
165	6
166	11
166	10
166	14
167	1
167	2
167	8
168	13
168	11
168	15
169	1
169	11
169	15
170	1
170	2
170	6
171	16
171	11
171	6
172	7
172	2
172	9
173	2
173	5
174	11
174	14
174	3
175	7
175	2
175	8
176	1
176	2
176	9
177	1
177	2
177	11
178	1
178	8
179	5
179	4
179	6
180	1
180	2
180	8
181	8
181	14
182	5
182	4
183	11
183	9
183	10
184	3
185	11
185	6
186	11
186	14
187	11
187	18
188	11
188	10
188	5
189	16
189	11
190	8
190	11
190	14
191	11
191	14
192	11
193	16
193	11
193	15
194	5
194	3
194	6
195	1
195	11
195	20
196	1
196	2
196	3
197	16
197	11
197	6
198	2
198	13
198	11
199	13
199	11
199	6
200	1
200	8
200	16
201	1
201	2
201	3
202	11
202	10
202	5
203	13
203	11
203	6
204	1
204	2
204	3
205	1
205	2
205	4
206	1
206	2
206	3
207	11
207	5
208	8
208	11
208	14
209	8
209	14
210	11
210	5
210	6
211	1
211	2
211	11
212	11
213	1
213	2
213	3
214	1
214	11
214	4
215	1
215	2
215	10
216	1
216	2
216	10
217	1
217	2
217	3
218	1
218	2
218	8
219	11
219	5
220	1
220	8
221	1
221	2
221	3
222	7
222	2
222	8
223	5
223	4
224	16
224	11
224	4
225	8
225	16
226	11
227	8
227	11
227	14
228	1
228	2
228	3
229	1
229	2
229	9
230	5
230	3
230	6
231	11
231	10
231	18
232	16
232	11
232	6
233	1
233	2
233	11
234	1
234	2
234	6
235	1
235	2
235	11
236	11
236	14
237	13
237	11
237	15
238	11
238	5
238	6
239	2
239	8
239	11
240	1
240	2
240	14
241	1
241	11
241	18
242	7
242	2
242	8
243	7
243	2
243	8
244	1
244	2
244	3
245	2
245	9
245	10
246	11
246	19
246	14
247	11
247	3
247	6
248	8
248	11
249	1
249	8
249	16
250	13
250	8
250	11
251	8
251	11
251	14
252	11
252	6
253	13
253	11
253	15
254	1
254	2
254	3
255	5
255	4
255	6
256	8
257	1
257	2
257	3
258	1
258	11
258	3
259	5
260	11
260	6
261	8
261	11
261	14
262	11
262	6
263	8
263	11
264	11
265	1
265	2
265	8
266	11
266	5
266	6
267	8
268	11
268	3
269	1
269	2
269	3
270	5
271	1
271	2
271	6
272	2
272	10
273	1
273	8
273	16
274	8
274	11
274	12
275	7
275	2
275	8
276	1
276	2
276	4
277	1
277	8
277	16
278	16
278	11
278	15
279	8
280	1
280	2
280	3
281	16
281	4
281	6
282	1
282	2
282	16
283	6
284	13
284	11
284	14
285	1
285	2
286	1
286	10
287	1
287	8
288	1
288	2
288	3
289	1
289	8
289	16
290	6
291	1
291	11
291	5
292	8
292	12
292	14
293	8
294	11
295	1
295	2
295	10
296	11
296	14
297	7
297	2
297	8
298	8
298	11
299	13
299	16
299	11
300	11
300	15
301	1
301	16
301	6
302	1
302	13
302	11
303	5
304	8
304	14
305	8
305	14
306	8
306	16
306	11
307	2
307	9
307	10
308	16
308	11
308	6
309	1
309	16
309	6
310	8
310	14
311	13
311	11
311	20
312	11
312	14
313	11
313	5
314	2
314	10
315	2
315	9
315	10
316	1
316	11
316	3
317	1
317	2
317	3
318	1
318	5
319	8
319	5
319	6
320	1
320	16
320	6
321	16
321	11
321	12
322	11
323	1
323	16
323	6
324	1
324	3
324	6
325	13
325	11
326	1
326	2
326	10
327	11
327	5
327	3
328	13
328	8
328	11
329	16
329	5
329	6
330	16
330	11
330	4
331	7
331	2
331	8
332	1
332	13
332	11
333	13
333	11
334	13
334	11
334	15
335	1
335	13
335	11
336	11
336	10
336	5
337	8
337	11
337	14
338	11
338	20
339	11
339	14
340	8
340	14
341	1
341	16
341	6
342	1
342	16
342	11
343	1
343	11
343	6
344	2
344	9
344	10
345	1
345	2
346	1
346	2
346	14
347	2
347	9
347	10
348	16
348	11
349	8
349	5
350	8
350	10
350	14
351	11
352	11
353	8
353	11
354	8
354	11
354	14
355	2
355	3
355	6
356	1
356	2
356	10
357	8
357	11
358	13
358	11
358	14
359	8
359	10
360	8
360	11
360	10
361	8
362	5
362	6
363	1
363	2
363	3
364	2
364	8
364	5
365	8
365	4
366	11
367	2
367	11
367	10
368	11
368	20
369	1
369	2
370	1
370	2
370	11
371	1
371	11
371	3
372	1
372	4
372	3
373	1
373	16
373	11
374	1
374	16
374	10
375	13
375	8
375	11
376	1
376	16
376	6
377	13
377	16
377	11
378	11
378	20
379	2
379	8
379	11
380	1
380	2
380	6
381	8
381	10
381	5
382	11
382	20
383	5
383	6
384	11
384	15
384	6
385	7
385	1
385	2
386	1
386	2
386	11
387	1
387	8
387	9
388	1
388	2
388	11
389	1
389	2
389	3
390	1
390	2
390	3
391	1
391	8
392	1
392	16
392	11
393	13
393	11
394	8
394	14
395	8
396	11
396	10
396	14
397	1
397	2
397	3
398	8
399	8
399	3
400	8
400	11
401	7
401	1
401	2
402	5
403	1
403	13
403	16
404	7
404	2
404	8
405	11
405	14
406	11
406	4
406	6
407	11
407	15
407	6
408	7
408	2
408	8
409	1
409	2
409	3
410	2
410	8
411	1
411	6
412	8
412	12
413	7
413	2
413	8
414	16
414	11
414	6
415	1
415	2
415	16
416	8
416	11
416	5
417	11
418	11
418	4
418	14
419	2
419	9
419	10
420	11
421	1
421	11
421	6
422	11
423	1
423	5
423	14
424	1
424	11
424	10
425	1
425	16
425	11
426	11
426	10
426	14
427	1
427	16
427	6
428	1
428	4
428	6
429	5
429	4
429	6
430	1
430	5
430	3
431	8
431	11
432	8
433	1
433	2
433	5
434	1
434	2
434	6
435	1
435	16
435	11
436	8
436	16
436	11
437	11
437	14
438	11
438	6
439	1
439	8
439	16
440	8
441	2
441	9
441	10
442	11
442	14
443	7
443	9
443	10
444	11
444	14
445	6
446	2
446	5
446	4
447	1
447	3
448	2
448	8
448	11
449	7
449	1
449	2
450	11
450	5
451	1
451	2
451	3
452	8
452	11
453	1
453	5
453	4
454	1
454	6
455	1
455	2
455	3
456	11
457	8
457	11
457	14
458	8
458	16
459	8
459	14
460	11
460	14
461	16
461	11
461	6
462	5
462	4
462	6
463	13
463	11
464	11
464	4
464	3
465	2
465	8
465	9
466	1
466	2
466	16
467	1
467	16
467	4
468	4
468	6
469	1
469	3
469	6
470	1
470	8
470	16
471	13
471	16
471	11
472	13
472	11
472	15
473	1
473	2
473	3
474	2
474	9
474	10
475	13
475	11
475	15
476	13
476	8
476	11
477	11
477	6
478	5
478	6
479	11
480	11
480	18
481	8
481	11
481	14
482	11
482	14
482	3
483	1
483	16
483	11
484	8
484	11
485	7
485	1
485	2
486	2
486	8
486	11
487	8
487	11
487	9
488	11
488	14
488	6
489	8
489	16
489	11
490	7
490	8
490	9
491	11
491	5
491	3
492	1
492	2
492	11
493	1
493	5
493	3
494	1
494	16
494	20
495	11
495	5
495	3
496	11
496	5
496	3
497	1
497	2
497	8
498	4
498	3
498	6
499	16
499	11
499	6
500	7
500	2
500	8
501	1
501	3
501	6
502	11
502	14
503	16
503	11
503	6
504	8
504	11
504	12
505	11
505	10
505	14
506	16
506	11
506	6
507	16
507	11
507	6
508	8
508	11
508	14
509	8
509	14
510	11
510	3
510	6
511	11
511	18
512	1
512	16
512	11
513	3
513	6
514	2
514	11
514	5
515	8
515	11
515	12
516	8
516	11
516	14
517	1
517	2
517	11
518	1
518	16
518	11
519	2
519	10
520	11
520	14
521	13
521	15
521	6
522	16
522	11
522	6
523	1
523	11
523	15
524	13
524	8
524	11
525	16
525	11
525	6
526	1
526	13
526	11
527	1
527	11
527	3
528	2
528	5
529	1
529	2
529	3
530	1
530	2
530	4
531	8
531	11
531	14
532	5
532	6
533	1
533	3
533	6
534	1
534	3
534	6
535	13
535	11
536	1
536	16
536	11
537	1
537	16
537	4
538	1
538	2
538	8
539	16
539	11
539	6
540	16
540	11
541	4
541	6
542	4
542	3
542	6
543	1
543	4
543	3
544	11
544	14
545	11
545	6
546	11
546	4
546	3
547	8
547	11
548	2
548	9
548	10
549	13
549	11
549	20
550	11
551	8
551	11
551	14
552	13
552	11
552	14
553	1
553	2
553	3
554	11
554	3
554	6
555	11
555	14
555	6
556	4
556	6
557	4
557	6
558	1
558	11
558	10
559	1
559	2
559	13
560	2
560	8
560	3
561	1
561	2
561	6
562	10
562	5
563	5
563	4
564	7
564	2
564	8
565	1
565	2
565	11
566	2
566	9
566	10
567	1
567	2
567	3
568	8
568	11
569	8
569	11
570	16
570	11
570	6
571	8
571	14
572	7
572	8
572	9
573	8
573	11
574	8
574	11
575	13
575	11
575	20
576	1
576	2
576	10
577	1
577	11
577	15
578	1
578	2
578	3
579	1
579	2
579	4
580	16
580	11
580	4
581	1
582	1
582	2
582	9
583	8
583	14
584	8
584	11
584	14
585	13
585	11
585	20
586	1
586	10
586	6
587	13
587	11
587	20
588	1
588	11
588	10
589	2
589	3
589	6
590	7
590	2
590	8
591	11
591	4
591	6
592	11
592	14
593	16
593	11
593	4
594	8
594	14
594	20
595	8
595	9
596	11
596	5
596	4
597	1
597	11
597	20
598	1
598	2
598	8
599	11
599	4
599	3
600	7
600	1
600	8
601	1
601	16
601	11
602	1
602	16
602	11
603	8
603	11
603	14
604	7
604	1
604	2
605	16
605	11
606	11
607	11
608	8
608	16
609	11
610	1
610	2
610	10
611	11
611	10
611	14
612	8
612	11
613	11
613	10
613	6
614	13
614	16
614	11
615	8
615	11
615	14
616	1
616	16
616	11
617	3
618	1
618	13
618	11
619	1
619	8
619	14
620	2
620	8
620	11
621	8
621	16
621	11
622	1
622	10
622	5
623	11
623	5
624	5
625	1
625	6
626	1
626	2
626	4
627	1
627	2
627	10
628	8
628	11
628	14
629	16
629	11
629	4
630	2
630	8
630	9
631	8
631	11
631	14
632	8
633	8
633	11
633	5
634	11
634	5
634	6
635	7
635	2
635	9
636	8
636	14
637	4
637	14
637	3
638	16
638	11
639	11
639	5
639	4
640	8
641	13
641	11
642	8
642	11
642	6
643	8
643	17
644	11
644	15
644	18
645	11
645	5
645	3
646	11
647	8
647	11
648	10
648	5
648	6
649	11
649	14
650	1
650	8
650	10
651	11
651	5
651	19
652	16
652	11
652	4
653	5
653	4
653	6
654	8
654	12
655	11
656	13
656	16
656	11
657	11
658	1
658	2
658	8
659	16
659	11
659	4
660	11
661	1
661	8
661	16
662	8
662	11
662	14
663	16
663	11
663	4
664	1
664	8
664	16
665	11
666	11
666	14
667	16
667	11
667	4
668	2
668	8
668	14
669	8
669	16
669	11
670	2
670	11
670	6
671	13
671	16
671	11
672	16
672	11
672	6
673	11
673	15
673	6
674	1
674	2
674	3
675	1
675	8
676	5
677	1
677	16
677	4
678	8
678	14
679	8
680	1
680	11
680	6
681	1
681	2
681	3
682	11
682	4
682	6
683	8
683	11
683	14
684	1
684	10
684	5
685	11
685	14
686	13
686	11
687	13
687	11
688	1
688	2
688	3
689	7
689	2
689	8
690	11
690	4
690	6
691	1
691	5
691	3
692	11
692	14
693	13
693	11
694	1
694	2
694	11
695	2
695	11
695	10
696	11
696	9
697	8
697	11
697	14
698	11
698	14
698	3
699	1
699	2
699	6
700	8
700	14
701	16
701	11
701	5
702	8
702	10
703	1
703	8
703	16
704	2
704	11
704	14
705	1
705	16
705	11
706	16
706	5
706	6
707	14
707	3
707	6
708	8
708	11
708	14
709	16
709	11
710	16
710	11
710	4
711	1
711	2
711	3
712	7
712	10
713	7
713	2
713	8
714	11
714	4
714	18
715	8
715	14
716	7
716	8
716	9
717	8
718	5
718	4
718	6
719	1
719	2
719	11
720	8
721	11
722	2
722	13
722	11
723	8
724	5
724	6
725	1
725	11
725	9
726	8
726	10
726	5
727	8
727	14
728	11
728	4
728	14
729	1
729	2
729	8
730	6
731	8
732	2
732	8
732	3
733	8
733	11
733	10
734	4
734	6
735	8
735	11
736	2
736	11
736	9
737	5
737	6
738	1
738	11
738	14
739	11
739	14
740	1
740	2
740	10
741	8
742	1
742	13
742	11
743	11
743	4
743	14
744	2
744	11
744	17
745	11
745	12
745	14
746	8
746	14
746	17
747	6
748	8
748	11
748	14
749	5
749	6
750	2
750	9
750	10
751	16
751	11
751	4
752	5
752	4
753	8
753	16
753	11
754	1
754	8
754	14
755	13
755	11
755	15
756	2
756	11
757	11
757	6
758	11
759	1
759	2
759	10
760	1
760	13
760	11
761	11
761	12
762	8
762	11
763	11
763	6
763	18
764	1
764	4
764	6
765	5
765	3
765	6
766	8
766	11
766	14
767	1
767	3
768	1
768	2
768	10
769	11
769	4
769	14
770	11
771	1
771	2
771	6
772	1
772	16
772	6
773	7
773	1
773	2
774	11
774	10
774	4
775	11
775	3
776	7
776	2
776	8
777	5
777	6
778	1
778	6
779	8
780	13
780	11
781	1
781	4
781	6
782	1
782	4
782	3
783	16
783	11
783	6
784	8
784	14
785	8
785	11
785	14
786	13
786	11
786	6
787	11
788	1
788	2
788	9
789	7
789	8
789	9
790	1
790	16
790	11
791	8
792	8
792	16
792	6
793	8
793	14
794	7
794	8
794	11
795	1
795	16
795	6
796	8
796	14
797	2
797	13
797	11
798	7
798	2
798	8
799	16
799	11
799	4
800	1
800	8
800	3
801	8
801	10
801	5
802	8
802	16
803	7
803	1
803	2
804	1
804	11
804	6
805	10
805	5
806	16
806	11
806	6
807	1
807	2
807	10
808	8
808	11
808	14
809	13
809	11
809	14
810	1
810	11
810	15
811	1
811	2
811	8
812	5
812	6
813	5
813	4
813	6
814	8
814	14
815	7
815	2
815	8
816	16
816	11
816	4
817	16
817	11
817	4
818	2
818	13
818	11
819	5
819	4
819	6
820	5
820	6
821	11
821	14
821	18
822	2
822	10
822	4
823	1
823	2
823	3
824	13
824	11
825	11
825	6
826	5
826	6
827	11
827	5
827	6
828	1
828	2
828	10
829	1
829	5
829	6
830	8
831	11
831	20
832	8
832	9
833	11
833	14
834	1
834	2
834	8
835	8
836	4
836	14
836	6
837	16
837	11
838	1
838	8
839	16
839	11
839	4
840	13
840	11
840	14
841	8
841	16
842	11
842	6
843	11
844	7
844	2
844	8
845	1
845	6
846	11
846	6
847	7
847	2
847	8
848	16
848	11
848	4
849	6
850	13
850	11
850	20
851	16
851	11
851	6
852	11
852	12
853	16
853	11
853	6
854	11
854	14
855	7
855	1
855	2
856	8
856	11
857	1
857	2
857	11
858	13
858	16
858	11
859	5
860	13
860	11
860	4
861	11
861	14
862	7
862	11
862	14
863	8
863	9
864	11
865	4
865	6
866	11
866	10
866	5
867	11
867	14
868	13
868	11
868	15
869	8
869	9
870	1
870	2
870	6
871	8
871	11
872	1
872	2
872	10
873	1
873	6
874	11
874	14
875	8
875	11
875	14
876	11
876	5
876	3
877	8
877	5
877	14
878	11
879	1
879	2
879	3
880	1
880	2
880	10
881	1
881	2
881	11
882	13
882	8
882	11
883	11
883	4
883	14
884	7
884	2
884	8
885	11
885	14
885	3
886	11
887	11
887	10
888	11
888	14
889	8
889	5
889	6
890	8
890	11
890	14
891	16
891	11
892	8
892	14
893	1
893	11
893	9
894	8
894	11
894	14
895	1
895	6
895	18
896	1
896	8
896	5
897	13
897	11
897	20
898	2
898	8
898	11
899	8
899	14
900	8
900	14
901	8
901	11
901	14
902	1
902	2
902	16
903	8
903	14
904	7
904	1
904	2
905	1
905	16
905	3
906	11
907	8
907	11
907	14
908	16
908	6
909	8
909	5
909	3
910	11
910	6
911	11
911	10
911	5
912	6
913	2
913	11
913	9
914	4
914	3
914	6
915	13
915	16
915	11
916	11
916	10
916	5
917	1
917	2
917	6
918	16
918	11
918	5
919	16
919	11
919	10
920	2
920	9
920	10
921	1
921	2
921	11
922	1
922	8
922	5
923	8
923	11
923	9
924	1
924	6
925	1
925	2
925	3
926	2
926	11
926	10
927	11
928	11
929	8
930	11
931	8
931	11
931	12
932	11
932	10
932	12
933	11
934	6
935	8
935	5
936	1
936	8
936	20
937	5
938	8
938	11
939	1
939	11
939	6
940	11
940	14
941	5
941	4
942	2
942	11
942	10
943	6
944	8
944	14
945	1
945	3
945	6
946	10
946	4
946	6
947	13
947	11
948	16
948	11
949	1
949	2
949	3
950	2
951	8
951	11
952	8
952	11
953	8
953	11
953	14
954	2
954	8
954	11
955	1
955	3
955	6
956	8
956	14
957	1
957	10
957	5
958	16
958	11
958	6
959	1
959	11
959	6
960	16
960	11
960	4
961	16
961	11
961	4
962	11
962	3
962	6
963	13
963	11
963	15
964	16
964	5
964	6
965	11
966	11
966	4
966	6
967	2
967	13
968	2
968	13
968	16
969	1
969	5
969	6
970	1
970	2
970	17
971	5
971	6
972	11
972	4
972	6
973	8
973	11
973	19
974	5
974	4
975	13
975	11
975	20
976	8
976	9
976	14
977	11
977	4
977	6
978	8
979	11
980	11
980	6
981	13
981	11
981	9
982	8
982	11
982	9
983	11
983	10
983	19
984	8
985	2
985	9
986	2
986	8
986	10
987	5
987	6
988	11
988	14
989	5
990	13
990	11
990	15
991	1
991	2
991	10
992	11
992	9
992	12
993	8
993	11
993	14
994	1
994	2
994	5
995	8
996	16
996	11
996	4
997	5
998	11
998	12
998	14
999	2
999	8
1000	8
1000	9
1000	10
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario (id_usuario, nombre_usuario, contrasena_hash, rol, fecha_creacion) FROM stdin;
1	admin	$2b$10$7KipzYj8eyQuK/3Xo/aYT.X0wb4/yViDCTbvTGFfaY2xtpnF4mWEi	administrador	2026-11-03
2	analista	$2b$10$tNeoReJOUu9B0v/u29OyN.98I9dQV5ejAl80dGczPzne7pbvCulj6	analista	2026-11-03
\.


--
-- Name: actor_id_actor_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.actor_id_actor_seq', 1985, true);


--
-- Name: director_id_director_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.director_id_director_seq', 644, true);


--
-- Name: genero_id_genero_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.genero_id_genero_seq', 20, true);


--
-- Name: pelicula_auditoria_id_auditoria_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pelicula_auditoria_id_auditoria_seq', 1, false);


--
-- Name: pelicula_id_pelicula_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pelicula_id_pelicula_seq', 1000, true);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 2, true);


--
-- Name: actor actor_nombre_actor_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_nombre_actor_key UNIQUE (nombre_actor);


--
-- Name: actor actor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (id_actor);


--
-- Name: director director_nombre_director_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.director
    ADD CONSTRAINT director_nombre_director_key UNIQUE (nombre_director);


--
-- Name: director director_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.director
    ADD CONSTRAINT director_pkey PRIMARY KEY (id_director);


--
-- Name: genero genero_nombre_genero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genero
    ADD CONSTRAINT genero_nombre_genero_key UNIQUE (nombre_genero);


--
-- Name: genero genero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id_genero);


--
-- Name: pelicula_actor pelicula_actor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_actor
    ADD CONSTRAINT pelicula_actor_pkey PRIMARY KEY (id_pelicula, id_actor);


--
-- Name: pelicula_auditoria pelicula_auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_auditoria
    ADD CONSTRAINT pelicula_auditoria_pkey PRIMARY KEY (id_auditoria);


--
-- Name: pelicula_genero pelicula_genero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_genero
    ADD CONSTRAINT pelicula_genero_pkey PRIMARY KEY (id_pelicula, id_genero);


--
-- Name: pelicula pelicula_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula
    ADD CONSTRAINT pelicula_pkey PRIMARY KEY (id_pelicula);


--
-- Name: usuario usuario_nombre_usuario_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nombre_usuario_key UNIQUE (nombre_usuario);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: pelicula trg_auditar_eliminacion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_auditar_eliminacion AFTER DELETE ON public.pelicula FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_eliminacion();


--
-- Name: pelicula trg_validar_calificacion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validar_calificacion BEFORE INSERT OR UPDATE ON public.pelicula FOR EACH ROW EXECUTE FUNCTION public.fn_validar_calificacion();


--
-- Name: pelicula_actor pelicula_actor_id_actor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_actor
    ADD CONSTRAINT pelicula_actor_id_actor_fkey FOREIGN KEY (id_actor) REFERENCES public.actor(id_actor) ON DELETE CASCADE;


--
-- Name: pelicula_actor pelicula_actor_id_pelicula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_actor
    ADD CONSTRAINT pelicula_actor_id_pelicula_fkey FOREIGN KEY (id_pelicula) REFERENCES public.pelicula(id_pelicula) ON DELETE CASCADE;


--
-- Name: pelicula_genero pelicula_genero_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_genero
    ADD CONSTRAINT pelicula_genero_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.genero(id_genero) ON DELETE CASCADE;


--
-- Name: pelicula_genero pelicula_genero_id_pelicula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula_genero
    ADD CONSTRAINT pelicula_genero_id_pelicula_fkey FOREIGN KEY (id_pelicula) REFERENCES public.pelicula(id_pelicula) ON DELETE CASCADE;


--
-- Name: pelicula pelicula_id_director_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelicula
    ADD CONSTRAINT pelicula_id_director_fkey FOREIGN KEY (id_director) REFERENCES public.director(id_director);


--
-- PostgreSQL database dump complete
--


