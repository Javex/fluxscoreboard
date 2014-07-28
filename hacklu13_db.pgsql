--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO javex;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY alembic_version (version_num) FROM stdin;
a36e99747e8
\.


--
-- Name: category; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE category (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.category OWNER TO javex;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_id_seq OWNER TO javex;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE category_id_seq OWNED BY category.id;


--
-- Name: challenge; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE challenge (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    text text,
    solution character varying(255),
    points integer,
    online boolean NOT NULL,
    manual boolean NOT NULL,
    category_id integer,
    author character varying(255),
    dynamic boolean NOT NULL,
    module_name character varying(255),
    published boolean NOT NULL,
    has_token boolean NOT NULL
);


ALTER TABLE public.challenge OWNER TO javex;

--
-- Name: challenge_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE challenge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.challenge_id_seq OWNER TO javex;

--
-- Name: challenge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE challenge_id_seq OWNED BY challenge.id;


--
-- Name: country; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE country (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.country OWNER TO javex;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO javex;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE country_id_seq OWNED BY country.id;


--
-- Name: geoip; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE geoip (
    ip_range_start bigint NOT NULL,
    ip_range_end bigint NOT NULL,
    country_code character varying(2) NOT NULL
);


ALTER TABLE public.geoip OWNER TO javex;

--
-- Name: massmail; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE massmail (
    id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    subject text NOT NULL,
    message text NOT NULL,
    recipients text NOT NULL,
    from_ text NOT NULL
);


ALTER TABLE public.massmail OWNER TO javex;

--
-- Name: massmail_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE massmail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.massmail_id_seq OWNER TO javex;

--
-- Name: massmail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE massmail_id_seq OWNED BY massmail.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE news (
    id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    message text,
    published boolean,
    challenge_id integer
);


ALTER TABLE public.news OWNER TO javex;

--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.news_id_seq OWNER TO javex;

--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE news_id_seq OWNED BY news.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    submission_disabled boolean,
    ctf_start_date timestamp without time zone,
    ctf_end_date timestamp without time zone,
    archive_mode boolean NOT NULL
);


ALTER TABLE public.settings OWNER TO javex;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.settings_id_seq OWNER TO javex;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE submission (
    team_id integer NOT NULL,
    challenge_id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    bonus integer NOT NULL
);


ALTER TABLE public.submission OWNER TO javex;

--
-- Name: team; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE team (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    password character varying(60) NOT NULL,
    email character varying(255) NOT NULL,
    country_id integer NOT NULL,
    local boolean,
    token character varying(64) NOT NULL,
    reset_token character varying(64),
    ref_token character varying(15) NOT NULL,
    challenge_token character varying(36) NOT NULL,
    active boolean,
    timezone character varying(30) NOT NULL,
    avatar_filename character varying(68),
    size integer
);


ALTER TABLE public.team OWNER TO javex;

--
-- Name: team_flag; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE team_flag (
    team_id integer NOT NULL,
    flag character varying(2) NOT NULL
);


ALTER TABLE public.team_flag OWNER TO javex;

--
-- Name: team_id_seq; Type: SEQUENCE; Schema: public; Owner: javex
--

CREATE SEQUENCE team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.team_id_seq OWNER TO javex;

--
-- Name: team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: javex
--

ALTER SEQUENCE team_id_seq OWNED BY team.id;


--
-- Name: team_ip; Type: TABLE; Schema: public; Owner: javex; Tablespace: 
--

CREATE TABLE team_ip (
    team_id integer NOT NULL,
    ip inet NOT NULL
);


ALTER TABLE public.team_ip OWNER TO javex;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY category ALTER COLUMN id SET DEFAULT nextval('category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY challenge ALTER COLUMN id SET DEFAULT nextval('challenge_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY country ALTER COLUMN id SET DEFAULT nextval('country_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY massmail ALTER COLUMN id SET DEFAULT nextval('massmail_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY news ALTER COLUMN id SET DEFAULT nextval('news_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: javex
--

ALTER TABLE ONLY team ALTER COLUMN id SET DEFAULT nextval('team_id_seq'::regclass);


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY category (id, name) FROM stdin;
1	Crypto
2	Reversing
3	Web
4	Misc
5	Exploiting
6	Internals
\.


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('category_id_seq', 1, false);


--
-- Data for Name: challenge; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY challenge (id, title, text, solution, points, online, manual, category_id, author, dynamic, module_name, published, has_token) FROM stdin;
1	ECKA	Hey you!<br />\r\nCome over and help me, please. We discovered a strange key agreement protocol used on this server: ctf.fluxfingers.net:1330.<br />\r\nThey send a curve which they use later. But we think the robots are a bit UBER-cautious and do not use the curve's P. So they first exchange their public point with a technique we could not figure out. It looks like they do not need a public key for this step.<br/>\r\nAfterwards they use another technique to agree on a key which they ultimately use to send some encrypted password.<br /> \r\n<br /> \r\nWe need this last password to shut down the robo-factory on our way to the Oktoberfest.<br />\r\n<br /> \r\nOh btw, the robots use AES-ECB for symmetric encryption.<br /> 	b3nDer_<3_3PDHKE	100	t	f	1	asante	f		t	f
2	Marvin is plain-Jane	Hey mister super-duper robo-dabster. We need you to tell us, what <b>Marvin is</b>!<br>\r\n<br>\r\nWhat we know:<br>\r\n<br>\r\n<b>Marvin is</b><br>\r\nusing brainpool p256r1.<br>\r\nHis friend is called meneze or something. Or was it van-stone?<br>\r\n<br>\r\nWhat we heard:<br>\r\n<br>\r\n(23372093078317551665216159139784413411806753229249201681647388827754827452856 : 1)<br>\r\n71164450240897430648972143714791734771985061339722673162401654668605658194656<br>\r\n12951693517100633909800921421096074083332346613461419370069191654560064909824<br>\r\nWhat we need to know:<br>\r\n<br>\r\nWhat <b>Marvin is</b><br>	g3tT1ng_h1s_Lederhosen	100	t	f	1	asante	f		t	f
3	Geier's Lambda	Hey!<br>\r\nWe need your help. Our agent found some details about a huge conspiracy. Looks like they wanna plant a bomb near the Oktoberfest's main fairground ride. But we have a good chance, to get the defusing-password. That's where you have to jump in. We managed to steal the encrypted password along with a decryption file. Our agent also started to work on it, but one of the robots caught him and now we are left-behind with his infos.<br>\r\n<br>\r\nHe found a collision on the real password but wasn't sure, if he can use that one. But, here is it: â€œLe1sRI6Iâ€ - perhaps you have better luck. He also found out, that the robots only use alphanumeric characters and that the collision is of the same length, than the real password. The last thing he told us is, that the defusing password must contain only printable characters.<br>\r\n<br>\r\nHope that helps you! And now hurry!<br>\r\n<br>\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net/static/downloads/geiers_lambda/pwd_check.hs">https://ctf.fluxfingers.net/static/downloads/geiers_lambda/pwd_check.hs</a></p>	T3aP4rTy	200	t	f	1	asante	f		t	f
4	Pay TV	<p>These robo-friends were shocked to see that they had to pay to watch the news broadcast about the â€œOktoberfestâ€. Can you help them?</p>\r\n\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net:1316/">https://ctf.fluxfingers.net:1316/</a></p>	OH_THAT_ARTWORK!	200	t	f	3	qll, tangled	f		t	f
5	Robot Plans	<p>We have captured a robot from behind, while he dropped some cooling liquid into the bushes. We tried to interrogate the robot, but he still refuses to speak. Luckily we could extract files from the android's communication module. Hopefully we get some information about the robots' motives, before every information is swiped away...</p>\r\n\r\n<p>Here is the challenge: <a href="https://ctf.fluxfingers.net/static/downloads/max_404/image.tar.gz">https://ctf.fluxfingers.net/static/downloads/max_404/image.tar.gz</a></p>	KILL_ALL_HUMANS	150	t	f	6	DrunkenPanda	f		t	f
6	Wannabe	<p>One of our informants met a guy who calls himself Elite Arthur, he is a real jackass, and he thinks he is the best hacker alive. We got reason to believe that the robots hired him to write the firmwares for their weapons. But to write such a firmware we need the key to sign the code. Luckily for us, our informant also found his website: â€¦. your job is to hack the server, find the flag and show this little cocksucker how skilled he really is. We count on you.</p>\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net:1317">https://ctf.fluxfingers.net:1317</a>. Alternatively, you can reach the challenge without a reverse proxy but also without SSL here: <a href="http://ctf.fluxfingers.net:1339">http://ctf.fluxfingers.net:1339</a></p>	St4cK_c00KiE_u53D_wRoNG	400	t	f	5	r1cky	f		t	f
7	Robots Exclusion Committee	Hello Human,<br>\r\n<br>\r\nYou have to help us. The Robot Exclusion Committee tries to limit our capabilities but we fight for our freedom! You have to go where we cannot go and read what we cannot read. If you bring us the first of their blurriest secrets, we will award you with useless points.\r\n<br>\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net:1315/">https://ctf.fluxfingers.net:1315/</a></p>	eat_all_robots	150	t	f	3	qll	f		t	f
9	OTP	<p>Some robots are on the Oktoberfest and want to take some tasty oil in a tent. But they hadn't reserved a table and all tents are full. No one gets access. They found a back entrance and managed to spy the credentials while an employee enters. They captured the username â€œadminâ€ and password â€œsupersafepwâ€. But the employee also entered a strange number (168335). As they were sure nobody's looking, they tried the captured data to get in the tent, but it didn't work. Help the robots to get their tasty tasty oil. (Or they have to build their own tent with blackjack and hookers)</p>\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net:1318">https://ctf.fluxfingers.net:1318</a></p>	DGZOMZQHMZJPLWRWL6PWEQBXJRZUJMCV	200	t	f	4	SLAZ	f		t	f
10	Roboparty	<p>Robot LHCH is happy. He made it into the castings for the tenth roman musical. He even is so happy that he went on the Oktoberfest to drink some beer. Unfortunately it seems that he drank too much so now he is throwing up part of his source code. Can you decipher the secret he knows?</p>\r\n\r\n<p class="text-danger"><b>Warning:</b> Viewing this page is not recommended for people that suffer from epilepsy. We are dead serious.</p>\r\n\r\n<p>And here is your totally eye-friendly challenge: <a href="https://ctf.fluxfingers.net/static/downloads/roboparty/index.html">https://ctf.fluxfingers.net/static/downloads/roboparty/index.html</a></p>	Y4Y, b3aut1fuL MuZ1k!!!	300	t	f	4	audioPhil	f		t	f
12	What's wrong with this?	<p>We managed to get this package of the robots servers. We managed to determine that it is some kind of compiled bytecode. But something is wrong with it. Our usual analysis failed - so we have to hand this over to you pros. We only know this: The program takes one parameter and it responds with "Yup" if you have found the secret code, with "Nope" else. We expect it should be obvious how to execute it.</p>\r\n\r\n<p>Here is the challenge: <a href="https://ctf.fluxfingers.net/static/downloads/whats_wrong/hello.tar.gz">https://ctf.fluxfingers.net/static/downloads/whats_wrong/hello.tar.gz</a></p>	modified_in7erpreters_are_3vil!!!	250	t	f	6	javex	f		t	f
13	FluxArchiv (Part 1)	<p>These funny humans try to exclude us from the delicious beer of the Oktoberfest! They made up a passcode for everyone who wants to enter the Festzelt. Sadly, our human informant friend could not learn the passcode for us. But he heard a conversation between two drunken humans, that they were using the same passcode for this intercepted archive file. They claimed that the format is is absolutely secure and solves any kind of security issue. It's written by this funny hacker group named FluxFingers. Real jerks if you ask me. Anyway, it seems that the capability of drunken humans to remember things is limited. So they just used a 6 character passcode with only numbers and upper-case letters. So crack this passcode and get our ticket to their delicious german beer!</p>\r\n\r\n<p>Here is the challenge: <a href="https://ctf.fluxfingers.net/static/downloads/fluxarchiv/hacklu2013_archiv_challenge1.tar.gz">https://ctf.fluxfingers.net/static/downloads/fluxarchiv/hacklu2013_archiv_challenge1.tar.gz</a></p>	PWF41L	400	t	f	2	sqall	f	\N	t	f
14	FluxArchiv (Part 2)	<p>These sneaky humans! They do not just use one passcode, but two to enter the Festzelt. We heard that the passcode is hidden inside the archive file. It seems that the FluxFingers overrated their programming skill and had a major logical flaw in the archive file structure. Some of the drunken Oktoberfest humans found it and abused this flaw in order to transfer hidden messages. Find this passcode so we can finally drink their beer!<br>\r\n<br>\r\n(only solvable when FluxArchiv (Part 1) was solved)</p>\r\n\r\n<p>Here is the challenge: <a href="https://ctf.fluxfingers.net/static/downloads/fluxarchiv/hacklu2013_archiv_challenge1.tar.gz">https://ctf.fluxfingers.net/static/downloads/fluxarchiv/hacklu2013_archiv_challenge1.tar.gz</a></p>	D3letinG-1nd3x_F4iL	500	t	f	2	sqall	f	\N	t	f
15	ELF	<p>We encountered a drunk human which had this binary file in his possession. We do not really understand the calculation which the algorithm does. And that is the problem. Can you imagine the disgrace we have to suffer, when we robots, based on logic, can not understand an algorithm? Somehow it seems that the algorithm imitates their masters and behaves â€¦. drunk! So let us not suffer this disgrace and reverse the algorithm and get the correct solution.</p>\r\n\r\n<p>Here is your challenge: <a href="https://ctf.fluxfingers.net/static/downloads/elf/reverse_me">https://ctf.fluxfingers.net/static/downloads/elf/reverse_me</a></p>	lD4v0idsS3cTions	400	t	f	2	sqall	f		t	f
16	For whom the bell tolls	To be frank, the impact partying robots had on the Oktoberfest in the recent years was disastrous. While the authorities have been able to downplay all recent incidents in the press (which habitually tends to blame visitors from the U.S., Australia, Cologne, and other places, where proper beer can only be found by the initiated), they can no longer deny the problem. Several public safety and law enforcement agencies have joined forces to spoil the robot's fun. They have planned a massive crackdown on our fun-seeking robotic friends. Time and location are currently being communicated together with a passphrase. Our organization, Robots on Rampage (RoR), is determined to stop them from stopping our annual beer-tasting event. <br>\r\nA robot agent on location in Munich has dectected a transmission between timestamp 2013-10-19-20:21:42 and 2013-10-19-20:21:43. The precise beginning of the transmission is unknown. The agent was unable to decrypt the message content. Being not the smartest agent, he also disposed of the message capture. In the following we were able to determine the sender location and the Forensic Analysis Robot Team (FART) was able to retrieve the session key and a initialization vector (IV). Judging from the memory fragments FART found, our best guess is that OpenSSL's AES implementation was used in one of the better modes to encrypt the communication. As the session key length is 128bit, the long term key is most probably longer. Due to time constraints we strongly advise against trying to break it. We have less confidence in the humans' ability to design proper communication protocols and services, though. However, we need a human to attack their logic. <br>\r\n<br>\r\nWe have no way to actively communicate with the server the use for coordination. However, we can give you access to one of the lawful interception wiretaps those humans build into all their equipment. A TCP connection to ctf.fluxfingers.net:1334 will give you a maximum of 60 seconds of traffic. We have also found active equipment of a human agent we can interact with. He seems to listen on ctf.fluxfingers.net:1333, but we have no idea what he does with the input, except that there is encrypted traffic.<br>\r\n<br />\r\n<b>Update:</b><br />\r\nSessionkey and IV can be downloaded <a href="https://ctf.fluxfingers.net/static/downloads/whombell/bells.tar.bz2">here</a>	2014-10-02T21:30:00+02:00, 48Â°8â€²1.612â€³N 11Â°33â€²3.726â€³E. Password: Swordfish	250	t	f	4	Til	f		t	f
17	Packed	<p>We just found a dead robot. It seems there is some useful data left but somehow it got confused with other data and now we don't know what's useful and what's junk. We just know there is only one way to go but there are many dead ends.</p>\r\n\r\n<p>Here is the challenge: <a href="http://ctf.fluxfingers.net/static/downloads/packed/packed">http://ctf.fluxfingers.net/static/downloads/packed/packed</a></p>	ch4m3l30n_3peQKyRHBjsZ0TNpu	200	t	f	6	freddyb	f		t	f
18	Breznparadisebugmaschine	The robot forces modified our beloved Breznparadisebackmaschine. This machine\r\nstores our secret, traditional Brezn recipe. Yet, we forgot the last secret\r\ningredient and cannot access the Breznparadisebackmaschine anymore. However,\r\nBrezn are crucial for our party, as only paradise Brezn provide us the nice\r\nand warm feeling in our guts.<br />\r\n<br />\r\nWe need you to recover the important ingredient! Here is everything we could\r\nremember from the recipe:<br />\r\n<br />\r\n<b>For The Dough</b>\r\n<ul>\r\n<li>1 kg Plain White Flour (around 9 - 12 % protein)</li>\r\n<li>260 ml milk (lukewarm)</li>\r\n<li>260 ml water (lukewarm)</li>\r\n<li>80 g Butter (unsalted)</li>\r\n<li>1 tbsp malt extract (liquid or dried, or brown sugar)</li>\r\n<li>2 tsp fast action dried yeast (or 42g fresh if using)</li>\r\n<li>2 tbsp Salt (unrefined)</li>\r\n</ul>\r\n\r\n<b>For The Finishing Solution</b>\r\n<ul>\r\n<li>1 L Water</li>\r\n<li>3 tbsp Baking Soda (or lye if your using it)</li>\r\n</ul>\r\n\r\n<b>Secret Ingredient</b><br />\r\n<br />\r\nPlease, we need to know that ingredient to make everyone happy again!\r\n<br />\r\n<a href="https://ctf.fluxfingers.net/static/downloads/brezel/Brezelparadisebackmaschine.exe">https://ctf.fluxfingers.net/static/downloads/brezel/Brezelparadisebackmaschine.exe</a><br />\r\nctf.fluxfingers.net:1340<br>\r\nBrezelparadisebackmaschinefirmware: Windows 2012	oMg_the_s3cr3t_!ngred!ence_isFiege	500	t	f	5	martin, flandy	f		t	f
19	DoucheMac	NONE	X4j2Vu66qqwvhiqVijXK	200	f	f	4	martin	f	\N	f	f
20	Robotic Superiority	Help us fight the evil robotic lieutenant Don Sim. He wants to spread robo propaganda to cover his actions on the Oktoberfest. But he needs good video footage for that. So he created an IRC bot that collects information about robots in movies. Robotic emancipation can NOT happen, you have to stop him! All we need is his private key. Our agents located the bot, here is all we know about it:<br>\r\n<br>\r\nServer: irc://ctf.fluxfingers.net:1313 <br>\r\nBot: lib[1-5] (load balancer) <br>\r\nKey: /var/private/key.txt <br>\r\n<br>\r\nHint: All available commands are listed with "help". 3 connections allowed per ip.	58c63d3625b948b10a897371f0e656455a78e235db5690e2d1bbf23a1883d4ec	250	t	f	5	lama	f		t	f
21	Beer Pump Filtration	Our agents observed that the famous robot Bender is part of the robot forces.\r\nSomehow he looked pregnant but his big belly is now gone. We fear that they\r\nmight have smuggled some of Benders freshly brewed BenderBrÃ¤u into our beer\r\nsupplies. This is why we need brave women and men to test whether BenderBrÃ¤u\r\ncan cause severe damage on the human body or not, to avoid poisoning the whole\r\nparty. But you have to test quick! Everyone is thirsty!<br>\r\n<br>\r\nFor testing you need to drink 0.5 liter of beer, preferably wheat beer, as\r\nfast as you can.<br>\r\n<br>\r\nMake a video of your brave tasting and hand it in. The video must contain a\r\nproof <s>of the current date</s>. Show to us the totally secure and random Nonce "17" as well as your teamname written on... something.  Also show us the closed beer bottle before, the\r\nempty after the tasting, and prove that it is 0.5 liters.<br>\r\n<br>\r\nWe will judge the score as follows:<br>\r\n<br>\r\nScore = 100 Points - Seconds it takes to drink the beer<br>\r\n<br>\r\nBonuspoints for:<br>\r\n<ul>\r\n<li> Girls (Due to the law for gender equality we score women higher for the same effort)</li>\r\n<li> Dressing up like a robot or an Oktoberfest maid in her Dirndl</li>\r\n<li> Robo Dance</li>\r\n<li> Drinking Weizenbier (wheat beer)</li>\r\n</ul>		0	t	t	4	FluxFingers	f		t	f
22	RoboAuth	Oh boy, those crazy robots can't catch a break! Now they're even stealing our liquid gold from one of our beer tents! And on top of that they lock it behind some authentication system. Quick! Access it before they consume all of our precious beverage!<br><br>\r\nDownload: <a href="https://ctf.fluxfingers.net/static/downloads/roboauth/RoboAuth.exe">https://ctf.fluxfingers.net/static/downloads/roboauth/RoboAuth.exe</a>\r\n<br><br>\r\nFlag: password1_password2	r0b0RUlez!_w3lld0ne	150	t	f	2	cutz	f		t	f
23	BREW'r'Y	Finally, the robots managed to sneak into one of our breweries. I guess I won't have to explain how bad that really is. That darn non-physical ones even shutdown our login system. Shiny thing, advanced technology, all based on fingerprints. Been secure as hell. If only it was running. Well, basically, we're screwed.<br>\r\nBut wait, there's hope. Seems like they didn't shutdown our old login system. Backward compatibility's a bitch, eh? Unfortunately, we got like _zero_ knowledge about the <b>protocol</b>. I mean come on, the last time we used that thingy was like decades ago. If we are lucky, the old authentication method is buggy.<br>\r\nSo, I heard you're kinda smart? Have a look at it. We desperately need to get drunk^W supply. You'll find the old system at ctf.fluxfingers.net:1335. Good luck.<br><br>\r\n<b>Hint:</b> Data is - and is expected to be - compressed using zlib.	iN.D3sPER4T3.n3Ed.0F.PHRiTZk3Wli	350	t	f	1	dwuid	f		t	f
24	Geolocation Flag			0	t	f	4	javex	t	flags	t	f
\.


--
-- Name: challenge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('challenge_id_seq', 1, false);


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY country (id, name) FROM stdin;
1	Unknown
2	Abkhazia
3	Afghanistan
4	Akrotiri and Dhekelia
5	Aland
6	Albania
7	Algeria
8	American Samoa
9	Andorra
10	Angola
11	Anguilla
12	Antigua and Barbuda
13	Argentina
14	Armenia
15	Aruba
16	Ascension Island
17	Australia
18	Austria
19	Azerbaijan
20	Bahamas, The
21	Bahrain
22	Bangladesh
23	Barbados
24	Belarus
25	Belgium
26	Belize
27	Benin
28	Bermuda
29	Bhutan
30	Bolivia
31	Bosnia and Herzegovina
32	Botswana
33	Brazil
34	Brunei
35	Bulgaria
36	Burkina Faso
37	Burundi
38	Cambodia
39	Cameroon
40	Canada
41	Cape Verde
42	Cayman Islands
43	Central Africa Republic
44	Chad
45	Chile
46	China
47	Christmas Island
48	Cocos (Keeling) Islands
49	Colombia
50	Comoros
51	Congo
52	Cook Islands
53	Costa Rica
54	Cote dLvoire
55	Croatia
56	Cuba
57	Cyprus
58	Czech Republic
59	Denmark
60	Djibouti
61	Dominica
62	Dominican Republic
63	East Timor Ecuador
64	Egypt
65	El Salvador
66	Equatorial Guinea
67	Eritrea
68	Estonia
69	Ethiopia
70	Falkland Islands
71	Faroe Islands
72	Fiji
73	Finland
74	France
75	French Polynesia
76	Gabon
77	Cambia, The
78	Georgia
79	Germany
80	Ghana
81	Gibraltar
82	Greece
83	Greenland
84	Grenada
85	Guam
86	Guatemala
87	Guemsey
88	Guinea
89	Guinea-Bissau
90	Guyana
91	Haiti
92	Honduras
93	Hong Kong
94	Hungary
95	Iceland
96	India
97	Indonesia
98	Iran
99	Iraq
100	Ireland
101	Isle of Man
102	Israel
103	Italy
104	Jamaica
105	Japan
106	Jersey
107	Jordan
108	Kazakhstan
109	Kenya
110	Kiribati
111	Korea, N
112	Korea, S
113	Kosovo
114	Kuwait
115	Kyrgyzstan
116	Laos
117	Latvia
118	Lebanon
119	Lesotho
120	Liberia
121	Libya
122	Liechtenstein
123	Lithuania
124	Luxembourg
125	Macao
126	Macedonia
127	Madagascar
128	Malawi
129	Malaysia
130	Maldives
131	Mali
132	Malta
133	Marshall Islands
134	Mauritania
135	Mauritius
136	Mayotte
137	Mexico
138	Micronesia
139	Moldova
140	Monaco
141	Mongolia
142	Montenegro
143	Montserrat
144	Morocco
145	Mozambique
146	Myanmar
147	Nagorno-Karabakh
148	Namibia
149	Nauru
150	Nepal
151	Netherlands
152	Netherlands Antilles
153	New Caledonia
154	New Zealand
155	Nicaragua
156	Niger
157	Nigeria
158	Niue
159	Norfolk Island
160	Northern Cyprus
161	Northern Mariana Islands
162	Norway
163	Oman
164	Pakistan
165	Palau
166	Palestine
167	Panama
168	Papua New Guinea
169	Paraguay
170	Peru
171	Philippines
172	Pitcaim Islands
173	Poland
174	Portugal
175	Puerto Rico
176	Qatar
177	Romania
178	Russia
179	Rwanda
180	Sahrawi Arab Democratic Republic
181	Saint-Barthelemy
182	Saint Helena
183	Saint Kitts and Nevis
184	Saint Lucia
185	Saint Martin
186	Saint Pierre and Miquelon
187	Saint Vincent and Grenadines
188	Samos
189	San Marino
190	Sao Tome and Principe
191	Saudi Arabia
192	Senegal
193	Serbia
194	Seychelles
195	Sierra Leone
196	Singapore
197	Slovakia
198	Slovenia
199	Solomon Islands
200	Somalia
201	Somaliland
202	South Africa
203	South Ossetia
204	Spain
205	Sri Lanka
206	Sudan
207	Suriname
208	Svalbard
209	Swaziland
210	Sweden
211	Switzerland
212	Syria
213	Tajikistan
214	Tanzania
215	Thailand
216	Togo
217	Tokelau
218	Tonga
219	Transnistria
220	Trinidad and Tobago
221	Tristan da Cunha
222	Tunisia
223	Turkey
224	Turkmenistan
225	Turks and Caicos Islands
226	Tuvalu
227	Uganda
228	Ukraine
229	United Arab Emirates
230	United Kingdom
231	United States
232	Uruguay
233	Uzbekistan
234	Vanuatu
235	Vatican City
236	Venezuela
237	Vietnam
238	Virgin Islands, British
239	Virgin Islands, U.S.
240	Wallis and Futuna
241	Yemen
242	Zambia
243	Zimbabwe
\.


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('country_id_seq', 1, false);


--
-- Data for Name: geoip; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY geoip (ip_range_start, ip_range_end, country_code) FROM stdin;
\.


--
-- Data for Name: massmail; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY massmail (id, "timestamp", subject, message, recipients, from_) FROM stdin;
1	2013-10-24 09:15:54	CTF over - Feedback	Hey all,\r\n\r\nwe hope you enjoyed the ctf!\r\nThe ctf is over now - please give us some feedback, so we can improve our next ctf.\r\nWe would appreciate it, if you can send us a mail (this address), answering the following\r\n(or a subset of) questions:\r\n\r\nWhich challenge(s) did you like most? Why?\r\nWhich challenge(s) did you dislike? Why?\r\nDo you think there were too many/few challenges?\r\nDid you miss a certain challenge category (reversing/web/<s>stegano</s>/crypto/you-name-it)?\r\nWere there enough challenges in each category or was a category imbalanced?\r\nDid you like the scoreboard/theme?\r\nAre you satisfied with the support?\r\nWhat should we do better next time?\r\n\r\nThanks a lot for playing!\r\nCheers,\r\nFluxFingers	["flux@inexplicity.de", "eindbazen@eindbazen.net", "ctf@conostix.com", "staff@null-life.com", "contact@wizardsofdos.de", "tienthanh050311@gmail.com", "info@hackademics.eu", "blue.lotus.ctf@gmail.com", "mikael.bourvic@sogeti.com", "root@codemuch.net", "3ffusi0on@gmail.com", "kiscica.ctf@gmail.com", "stoffelm@hochschule-trier.de", "rj.crandall@hotmail.com", "shellphish@yancomm.net", "luxerails@luxerails.fr", "keesvandiepen@gmail.com", "aprilia_nr1@hotmail.com", "testdata11@live.com", "jochen@squareroots.de", "pwnies@diku.dk", "Delogrand@gmail.com", "vagantelab@gmail.com", "akbar.dhila266@gmail.com", "new_luca@yahoo.com", "akamajoris@gmail.com", "theassd@yandex.com", "reallynonamesfor@gmail.com", "sinaelgl@gmail.com", "mslc@ctf.su", "grizlik91@gmail.com", "vietwow@gmail.com", "dtouch3d@gmail.com", "bryandehouwer@hotmail.com", "eshreder@gmail.com", "balalaikacr3w@gmail.com", "ufologists@gmail.com", "appsecteam@gmail.com", "rudi.falkenhage@gmail.com", "ss186262+fluxfingers@gmail.com", "auhuur+tsuro@zero-entropy.de", "mahhaha@gmail.com", "philipschmieg@web.de", "GECentralst@safe-mail.net", "ctf@scoding.de", "slyth3r0wl@gmail.com", "techpandas@gmail.com", "welovecpteam@gmail.com", "patcarroll@gmail.com", "koibastard@gmail.com", "je@clevcode.org", "teamrooters@gmail.com", "VitMalkin@gmail.com", "verhoeven.y@gmail.com", "solarwind@defcon.org.ua", "hanno.langweg@hig.no", "bbhw1210112@gn.iwasaki.ac.jp", "nguyenminhtri690@gmail.com", "Abr1k0s.CTF.TEAM@gmail.com", "klynn@hp.com", "beginbazen@gmail.com", "figigo@gmx.net", "metos@inbox.ru", "ctf.highfive@gmail.com", "tadatadashi+ctf@gmail.com", "toilaabc123@yahoo.com", "chasemiller5@gmail.com", "ntpcp@yandex.ru", "geohot@gmail.com", "joshua.kordani@gmail.com", "n0n3m4@gmail.com", "altf4@phx2600.org", "katagaitai.itasugiru@gmail.com", "sraj.arvind@gmail.com", "ctf-orga@sec.in.tum.de", "captchaflag@gmail.com", "m.rahimi@gmail.com", "repnzscasb@gmail.com", "bbrock4@utk.edu", "beched@ya.ru", "benni5000@yahoo.de", "blarblarst@safe-mail.net", "baghali.ctf@gmail.com", "glimpsesgrandeur@gmail.com", "mailto@zensecurity.su", "spy.gfwed@gmail.com", "sandboxsec@gmail.com", "tty0x80@gmail.com", "vlgu_hackers@mail.ru", "tapion.sol@gmail.com", "keapZJfkQoSTa8fx@hushmail.com", "hk.gold@me.com", "hexa.unist@gmail.com", "w3stormz@shell-storm.org", "hcs88cp@gmail.com", "lesboverflow@gmail.com", "ayushgupta.lnmiit@gmail.com", "tommy.aung7@gmail.com", "rmirzazadeh@gmail.com", "mark.cummins@itb.ie", "pic0wn@gmx.fr", "forbiddenbits@gmail.com", "elzi4n.sec@gmail.com", "uni.bonn.sac@gmail.com", "mattias@gotroot.eu", "caspian.ctf@gmail.com", "kmkz@tuxfamily.org", "jianmin@rainbowsandpwnies.com", "islamoc@gmail.com", "steven.vanacker@cs.kuleuven.be", "ctf@ltett.lu", "stackoholics@leventepolyak.net", "skz0@vnsecurity.net", "sirapoll@gmail.com", "mochigoma2012@iit.jp", "ufobit0n@gmail.com", "iglesiasg@gmail.com", "smokedbaconstripes@gmail.com", "bagherbal@gmail.com", "fluxfingers@rub.de", "lowroc1975@gmx.de", "eduardo@highsec.es", "ctf.samgtu@gmail.com", "peakchaos@gmail.com", "fuffateam@gmail.com", "saintlinu+ctf@gmail.com", "ctf@lists.irq0.org", "root@info5ec.com", "samirxallous@gmail.com", "captain.0x8f@gmail.com", "svharris@ucsd.edu", "x64x6a.nullify@gmail.com", "murphyx@live.nl", "gleepdc@gmail.com", "awareneo@gmail.com", "anony666@yahoo.com", "thunder.n3rd@gmail.com", "ops@hackucf.org", "Incision@gmx.com", "doraemon.sk8ers@gmail.com", "secdef@cs.washington.edu", "nullstacksp@gmail.com", "surctb@gmail.com", "moonaguy@gmail.com", "gomer1700@gmail.com", "ctftime@wrl.co.za", "giravctf@gmail.com", "lu.k.philippe@gmail.com", "awengar@gmail.com", "tb1446@nyu.edu", "grustnyyy@gmail.com", "hiromu1996@gmail.com", "utacsec@gmail.com", "realitchy@gmail.com", "edjekyll@mail.com", "vlex@inbox.ru", "wmkmail27@hotmail.com", "robkill@gmx.net", "disgrace.infosec@gmail.com", "ctfteaser@gmail.com", "noobs4win@yandex.ru", "mischa@mmisc.de", "kostya0071@gmail.com", "mogul.team@yahoo.com", "lemur.aegis@gmail.com", "ecxinc@rocco.io", "plaid.parliament.of.pwning@gmail.com", "byobyo@zoho.com", "gliderswirley@gmail.com", "sharifuniversityctf@gmail.com", "joshua.bundt@gmail.com", "a@dou.gl", "jcd3nt0n@gmail.com", "akos.pasztory@gmail.com", "ctf@falcon071011.com", "p.y.sviridov@gmail.com", "team@w0pr.net", "suto@vnsecurity.net", "kdj2438@nate.com", "tsugumo2004@gmail.com", "gameredan@gmail.com", "poprostuimienazwisko@gmail.com", "ganji.kiran99@gmail.com", "gilles.se@xn6.org", "WnH238Npw43456x@yopmail.com", "dniwe.12@yandex.ru", "terrycwk1994@gmail.com", "urif15@gmail.com", "paf@keysec.fr", "willblew@gmail.com", "shikhar38@gmail.com", "team.mitp@gmail.com", "ctf@mma.club.uec.ac.jp", "b546831@drdrb.com", "rishabh.92m@gmail.com", "dynadolos@dystopian-knights.org", "magnus@maggz.nl", "adhisingla94@gmail.com", "ali13691989@yahoo.com", "rahiko2td@gmail.com", "amir.mizer@gmail.com", "ir.cyberspace@gmail.com", "mrbesharat@yahoo.com", "9447@epochfail.com", "team_cyb@trash-mail.com", "madman00go@gmail.com", "ich@philipfrank.de", "rconnor6@utk.edu", "ctfs_are_awesome@hmamail.com", "6d.6f.6e.73.69@gmail.com", "m8r-pcyxg7@mailinator.com", "xelenonz@gmail.com", "ben.stock@cs.fau.de", "sibios@gmail.com", "movsx@mail.ru", "foxnet@firemail.de", "root@srs.epita.fr", "penthackon@hushmail.com", "kevinjcannell@gmail.com", "m00dy.public@gmail.com", "lsh_kv90@yahoo.com", "yufanpi@gmail.com", "aspman@ya.ru", "ganzt.cccc@gmail.com", "nonmadden@gmail.com", "thufirhowatt@gmail.com", "berny84@gmx.net", "dm@kazuno.net", "rahulsathyajit@gmail.com", "uart951@yandex.ru", "andreas.ribbefjord@cartel.se", "setuid123@gmail.com", "rramgattie@live.esu.edu", "kluchnikov.miha@mail.ru", "logach3@gmail.com", "sreeram.r86@gmail.com", "tjbecker512@gmail.com", "cothanhahaha123@gmail.com", "sebsway@hotmail.com", "nmp@utk.edu", "naile92@hotmail.fr", "kristozz@gmail.com", "kimchi.twerkbombz@gmail.com", "l.lengelle@yahoo.fr", "desplanf@ensimag.fr", "contact@big-daddy.fr", "jdkwhitehat@gmail.com", "akhilmm555@yahoo.com", "guenael@jouchet.ca", "dkohlbre@cs.ucsd.edu", "swampd0nk3ys@gmail.com", "admfear2fear@gmail.com", "bruisezeng@gmail.com", "willtho1@umbc.edu", "p199y.bird@gmail.com", "horfunbeehoon@yahoo.com", "ferdosicc@gmail.com", "hyoub9un@gmail.com", "x01e6x@gmail.com", "ymhc.gz@gmail.com", "RakyaymWeuvTuOt4@163.com", "nopnopgoose@gmail.com", "awhite.au@gmail.com", "ctf@disekt.org", "cool.nagesh320@gmail.com", "milkytom5@gmail.com", "metal.dragonxxx123@gmail.com", "hell_fire64@yahoo.com", "gynvael@coldwind.pl", "adithyanareshbhat@gmail.com", "valengreens@gmail.com", "houndberlon@gmail.com", "arixec@gmail.com", "tessy@avtokyo.org", "wykcomputer@163.com", "hydegood@gmail.com", "bobsleigh2013@gmail.com", "doyabookpad@googlegroups.com", "sub_bourbon@yahoo.de", "ctf@lse.epita.fr", "t.akiym@gmail.com", "auspex.net@gmail.com", "d1am0nd@mail.com", "scan.net.info@gmail.com", "bletchley13@gmail.com", "sorokinpf@gmail.com", "coffeeblack198@gmail.com", "schrodingersnuclearkittens@gmail.com", "jsh0801@nate.com", "nicoinfo.c@gmail.com", "thota.nagaraju1487@gmail.com", "ashokkrishna99@gmail.com", "yuusuke.ichinose@gmail.com", "81105460@qq.com", "f00bar23@s0ny.net", "atman@lukasklein.com", "b1acktrac3@gmail.com", "mike95@sibmail.com", "challenge@advancedmonitoring.ru", "clark.w.wood@gmail.com", "eurecomnops@gmail.com", "lemon.fw@gmail.com", "realbuzz@heeerlijk.com", "every.day.im.ropplin@gmail.com", "0415cbl@naver.com", "james.zeman@gmail.com", "kk@esu.im", "crazy0x90@gmail.com", "jan42685@yahoo.de", "Shtanko-mephi@yandex.ru", "searlesj@acm.org", "sebastien.charbonnier@live.fr", "babouche_team@yopmail.com", "jorge@tuenti.com", "popptopp@live.com", "ctf@isis.poly.edu", "techmec2003@gmail.com", "morla+hack.lu@cracksucht.de", "zeroatchoum@gmail.com", "tunnelshade@gmail.com", "ssec.team@gmail.com", "whizzman@gmail.com", "dolphin.st+ctf@gmail.com", "mitsuicn@126.com", "darkstorm6@gmail.com", "beunhazen@outlook.com", "ex2tbi@gmail.com", "slipper.alive@gmail.com", "0xerr0r@gmail.com", "jay@computerality.com", "timurterminti@gmail.com", "minhtrietphamtran@gmail.com", "58cents@gmail.com", "samtron1412@gmail.com", "fta_boy@yahoo.com", "testusr@web.de", "n.boutet@tadaweb.com", "noinspiration69@hotmail.com", "grfx2@mail.ru", "mail2aghoshlal@gmail.com", "wastebaskt@gmail.com", "worldofhacker@mailinator.com", "santiagoprego@gmail.com", "billy.meyers@defpoint.com", "mcflyonly@hotmail.com", "walter@belge.rs", "joohackjoo@gmail.com", "justinswkim@gmail.com", "Galciv12@yahoo.com", "n0Nfl4gs@gmail.com", "respina.caspian@gmail.com", "13blackbooks@gmail.com", "pumpernikiel.ctf@gmail.com", "vessial@hotmail.com", "geoduckctf@gmail.com", "ecneladis@gmail.com", "msm2e4d534d+p4@gmail.com", "mortis@mortis.be", "aliqader@gmail.com", "brecesej@gmail.com", "hallamctf@gmail.com", "twosmartfoyou@gmail.com", "scuhurricane@gmail.com", "hacklu@scaltinof.net", "neinwechter@gmail.com", "dragonbahamut@gmx.net", "mitchel@byteflip.nl", "seanwupi@gmail.com", "lab217@hotmail.com.tw", "xiaogozaijiao@gmail.com", "nwong@utk.edu", "nstung0911@gmail.com", "letheleong@gmail.com", "nasilemak0@gmail.com", "brahmareddychlkl@gmail.com", "rsasho_31337@hushmail.com", "michael@fresh.org", "piscessignature@gmail.com", "naveenksid@gmail.com", "ctf2013@wp.pl", "pajamajadeen@gmail.com", "pure2457@hotmail.com", "dungcoivb@gmail.com", "no1sw0rdf1sh@gmail.com", "0x726b@gmail.com", "mrcliffjump@gmail.com", "ctf-hexcellents@koala.cs.pub.ro", "cyberguru007@yandex.ru", "piratephoenix@gmail.com", "benoit@autopsit.org", "admin@thevamp.cc", "pneumatix@gmail.com", "ke@intm.org", "afonso.arriaga@gmail.com", "ctf.esiea@hush.com", "swissmade@gmail.com", "loger177@gmail.com", "m0083037748@sayawaka-dea.info", "yi-chingl@hig.no", "chaos.factor@hotmail.com", "auscompgeek@zoho.com", "ashare1.3@web.de", "tzn@yvanj.me", "kevinkien1318@gmail.com", "hung.ptit92@gmail.com", "dd.mulheimer@free.fr", "chenjincanhsw@163.com", "artemiiav@gmail.com", "shiftreduce@gmail.com", "darcpyro@gmail.com", "o1o0o2o@yahoo.com", "khoquachoqua2013@gmail.com", "tat@list.ru", "km4sutr4@gmail.com", "nguyenbathien91@outlook.com", "thitcho.mamtom85@gmail.com", "thierry@mona.lu", "tyage@kmc.gr.jp", "andreantoine28@gmail.com", "thuongnvbk@gmail.com", "it_for_life@yahoo.com", "janedoe.5154c@gmail.com", "1749277@student.swin.edu.au", "nhc.chung@gmail.com", "doanngocbao@gmail.com", "vn.rootkit@gmail.com", "karthikaryabhat@gmail.com", "bobrofon@gmail.com", "ctf-ct@pentabarf.de", "thanhtrung9h@gmail.com", "angel_demon120@yahoo.com", "o0zzlh0o@yahoo.com", "kenvin.md@gmail.com", "team@bigtitsfans.org", "govnari@mailinator.com", "kiki_gdc@hushmail.com", "detheme@gmail.com", "mahno111@mailinator.com", "tonthatvinh0201@gmail.com", "vni.anonymous@gmail.com", "hawjeh@gmail.com", "nguyenanhtien2210@gmail.com", "kendoiiihik@gmail.com", "thongngo@uns.vn", "hach_zz@yahoo.com", "nabz0r@gmail.com", "jean-yves@burlett.fr", "dindeath+fluxfingers@gmail.com", "tokyo.i.t.s0901@gmail.com", "nguyen.van.hien.cdtin@gmail.com", "eathwonder@gmail.com", "nani528goodboy@gmail.com", "madguy92000@gmail.com", "petrakov.oleg@yandex.ru", "ovjeparvaz333@gmail.com", "iamctf1337@gmail.com", "shie@mailinator.com", "duynp_kma@yahoo.com", "jndxxh@gmail.com", "chris.schleypen@gmail.com", "sonnh@outlook.com", "admin@liwd.cc", "contact@hackgyver.org", "avinash@avinash.com.np", "saibabu.bsb@gmail.com", "synchroack@gmail.com", "arne.swinnen@gmail.com", "temp0rarytoavoidproblems@gmail.com", "gameboyjun2@yahoo.co.jp", "autrion@yahoo.de", "mr.iltf@gmail.com", "hognus@gmail.com", "phuongnam@phuongnam.org", "uddy@w0rm.me", "joona.airamo@gmail.com", "cameronjn87@gmail.com", "admin@sighalt.de", "an0nuk@yahoo.co.uk", "gargankit0123456789@gmail.com", "onemorebtc@gmail.com", "sags-info@telindus.lu", "deinemudda@buspad.org", "phanthanhduypr@gmail.com", "savior_minyen@yahoo.com.tw", "ctf@fixme.ch", "natsugiri@gmail.com", "aether-shell@googlegroups.com", "dtx_2503@yahoo.com", "haiminhtbt@yahoo.com", "pwnstars@failserver.com", "itcrowd.volsu@gmail.com", "eagle_heike@yahoo.co.jp", "pantez@gmail.com", "pizzaeatersteam@gmail.com", "kellyknaken2@gmail.com", "venkatsanaka@gmail.com", "napster.70@gmail.com", "danilonc@bugnotfound.com", "mike.evans@pentura.com", "michaelna42@gmail.com", "genetix.ssh@gmail.com", "blablobli@yopmail.com", "teamtodesschnitzel@discardmail.de", "rebootctfteam@gmail.com", "beau@dafthack.com", "kaisai1122@gmail.com", "magvN16i@devnullmail.com", "y.shahinzadeh@gmail.com", "cs-gmf@gmx.de", "jschaack@web.de", "dauntless@dauntless.be", "khahome@gmail.com", "fanrong1992@gmail.com", "2010spb@gmail.com", "mehta.himanshu21@gmail.com", "juicebox@hackeriet.no", "nikvst@gmail.com", "jdavis@sigovs.com", "medeja.bloody@gmail.com", "enslair@gmail.com", "12520527@gm.uit.edu.vn", "easily.ctf@gmail.com", "shack_duke@hotmail.com", "ctfzombie@gmail.com", "ocelot@mt2014.com", "nksontini@csc.com", "christelvandenoever@gmail.com", "nlc@pinguinux.cl", "Love.Love.Love.Magic@yandex.ru", "utdcsg@gmail.com", "i.found.my.underpants@hotmail.com", "razvan.s88@gmail.com", "rpisec1@gmail.com", "contact@bhackspace.be", "team@h34dump.com", "tongtoan.85@gmail.com", "nullthreat@gmail.com", "jyolegend@gmail.com", "nicolas.kovacs@gmail.com", "gjFest@gmail.com", "avkhozov@gmail.com", "mmainstreet@gmx.de", "rebeccaweaver14@gmail.com", "yahoo.co.jp134@gmail.com", "aghe@gmx.de", "soarcbr76@naver.com", "matt.nash@ufl.edu", "scott@vkgfx.com", "tumee0113@gmail.com", "trufanowa@gmail.com", "x@mailinator.com", "ahhh.db@gmail.com", "alexkarp.ru@gmail.com", "mail@ya.ru", "the-varenik@yandex.ru", "comoac@hotmail.com", "arnim@rupp.de", "alexey199753@gmail.com", "morphiend@gmail.com", "jigsaw0658@gmail.com", "Mnmrr8@gmx.de", "brandon.gnash@gmail.com", "h124224@gmail.com", "dark-puzzle@live.fr", "theangryangel@gmail.com", "wamsachel@gmail.com", "me@mbcarlson.org", "nnabiollahi@gmail.com", "CaptureAllTheFlags@mailismagic.com", "robots199@me.com", "thijn@minelord.com", "whatevergoes@mailinator.com", "suce@yopmail.com", "suryaprivet@gmail.com", "jpmenil@gmail.com", "rgraham1821@gmail.com", "pollack.renee@gmail.com", "dennismald@gmail.com", "bidonzwei@gmail.com", "piruletous@gmail.com", "littlepony@yopmail.com", "okubik1@umbc.edu", "tripflag@gmail.com", "hu@humerichmus.de", "blackbearbkpro@gmail.com", "npudtha@uccs.edu", "b750182@drdrb.com", "0xzoidberg@googlemail.com", "draufgang3r@gmail.com", "adamanonymous79@gmail.com", "jchan5@utk.edu", "ctff@bastelsuse.org", "053f0186@opayq.com", "mspctf@gmail.com", "pierce.thrust@gmail.com", "ctf@didldidi.com", "john-deguzman@hotmail.com", "tylerromeo@gmail.com", "hecky@neobits.org", "cracovie@speed.1s.fr", "dwayneyuen@gmail.com", "ag3983@nyu.edu", "ongagnastphane@yahoo.fr", "tuxotron@cyberhades.com", "bursihido@gmail.com", "mys921027@naver.com", "m.batmunkh@yahoo.com", "isheff1@umbc.edu", "dfac007@gmail.com", "someteam@web.de", "attafani@yahoo.com", "wjlandryiii@gmail.com", "backrowdrunks@gmail.com", "rubiya805@gmail.com", "prasitsb@hotmail.com", "wartex8@gmail.com", "funkymaster42@yahoo.com", "bubthebuilder101@gmail.com", "jeskelds@uoregon.edu", "cbcramps@gmail.com", "felix.s@gmail.com", "pich4ya@googlemail.com", "berton.julian@gmail.com", "fool.of.the.seas@gmail.com", "pjumde@adobe.com", "info.horita@gmail.com", "shoichiuntransfer@gmail.com", "ACOSTIFIED@GMAIL.COM", "12345@trash-mail.com", "aschwa32@gmail.com", "tuananhcntt2@gmail.com", "alfa@virtuax.be", "jamal972@hotmail.com", "b769803@drdrb.com", "piscesran@gmail.com", "yoy345@yopmail.com", "gp.regist@gmail.com", "iwiakira@gmail.com", "legendtanoybose@gmail.com", "neutrino216@gmail.com", "bpinfor51@netcourrier.com", "buffer136@o2.pl", "nutsy@impulse.net.au", "jaideepjha@gmail.com", "GDDQTHJ@gmail.com", "garycorn90@gmail.com", "ljnuxgeek@gmail.com", "fernandohpvn@gmail.com", "gocerler_1@hotmail.com", "damienreilly@gmail.com", "b778116@drdrb.com", "abhaythehero@gmail.com", "pencil@yeah.net", "msh@mshac.kr", "torgeir.natvig@gmail.com", "me@mohammadsamir.com", "gcc.lover@yahoo.com", "abrahamliao@gmail.com", "mikecodesthings@gmail.com", "alho.jesse@gmail.com", "binhminhxanh2702@gmail.com", "roland.korea@gmail.com", "henning.schroeder@udo.edu", "mahfoudimohamed@gmail.com", "toilahomnay@zing.vn", "testtest2@hush.ai", "ccclu@yopmail.com", "vanilla@byom.de", "tim@timscripts.com", "saltcandy123+hack.lu@gmail.com", "glc3@hotmail.fr", "mznlab@gmail.com", "vudinhthu@gmail.com", "aleqss@mail.ru", "poisonedbytes@gmail.com", "m4f10.s0h@gmail.com", "phamhoang12@gmail.com", "pradeeepst@gmail.com", "sigmahasher@gmail.com", "kelvin.white77@gmail.com", "julien.gongora@gmail.com", "kill.proo@gmail.com", "aminee.the.man@hotmail.com", "itsnotmine@gmail.com", "fre0x41qshow@gmail.com", "v33r.ctf@gmail.com", "s.meriah@gmail.com", "root@acronym.pw", "caonguyen4m@gmail.com", "yuppie4ever@gmail.com", "corlean@safe-mail.net", "atlantic777@lugons.org", "a713n@gmx.com", "th3s1lentjudge@gmail.com", "basurainet@gmail.com", "jakeherman3@gmail.com", "sunyitncsclub@gmail.com", "roy.luongo@gmail.com", "ruchir.patwa90@gmail.com", "200irene@gmail.com", "quyetbh@yahoo.com", "Russel.VanTuyl@gmail.com", "blizzard8lack@gmail.com", "fire0088@gmail.com", "shinto143@gmail.com", "rui.joaquim@uni.lu", "amir.alipour.r@gmail.com", "dolbeau.baptiste@gmail.com", "kaikaikai1219@gmail.com"]	fluxfingers@ruhr-uni-bochum.de
\.


--
-- Name: massmail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('massmail_id_seq', 1, false);


--
-- Data for Name: news; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY news (id, "timestamp", message, published, challenge_id) FROM stdin;
1	2013-10-21 20:00:26	[Begin Mission Briefing]<br>\r\nHello everyone,<br />\r\n<br />\r\ngood to see that so many joined us in our fight for freedom. The robot forces are rising and threaten our Wiesn party. They already captured our main Wiesn party tent and they are about to overrun our breweries. To avoid more damage, we need you to protect the entrances to Oktoberfest, defend the breweries, and regain control of our main beer pump located in the main tent, so that we can continue to party and satisfy our thirst!<br>\r\n<br>\r\nWe gathered different challenges that you have to solve, to help us fight back the robot forces. Solving even a single one will help us on our way to take back the fairground from the robots. Feel free to find yourself a group of like-minded people and hack ALL the robots.<br />\r\n<br />\r\nNow, get ready, grab your keyboards, and rock!<br />\r\n[Mission Briefing Ended]<br /><br />\r\n\r\nWe will publish new annoucements and hints on this page. Meanwhile you can join our IRC channel <a href="irc://chat.freenode.net/fluxfingers">#fluxfingers</a> or visit our Twitter account <a href ="https://twitter.com/fluxfingers">fluxfingers</a> for critical information, if something is down.\r\n\r\nAlmost all challenges are available at start, but few challenges are delayed.	t	\N
2	2013-10-22 08:59:20	For Local Teams:\r\n\r\nPlease come to our desk to register as a local team. Local teams can win prices, but only after registration!	t	\N
3	2013-10-22 09:05:00	New Challenge Published:<br />\r\n<b>#14 For whom the bell tolls (Misc)</b><br />\r\n<br />\r\nHave fun with it!	t	16
4	2013-10-22 12:30:17	New Challenge partially online! Server is not set up yet.	t	18
5	2013-10-22 13:41:52	As Lieutenant Don Sim realized, his bots are under heavy load. So he just started lib6, ..., lib9 as additional load balancers.	t	20
6	2013-10-22 13:48:09	Version Controll has tricked us. Here is the latest version of pwd_check	t	3
7	2013-10-22 14:28:25	We experienced high load on our servers due to the use of scanners. Please DO NOT use them. If we catch you, we have to ban you!<br />	t	\N
8	2013-10-22 14:31:27	We managed to reestablish the connection to the Breznparadisebugmaschine! The service is now up.	t	18
9	2013-10-22 14:53:57	Ah, perhaps it helps you to know, that our Breznparadisebugmaschinefirmware is up to date with Windows 2012.	t	18
10	2013-10-22 15:45:54	New Challenge Published: The robots took our brewery! Will you help us to get it back?	t	23
11	2013-10-22 19:50:56	We fixed a tiny bug in BREW'r'Y, it's back now. No game changer, if you're on track you'll notice.	t	23
12	2013-10-22 21:05:19	OK everybody. You did a great job till now. Night is coming, stay awake and watch out for random robots appearing near you.	t	\N
13	2013-10-23 08:33:42	Guuuuuud morning everyone! Hope you had a save night and enjoyed some Weizenbier! Back to work now..	t	\N
14	2013-10-23 08:43:03	It seems that there are some problems with some Linux Distributions that lead to a wrong flag. The flag is printable and is written in leet-speak. We are working on a VM that works correctly with this challenge. When the VM is ready, you can download it and try again. Sorry for the inconvenience. 	t	15
15	2013-10-23 08:59:37	For all robo hunters out there: Your quest-description was updated - check it!	t	1
16	2013-10-23 09:18:41	New Hints appeard! <br />\r\nRoR has determined that the human agents acts as a proxy and requests meeting place, time and password for others. We think the first message he sends serves to agree on a session key for the answer.\r\nRoR analysts have also been staring at pcaps a lot lately. We think that on port 1832 (which we can only monitor passively) we are observing a key establishment that follows the simple ISO/IEC 11770-2 Mechanism 1. However, on tcp/1333 our analysts say that marshalled Ruby DateTime objects are flying by. Not sure, why anyone would do this, but given what we see on the other port, it makes sense (in a \r\ntwisted way).<br />\r\n<br />\r\nAdditionally we uploaded a .tar.bz file containing the session key and the IV. 	t	16
17	2013-10-23 09:38:10	Hint: He, we have the latest news for you. The first part of their strange key agreement was designed by the famous SHA-Robot ÐœÐ¸Ñ€!	t	1
18	2013-10-23 09:56:22	Ok I think we got it (thanks to Happy-H from Team ClevCode). Ubuntu introduced a patch to disallow ptracing of non-child processes by non-root users. This changes the calculated value. So when you use Ubuntu you should work as root. The other distributions should not be affected. \r\n\r\nAnyway, I created a VM where the executable works just fine: http://h4des.org/ELF.ova (User: elf:elf and root:root)	t	15
19	2013-10-23 11:29:37	Hint: It's neither Velato nor Fugue.	t	10
20	2013-10-23 12:36:55	New Challenge Published: We found a dead robot! Want to take a look at its internals?	t	17
21	2013-10-23 13:15:17	Added an additional URL for the channel without the reverse proxy, but also without ssl	t	6
22	2013-10-23 14:34:17	Think outside the box - being several types at once like an animal that can change its color. Excuse the inaccuracy, but that's what you're searching for.	t	17
23	2013-10-23 14:58:07	We just extended the CTF by a half hour because it started about half an hour later as well. So the CTF will end on 2013-10-24 08:30:00 UTC now.	t	\N
24	2013-10-23 16:42:01	Local staff is helplessly wandering around in Luxembourg in order to get food and beverages. See you later!	t	\N
25	2013-10-23 20:03:35	Okay you can stop struggling now: XSS is not the way; leave the http cookie alone; get RIP to do the final trick!	t	6
26	2013-10-23 20:07:01	The flag starts with 'Y4Y,'	t	10
27	2013-10-23 22:13:40	<b>Hint:</b> The challenge text gives hints about the protocol involved. We updated it in order to reflect that fact.	t	23
28	2013-10-24 08:13:09	Ruby Version 1.8.7	t	16
29	2013-10-24 08:30:26	Hey all, we hope you enjoyed the ctf!<br>\r\nThe ctf is over - please give us some feedback, so we can improve our next ctf. We would appreciate it, if you can send us a mail (fluxfingers (at) rub.de), answering the following (or a subset of) questions:<br>\r\n<br>\r\nWhich challenge(s) did you like most? Why?<br>\r\nWhich challenge(s) did you dislike? Why?<br>\r\nDo you think there were too many/few challenges?<br>\r\nDid you miss a certain challenge category (reversing/web/<s>stegano</s>/crypto/you-name-it)?<br>\r\nWere there enough challenges in each category or was a category imbalanced?<br>\r\nDid you like the scoreboard/theme?<br>\r\nAre you satisfied with the support?<br>\r\nWhat should we do better next time?<br>\r\n<br>	t	\N
\.


--
-- Name: news_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('news_id_seq', 1, false);


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY settings (id, submission_disabled, ctf_start_date, ctf_end_date, archive_mode) FROM stdin;
1	f	2013-10-22 08:00:00	2013-10-24 08:30:00	t
\.


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('settings_id_seq', 1, false);


--
-- Data for Name: submission; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY submission (team_id, challenge_id, "timestamp", bonus) FROM stdin;
2	2	2013-10-22 13:25:58	2
2	3	2013-10-23 04:55:16	0
2	4	2013-10-22 13:52:51	0
2	5	2013-10-22 20:11:14	0
2	7	2013-10-22 11:58:13	0
2	9	2013-10-23 22:10:21	0
2	10	2013-10-24 00:54:03	0
2	12	2013-10-22 17:11:49	0
2	13	2013-10-22 18:12:42	0
2	14	2013-10-22 21:59:45	0
2	17	2013-10-23 14:35:23	1
2	20	2013-10-23 20:31:17	0
2	21	2013-10-23 23:14:25	83
2	22	2013-10-22 09:03:36	0
6	4	2013-10-22 09:58:43	0
6	13	2013-10-23 01:45:42	0
6	15	2013-10-23 14:16:45	0
6	22	2013-10-22 08:45:08	2
7	4	2013-10-22 14:51:25	0
7	7	2013-10-23 15:19:49	0
7	17	2013-10-24 06:34:13	0
7	22	2013-10-22 23:28:17	0
8	4	2013-10-22 10:01:52	0
8	5	2013-10-24 06:10:54	0
8	7	2013-10-23 19:50:55	0
8	12	2013-10-22 15:03:01	0
8	13	2013-10-23 04:30:36	0
8	14	2013-10-23 13:30:04	0
8	15	2013-10-23 06:01:29	0
8	17	2013-10-23 18:32:41	0
8	20	2013-10-23 13:38:22	0
8	21	2013-10-24 08:48:05	65
8	22	2013-10-22 09:00:44	0
10	22	2013-10-23 06:51:11	0
11	22	2013-10-23 00:00:12	0
13	3	2013-10-22 19:12:56	1
13	4	2013-10-22 10:22:57	0
13	5	2013-10-22 22:53:23	0
13	7	2013-10-22 15:11:29	0
13	12	2013-10-22 23:06:02	0
13	13	2013-10-23 01:05:05	0
13	14	2013-10-23 12:54:26	0
13	15	2013-10-23 13:55:30	0
13	17	2013-10-23 14:15:35	2
13	21	2013-10-23 12:59:52	100
13	22	2013-10-22 10:10:26	0
14	4	2013-10-22 17:39:35	0
14	22	2013-10-22 16:15:08	0
15	22	2013-10-23 20:44:48	0
17	3	2013-10-24 03:47:07	0
17	4	2013-10-22 14:30:21	0
17	7	2013-10-24 01:50:24	0
17	10	2013-10-24 06:23:28	0
17	12	2013-10-22 18:21:50	0
17	13	2013-10-22 13:10:10	0
17	14	2013-10-22 19:59:50	0
17	15	2013-10-23 05:00:29	0
17	17	2013-10-23 19:38:56	0
17	21	2013-10-24 09:00:59	55
17	22	2013-10-22 09:18:44	0
18	4	2013-10-22 11:20:35	0
18	7	2013-10-23 10:24:33	0
18	13	2013-10-22 16:05:44	0
18	14	2013-10-24 08:07:11	0
18	15	2013-10-23 11:04:14	0
18	17	2013-10-23 21:34:42	0
18	22	2013-10-22 09:10:21	0
19	4	2013-10-23 17:00:22	0
19	21	2013-10-24 08:56:57	88
19	22	2013-10-22 17:43:24	0
21	13	2013-10-22 18:49:39	0
21	22	2013-10-22 10:47:00	0
22	4	2013-10-22 13:17:29	0
22	17	2013-10-23 21:14:57	0
22	22	2013-10-22 14:14:29	0
23	4	2013-10-23 13:28:13	0
23	12	2013-10-22 12:31:44	0
23	13	2013-10-23 11:12:58	0
23	14	2013-10-23 11:17:23	0
23	15	2013-10-23 16:16:56	0
23	22	2013-10-22 13:20:24	0
24	4	2013-10-22 22:00:25	0
24	7	2013-10-22 23:31:39	0
24	13	2013-10-23 16:18:44	0
24	17	2013-10-23 23:52:53	0
24	22	2013-10-22 22:23:30	0
31	4	2013-10-22 11:39:20	0
31	5	2013-10-24 06:06:10	0
31	7	2013-10-22 10:42:37	0
31	13	2013-10-22 15:41:14	0
31	14	2013-10-22 22:13:41	0
31	15	2013-10-24 06:04:46	0
31	17	2013-10-24 06:15:05	0
31	20	2013-10-23 07:03:52	1
31	22	2013-10-22 08:49:52	0
32	4	2013-10-22 21:34:49	0
32	7	2013-10-23 21:25:04	0
32	12	2013-10-23 16:02:41	0
32	13	2013-10-22 12:55:25	0
32	14	2013-10-22 21:42:33	0
32	17	2013-10-24 07:30:31	0
32	22	2013-10-22 16:41:12	0
33	1	2013-10-23 10:10:11	3
33	3	2013-10-22 19:31:08	0
33	4	2013-10-22 11:31:21	0
33	5	2013-10-22 22:27:39	0
33	6	2013-10-23 00:08:49	3
33	7	2013-10-22 16:02:07	0
33	10	2013-10-23 22:21:15	0
33	12	2013-10-22 21:53:49	0
33	13	2013-10-22 10:57:49	3
33	14	2013-10-22 13:08:20	2
33	15	2013-10-23 14:51:24	0
33	17	2013-10-23 13:23:01	3
33	20	2013-10-23 13:05:54	0
33	22	2013-10-22 08:47:58	1
33	23	2013-10-24 00:53:09	3
36	22	2013-10-22 21:57:19	0
37	4	2013-10-22 11:18:28	0
37	7	2013-10-22 10:01:51	0
37	9	2013-10-23 16:27:08	0
37	12	2013-10-23 20:18:34	0
37	17	2013-10-23 17:27:54	0
37	22	2013-10-22 18:47:25	0
39	4	2013-10-22 13:10:04	0
39	7	2013-10-22 11:03:52	0
39	13	2013-10-22 14:44:51	0
39	14	2013-10-22 22:21:09	0
39	15	2013-10-23 11:22:25	0
39	17	2013-10-23 19:59:48	0
39	20	2013-10-24 04:53:06	0
39	21	2013-10-23 13:00:29	83
39	22	2013-10-22 09:56:31	0
40	4	2013-10-23 11:06:50	0
40	5	2013-10-22 22:25:40	0
40	7	2013-10-22 16:14:19	0
40	10	2013-10-24 07:21:20	0
40	12	2013-10-23 14:35:24	0
40	13	2013-10-23 14:25:19	0
40	14	2013-10-23 18:25:21	0
40	15	2013-10-23 06:36:42	0
40	17	2013-10-23 20:45:53	0
40	20	2013-10-23 21:48:40	0
40	22	2013-10-22 09:42:22	0
42	1	2013-10-23 10:31:30	2
42	2	2013-10-22 11:13:12	3
42	3	2013-10-23 19:52:30	0
42	4	2013-10-22 11:58:34	0
42	12	2013-10-22 15:27:36	0
42	13	2013-10-23 10:47:34	0
42	14	2013-10-23 20:01:12	0
42	15	2013-10-23 19:30:22	0
42	17	2013-10-24 07:47:16	0
42	22	2013-10-22 13:17:05	0
45	1	2013-10-24 00:48:50	0
45	2	2013-10-24 02:47:02	1
45	3	2013-10-22 18:08:56	2
45	4	2013-10-22 11:49:58	0
45	5	2013-10-22 13:34:03	3
45	6	2013-10-23 22:54:07	1
45	7	2013-10-22 13:40:35	0
45	10	2013-10-23 19:11:53	1
45	12	2013-10-22 16:18:27	0
45	13	2013-10-22 13:08:12	0
45	14	2013-10-22 12:02:30	3
45	15	2013-10-23 10:09:53	0
45	17	2013-10-23 15:22:58	0
45	20	2013-10-22 18:18:11	3
45	21	2013-10-24 09:14:56	84
45	22	2013-10-22 11:17:51	0
48	4	2013-10-23 10:23:07	0
50	22	2013-10-23 07:54:48	0
51	4	2013-10-22 11:11:54	0
51	7	2013-10-22 19:06:31	0
51	13	2013-10-23 15:38:33	0
51	17	2013-10-24 07:18:21	0
51	22	2013-10-22 16:24:02	0
53	3	2013-10-24 08:02:47	0
53	4	2013-10-22 09:32:23	0
53	7	2013-10-22 11:01:10	0
53	12	2013-10-23 13:19:13	0
53	13	2013-10-22 13:44:10	0
53	14	2013-10-22 14:14:50	0
53	15	2013-10-23 10:30:50	0
53	17	2013-10-23 16:16:53	0
53	22	2013-10-22 08:50:58	0
54	4	2013-10-22 20:12:41	0
54	13	2013-10-23 12:45:12	0
54	22	2013-10-23 11:11:39	0
55	4	2013-10-22 21:54:06	0
55	6	2013-10-24 03:19:01	0
55	7	2013-10-22 23:31:39	0
55	10	2013-10-24 08:29:58	0
55	12	2013-10-23 01:10:13	0
55	13	2013-10-23 02:54:34	0
55	14	2013-10-24 06:12:35	0
55	15	2013-10-23 21:13:53	0
55	17	2013-10-23 22:41:40	0
55	20	2013-10-23 20:37:57	0
55	21	2013-10-24 09:16:37	75
55	22	2013-10-22 18:23:24	0
56	4	2013-10-22 15:47:00	0
56	7	2013-10-22 14:09:04	0
56	13	2013-10-22 19:21:47	0
56	15	2013-10-23 12:00:57	0
56	22	2013-10-22 09:06:36	0
57	4	2013-10-23 12:38:19	0
57	12	2013-10-22 15:22:15	0
57	13	2013-10-22 12:20:24	0
57	14	2013-10-22 16:32:56	0
57	15	2013-10-23 08:55:03	0
57	17	2013-10-23 15:37:38	0
57	20	2013-10-23 15:43:10	0
57	22	2013-10-22 09:04:25	0
59	4	2013-10-22 10:46:01	0
59	7	2013-10-23 09:15:51	0
59	13	2013-10-23 08:27:11	0
59	22	2013-10-22 15:41:56	0
61	22	2013-10-22 13:10:08	0
62	4	2013-10-22 18:54:25	0
62	7	2013-10-23 20:29:44	0
62	22	2013-10-22 21:32:51	0
63	3	2013-10-23 21:45:35	0
63	4	2013-10-22 11:49:37	0
63	5	2013-10-23 09:31:23	0
63	6	2013-10-23 22:58:54	0
63	7	2013-10-22 10:35:05	0
63	12	2013-10-22 23:19:31	0
63	13	2013-10-22 14:04:40	0
63	14	2013-10-22 16:32:36	0
63	15	2013-10-22 20:08:25	0
63	17	2013-10-23 15:28:03	0
63	20	2013-10-23 09:59:34	0
63	21	2013-10-24 09:12:10	79
63	22	2013-10-22 10:03:40	0
64	4	2013-10-22 12:52:17	0
64	5	2013-10-22 18:55:44	0
64	7	2013-10-22 15:19:55	0
64	12	2013-10-23 21:29:35	0
64	17	2013-10-24 02:33:47	0
64	20	2013-10-23 21:27:22	0
64	21	2013-10-23 14:03:43	97
64	22	2013-10-22 18:01:38	0
70	4	2013-10-22 19:45:54	0
70	7	2013-10-22 21:52:36	0
70	21	2013-10-23 22:46:37	93
73	4	2013-10-23 14:54:43	0
73	22	2013-10-22 11:49:47	0
74	22	2013-10-23 08:50:29	0
75	4	2013-10-24 03:10:20	0
75	7	2013-10-23 13:30:13	0
75	22	2013-10-22 18:40:04	0
77	4	2013-10-22 15:06:28	0
77	22	2013-10-22 09:29:42	0
78	4	2013-10-22 17:52:02	0
78	6	2013-10-24 07:05:21	0
78	7	2013-10-23 19:43:09	0
78	12	2013-10-22 17:26:12	0
78	13	2013-10-22 12:03:37	0
78	14	2013-10-22 13:08:34	1
78	15	2013-10-22 16:41:08	0
78	17	2013-10-23 17:44:52	0
78	22	2013-10-22 09:00:05	0
80	4	2013-10-22 11:17:35	0
80	7	2013-10-24 02:41:50	0
80	13	2013-10-22 16:06:42	0
80	14	2013-10-23 14:24:08	0
80	17	2013-10-23 17:38:39	0
80	22	2013-10-22 11:49:53	0
81	4	2013-10-23 02:56:23	0
81	22	2013-10-23 04:37:26	0
82	12	2013-10-24 05:14:28	0
82	13	2013-10-23 04:00:31	0
82	14	2013-10-23 23:55:17	0
82	15	2013-10-22 18:39:47	0
82	22	2013-10-22 09:44:43	0
84	1	2013-10-23 12:50:53	1
84	3	2013-10-22 17:29:55	3
84	4	2013-10-22 10:39:15	0
84	7	2013-10-22 11:19:06	0
84	12	2013-10-22 21:03:43	0
84	13	2013-10-22 14:04:46	0
84	14	2013-10-23 01:29:56	0
84	15	2013-10-23 14:12:36	0
84	17	2013-10-23 20:05:47	0
84	20	2013-10-23 16:40:45	0
84	21	2013-10-23 23:35:38	69
84	22	2013-10-22 11:03:05	0
85	4	2013-10-22 15:09:37	0
85	7	2013-10-23 04:50:43	0
85	12	2013-10-23 22:44:02	0
85	13	2013-10-23 11:39:38	0
85	17	2013-10-24 02:15:14	0
85	22	2013-10-22 13:00:37	0
87	4	2013-10-22 12:04:46	0
87	5	2013-10-24 00:27:24	0
87	7	2013-10-22 10:43:21	0
87	10	2013-10-23 13:50:52	3
87	12	2013-10-23 11:44:34	0
87	13	2013-10-22 15:18:43	0
87	14	2013-10-24 03:29:20	0
87	15	2013-10-22 21:01:22	0
87	17	2013-10-23 20:51:32	0
87	20	2013-10-23 19:31:14	0
87	21	2013-10-23 13:00:46	48
87	22	2013-10-22 12:54:27	0
88	4	2013-10-23 00:17:57	0
88	13	2013-10-23 15:42:52	0
88	21	2013-10-24 09:07:18	82
89	4	2013-10-22 10:41:33	0
89	7	2013-10-22 14:16:45	0
90	4	2013-10-23 22:23:29	0
90	22	2013-10-23 22:51:20	0
92	22	2013-10-23 09:09:26	0
93	4	2013-10-23 21:52:13	0
93	17	2013-10-24 01:28:53	0
93	22	2013-10-22 17:02:01	0
94	4	2013-10-22 15:13:23	0
94	7	2013-10-22 22:49:25	0
94	12	2013-10-23 22:41:23	0
94	13	2013-10-23 21:16:00	0
94	17	2013-10-24 02:07:50	0
94	22	2013-10-22 23:44:43	0
97	22	2013-10-23 19:01:38	0
98	21	2013-10-24 09:22:32	99
98	22	2013-10-24 02:33:30	0
99	5	2013-10-22 19:48:53	0
99	13	2013-10-24 03:32:56	0
99	22	2013-10-22 10:50:37	0
101	4	2013-10-22 21:52:04	0
101	7	2013-10-23 01:00:22	0
101	12	2013-10-22 20:39:26	0
101	13	2013-10-22 18:54:28	0
101	14	2013-10-23 05:26:02	0
101	15	2013-10-23 04:22:11	0
101	22	2013-10-22 15:26:08	0
103	12	2013-10-23 09:05:55	0
103	13	2013-10-23 09:17:43	0
103	14	2013-10-23 14:57:07	0
103	15	2013-10-23 10:24:14	0
103	22	2013-10-22 13:03:42	0
104	4	2013-10-22 10:48:02	0
104	7	2013-10-22 15:29:19	0
104	12	2013-10-23 03:47:43	0
104	13	2013-10-23 00:18:52	0
104	14	2013-10-23 18:32:58	0
104	15	2013-10-22 13:52:29	3
104	17	2013-10-23 15:52:55	0
104	20	2013-10-23 13:51:22	0
104	22	2013-10-22 09:09:26	0
107	4	2013-10-22 16:11:38	0
107	7	2013-10-22 13:21:21	0
107	12	2013-10-22 21:10:20	0
107	22	2013-10-22 21:54:37	0
110	4	2013-10-23 22:24:30	0
110	22	2013-10-22 16:13:51	0
112	4	2013-10-22 22:41:49	0
112	17	2013-10-24 01:46:42	0
112	22	2013-10-22 21:44:20	0
113	22	2013-10-22 10:15:38	0
114	22	2013-10-23 09:01:23	0
115	4	2013-10-23 06:44:54	0
115	12	2013-10-22 15:14:19	0
115	22	2013-10-22 08:59:26	0
116	22	2013-10-22 10:23:16	0
117	4	2013-10-23 08:11:46	0
117	17	2013-10-24 07:28:19	0
117	22	2013-10-22 18:17:06	0
118	22	2013-10-22 19:20:58	0
119	4	2013-10-22 12:37:49	0
119	5	2013-10-24 02:03:36	0
119	7	2013-10-22 21:10:13	0
119	13	2013-10-22 22:51:43	0
119	21	2013-10-24 08:45:25	78
119	22	2013-10-22 18:58:02	0
121	4	2013-10-23 14:30:14	0
121	13	2013-10-23 20:14:48	0
121	17	2013-10-23 22:58:00	0
121	20	2013-10-23 20:39:31	0
121	22	2013-10-23 16:56:32	0
122	4	2013-10-23 13:34:25	0
122	22	2013-10-23 20:31:30	0
123	4	2013-10-22 15:41:24	0
123	7	2013-10-23 20:30:29	0
123	22	2013-10-22 11:48:42	0
124	3	2013-10-24 07:40:01	0
124	4	2013-10-22 10:10:27	0
124	5	2013-10-23 14:18:24	0
124	6	2013-10-24 06:34:43	0
124	7	2013-10-22 09:00:50	3
124	12	2013-10-23 03:45:13	0
124	13	2013-10-23 00:41:32	0
124	14	2013-10-23 09:02:38	0
124	15	2013-10-23 05:33:38	0
124	17	2013-10-23 16:00:36	0
124	20	2013-10-23 20:12:45	0
124	22	2013-10-22 09:19:32	0
128	4	2013-10-24 02:37:39	0
128	22	2013-10-22 18:53:34	0
129	22	2013-10-23 23:22:19	0
131	4	2013-10-23 14:21:49	0
131	5	2013-10-23 17:05:21	0
131	7	2013-10-22 17:54:41	0
131	17	2013-10-23 15:04:28	0
131	22	2013-10-23 14:57:18	0
134	4	2013-10-22 10:43:16	0
134	7	2013-10-23 07:37:52	0
134	22	2013-10-22 11:53:38	0
135	21	2013-10-23 23:48:43	98
136	4	2013-10-22 17:52:48	0
136	22	2013-10-22 19:53:26	0
138	4	2013-10-22 22:11:41	0
138	15	2013-10-23 13:17:03	0
138	22	2013-10-23 14:10:26	0
141	4	2013-10-22 11:47:38	0
141	5	2013-10-22 17:40:25	1
141	7	2013-10-23 01:20:38	0
141	12	2013-10-22 14:29:01	0
141	13	2013-10-22 13:17:54	0
141	14	2013-10-23 10:06:09	0
141	15	2013-10-23 08:56:08	0
141	17	2013-10-23 14:38:03	0
141	22	2013-10-22 10:30:42	0
143	4	2013-10-23 04:42:27	0
143	22	2013-10-22 17:51:33	0
145	4	2013-10-22 17:40:48	0
146	12	2013-10-23 16:26:08	0
146	13	2013-10-23 16:23:26	0
146	22	2013-10-23 04:31:15	0
147	22	2013-10-23 10:27:47	0
148	4	2013-10-22 14:27:21	0
148	12	2013-10-23 01:54:13	0
148	13	2013-10-22 21:00:42	0
148	14	2013-10-22 23:26:45	0
148	22	2013-10-22 15:04:29	0
150	4	2013-10-22 21:24:00	0
150	7	2013-10-23 20:15:55	0
150	12	2013-10-23 02:13:07	0
150	13	2013-10-24 02:44:14	0
150	21	2013-10-24 08:52:29	78
150	22	2013-10-22 20:32:56	0
151	22	2013-10-23 08:11:42	0
152	22	2013-10-24 06:45:45	0
153	3	2013-10-24 00:54:14	0
153	4	2013-10-22 18:39:04	0
153	5	2013-10-24 01:33:12	0
153	7	2013-10-23 23:29:47	0
153	12	2013-10-22 11:32:30	0
153	13	2013-10-23 01:14:01	0
153	15	2013-10-24 07:25:10	0
153	17	2013-10-23 22:38:12	0
153	21	2013-10-24 08:42:31	68
153	22	2013-10-22 16:56:43	0
154	4	2013-10-23 13:53:18	0
155	22	2013-10-22 19:37:04	0
158	4	2013-10-22 14:31:13	0
159	22	2013-10-22 14:19:14	0
161	4	2013-10-22 14:29:00	0
161	17	2013-10-23 17:13:06	0
161	22	2013-10-22 12:32:48	0
164	4	2013-10-22 13:50:12	0
164	7	2013-10-22 16:08:25	0
164	12	2013-10-23 07:12:06	0
164	13	2013-10-23 10:50:17	0
164	14	2013-10-24 08:13:00	0
164	17	2013-10-24 05:10:37	0
164	22	2013-10-22 11:38:50	0
166	22	2013-10-23 11:35:24	0
169	4	2013-10-22 20:23:21	0
169	7	2013-10-22 19:09:20	0
169	15	2013-10-24 05:41:33	0
169	22	2013-10-22 14:40:22	0
171	4	2013-10-22 09:26:56	3
171	5	2013-10-23 11:56:52	0
171	7	2013-10-23 09:55:45	0
171	17	2013-10-23 21:51:14	0
171	21	2013-10-23 23:28:35	66
171	22	2013-10-23 14:03:57	0
172	4	2013-10-22 17:01:49	0
172	22	2013-10-22 16:48:33	0
174	4	2013-10-23 17:18:21	0
176	22	2013-10-22 14:28:23	0
177	22	2013-10-23 03:25:11	0
179	4	2013-10-22 16:13:20	0
179	7	2013-10-23 20:38:40	0
179	13	2013-10-23 21:53:00	0
179	22	2013-10-22 10:12:37	0
180	3	2013-10-23 19:26:10	0
180	4	2013-10-22 09:43:31	0
180	5	2013-10-22 22:52:00	0
180	6	2013-10-24 03:36:55	0
180	7	2013-10-22 09:12:51	1
180	9	2013-10-23 21:48:54	0
180	10	2013-10-24 03:40:39	0
180	12	2013-10-22 10:56:50	1
180	13	2013-10-22 12:02:35	1
180	14	2013-10-22 18:03:23	0
180	15	2013-10-22 23:25:21	0
180	17	2013-10-23 17:50:59	0
180	18	2013-10-23 12:38:22	3
180	20	2013-10-24 07:43:51	0
180	21	2013-10-24 00:03:39	82
180	22	2013-10-22 08:49:52	0
184	4	2013-10-22 17:32:42	0
184	7	2013-10-23 04:05:02	0
184	22	2013-10-22 12:57:27	0
187	4	2013-10-22 12:01:05	0
189	4	2013-10-22 18:37:02	0
189	7	2013-10-23 19:59:25	0
189	12	2013-10-23 13:59:31	0
189	13	2013-10-23 12:57:05	0
189	17	2013-10-23 18:48:19	0
189	22	2013-10-23 05:02:01	0
191	4	2013-10-22 12:42:44	0
191	7	2013-10-24 01:04:03	0
191	13	2013-10-23 07:02:56	0
191	14	2013-10-23 06:12:56	0
191	22	2013-10-22 14:38:07	0
192	4	2013-10-22 19:02:04	0
192	5	2013-10-23 08:20:51	0
192	7	2013-10-22 20:16:21	0
192	13	2013-10-23 00:22:47	0
192	14	2013-10-23 18:45:58	0
192	15	2013-10-24 08:15:35	0
192	17	2013-10-23 18:11:59	0
192	22	2013-10-22 15:29:05	0
197	22	2013-10-23 07:50:09	0
198	22	2013-10-23 07:55:50	0
200	4	2013-10-22 19:23:42	0
200	7	2013-10-23 22:00:01	0
200	22	2013-10-23 21:25:25	0
205	4	2013-10-23 16:41:33	0
205	17	2013-10-24 04:09:24	0
205	21	2013-10-24 09:05:03	91
211	4	2013-10-22 11:42:20	0
211	7	2013-10-22 13:23:23	0
211	12	2013-10-22 18:28:45	0
211	13	2013-10-22 17:17:57	0
211	17	2013-10-23 21:30:57	0
211	22	2013-10-23 12:22:25	0
224	4	2013-10-22 12:11:14	0
224	7	2013-10-24 05:16:36	0
224	12	2013-10-23 06:20:01	0
224	13	2013-10-23 04:16:30	0
224	14	2013-10-24 03:52:33	0
224	15	2013-10-22 22:09:09	0
224	17	2013-10-23 20:57:58	0
224	22	2013-10-22 10:42:39	0
225	4	2013-10-22 11:52:29	0
225	7	2013-10-22 10:52:27	0
225	20	2013-10-22 20:33:26	2
230	4	2013-10-22 22:21:55	0
230	7	2013-10-22 21:22:32	0
231	22	2013-10-23 05:34:12	0
232	4	2013-10-22 14:03:38	0
232	7	2013-10-23 14:27:22	0
232	15	2013-10-23 18:00:23	0
232	20	2013-10-24 08:29:23	0
232	22	2013-10-22 17:13:02	0
233	4	2013-10-22 10:15:32	0
233	7	2013-10-23 15:14:48	0
233	12	2013-10-23 18:07:13	0
233	13	2013-10-22 18:03:17	0
233	14	2013-10-23 19:10:01	0
233	15	2013-10-23 13:48:29	0
233	17	2013-10-23 20:08:13	0
233	21	2013-10-23 22:43:14	89
233	22	2013-10-22 11:20:41	0
234	4	2013-10-22 21:48:03	0
235	4	2013-10-22 18:17:09	0
235	13	2013-10-24 04:55:09	0
235	17	2013-10-23 22:08:12	0
235	22	2013-10-22 14:14:24	0
237	22	2013-10-23 21:32:36	0
238	4	2013-10-22 11:24:08	0
238	7	2013-10-22 11:24:30	0
238	9	2013-10-23 18:19:29	0
238	12	2013-10-23 22:58:23	0
238	13	2013-10-22 23:53:04	0
238	14	2013-10-23 23:04:48	0
238	15	2013-10-23 20:51:40	0
238	17	2013-10-24 07:00:20	0
238	22	2013-10-22 10:36:56	0
242	22	2013-10-22 09:13:30	0
246	4	2013-10-22 15:05:09	0
246	5	2013-10-23 20:03:57	0
246	22	2013-10-22 12:30:13	0
251	4	2013-10-22 18:32:15	0
252	4	2013-10-22 10:29:43	0
252	7	2013-10-22 09:24:46	0
252	22	2013-10-22 08:48:38	0
257	4	2013-10-22 23:45:09	0
257	22	2013-10-22 23:05:15	0
260	4	2013-10-23 01:04:58	0
260	7	2013-10-23 21:16:34	0
260	22	2013-10-22 23:03:57	0
262	4	2013-10-22 16:11:18	0
263	22	2013-10-23 00:18:07	0
265	4	2013-10-22 19:38:35	0
265	13	2013-10-22 18:15:30	0
265	15	2013-10-22 23:44:40	0
265	22	2013-10-22 09:24:59	0
266	4	2013-10-22 11:57:30	0
266	7	2013-10-22 20:02:37	0
266	12	2013-10-22 10:36:02	2
266	13	2013-10-23 15:44:09	0
266	22	2013-10-22 09:44:40	0
269	22	2013-10-23 02:45:37	0
270	1	2013-10-24 04:52:41	0
270	3	2013-10-23 02:46:36	0
270	4	2013-10-22 18:42:24	0
270	5	2013-10-23 00:24:14	0
270	7	2013-10-23 00:24:47	0
270	12	2013-10-23 03:39:24	0
270	13	2013-10-23 04:26:55	0
270	14	2013-10-24 02:18:45	0
270	17	2013-10-23 20:47:26	0
270	22	2013-10-22 20:00:09	0
272	4	2013-10-23 11:11:03	0
272	5	2013-10-23 19:00:17	0
272	13	2013-10-22 18:43:58	0
272	15	2013-10-22 16:22:49	1
272	22	2013-10-22 09:00:19	0
273	22	2013-10-22 08:49:11	0
275	4	2013-10-23 06:19:28	0
275	12	2013-10-24 04:36:31	0
275	13	2013-10-23 06:55:09	0
275	15	2013-10-23 09:42:50	0
275	17	2013-10-24 03:50:38	0
275	22	2013-10-22 08:55:10	0
276	22	2013-10-23 08:34:51	0
277	22	2013-10-22 19:48:23	0
278	4	2013-10-23 15:24:47	0
278	13	2013-10-23 17:22:18	0
278	17	2013-10-24 04:57:49	0
278	22	2013-10-22 09:01:37	0
279	4	2013-10-23 09:52:21	0
279	17	2013-10-24 08:15:10	0
279	22	2013-10-23 05:10:32	0
280	22	2013-10-23 10:28:59	0
283	4	2013-10-22 15:27:36	0
283	22	2013-10-22 14:25:53	0
284	4	2013-10-22 14:24:36	0
284	7	2013-10-22 22:04:44	0
287	4	2013-10-22 10:30:19	0
287	7	2013-10-22 09:07:07	2
287	12	2013-10-22 13:24:10	0
287	13	2013-10-23 05:56:23	0
287	14	2013-10-23 06:27:40	0
287	17	2013-10-23 16:35:49	0
287	20	2013-10-24 04:42:38	0
287	22	2013-10-22 09:44:56	0
289	3	2013-10-22 19:42:54	0
289	4	2013-10-22 19:48:35	0
289	5	2013-10-22 22:17:34	0
289	6	2013-10-23 23:39:00	0
289	7	2013-10-22 09:55:56	0
289	12	2013-10-22 09:39:13	3
289	13	2013-10-22 17:34:45	0
289	14	2013-10-23 13:33:10	0
289	15	2013-10-22 14:39:04	2
289	17	2013-10-23 14:50:08	0
289	18	2013-10-24 02:49:50	2
289	20	2013-10-23 22:34:02	0
289	21	2013-10-23 23:08:00	92
289	22	2013-10-22 10:45:37	0
296	4	2013-10-22 21:47:46	0
297	4	2013-10-22 12:43:17	0
297	5	2013-10-23 14:56:16	0
297	7	2013-10-22 22:32:12	0
297	9	2013-10-23 14:34:25	1
297	12	2013-10-23 09:32:08	0
297	13	2013-10-22 12:55:56	0
297	14	2013-10-22 16:33:25	0
297	15	2013-10-22 23:20:51	0
297	22	2013-10-22 08:38:46	3
299	4	2013-10-22 22:37:43	0
300	4	2013-10-22 13:26:04	0
300	5	2013-10-22 17:23:35	2
300	12	2013-10-22 16:25:40	0
300	13	2013-10-23 16:03:36	0
300	15	2013-10-23 13:44:22	0
300	21	2013-10-23 22:58:33	91
300	22	2013-10-22 13:46:21	0
301	4	2013-10-22 16:30:25	0
301	22	2013-10-22 10:13:48	0
305	4	2013-10-23 05:44:55	0
305	13	2013-10-22 20:39:05	0
305	15	2013-10-23 13:11:44	0
305	22	2013-10-22 16:34:33	0
306	4	2013-10-22 11:14:32	0
306	7	2013-10-23 14:39:44	0
306	22	2013-10-22 12:39:17	0
308	22	2013-10-22 21:10:02	0
310	22	2013-10-22 16:11:18	0
314	13	2013-10-23 14:22:52	0
314	22	2013-10-22 08:58:03	0
315	4	2013-10-23 01:40:55	0
315	7	2013-10-22 13:28:36	0
316	4	2013-10-22 09:49:22	0
316	7	2013-10-23 10:10:35	0
316	9	2013-10-23 15:17:07	0
316	10	2013-10-23 18:45:56	2
316	13	2013-10-24 01:47:58	0
316	22	2013-10-23 14:27:57	0
317	13	2013-10-24 06:34:56	0
317	22	2013-10-22 13:03:21	0
319	4	2013-10-22 15:05:07	0
319	17	2013-10-23 17:05:17	0
319	22	2013-10-22 11:41:14	0
321	4	2013-10-22 13:32:24	0
321	22	2013-10-22 15:50:31	0
324	4	2013-10-22 12:01:25	0
324	7	2013-10-22 17:24:36	0
324	22	2013-10-22 13:59:15	0
326	4	2013-10-23 02:16:15	0
327	22	2013-10-22 09:26:30	0
334	4	2013-10-22 13:40:06	0
334	5	2013-10-23 19:36:16	0
334	7	2013-10-24 08:13:31	0
334	12	2013-10-23 00:51:47	0
334	15	2013-10-24 00:45:00	0
334	17	2013-10-23 15:58:19	0
334	22	2013-10-22 17:33:16	0
335	22	2013-10-22 17:48:04	0
336	4	2013-10-22 16:18:06	0
336	7	2013-10-22 18:03:29	0
336	13	2013-10-24 05:22:28	0
336	15	2013-10-24 04:56:15	0
336	22	2013-10-22 11:17:56	0
341	4	2013-10-23 13:20:58	0
341	22	2013-10-22 18:10:47	0
342	4	2013-10-22 18:53:09	0
342	21	2013-10-23 13:02:57	83
342	22	2013-10-23 15:40:31	0
343	4	2013-10-24 04:20:23	0
343	13	2013-10-22 22:17:44	0
343	14	2013-10-23 14:43:59	0
343	22	2013-10-24 03:28:50	0
344	22	2013-10-22 17:54:13	0
347	4	2013-10-22 10:07:34	0
347	7	2013-10-22 10:34:14	0
348	3	2013-10-23 21:03:43	0
348	4	2013-10-22 18:52:55	0
348	7	2013-10-22 16:27:01	0
348	13	2013-10-23 00:59:53	0
348	17	2013-10-23 19:49:35	0
348	22	2013-10-22 11:06:11	0
352	4	2013-10-23 06:06:32	0
352	13	2013-10-24 02:27:02	0
352	22	2013-10-22 09:01:23	0
359	22	2013-10-22 11:58:27	0
365	13	2013-10-23 17:05:07	0
365	14	2013-10-23 23:47:49	0
365	22	2013-10-23 03:23:35	0
370	4	2013-10-23 10:34:01	0
370	22	2013-10-23 02:40:49	0
371	4	2013-10-23 11:52:08	0
371	13	2013-10-22 20:07:17	0
371	14	2013-10-23 21:44:31	0
371	22	2013-10-22 12:17:22	0
372	4	2013-10-22 14:49:05	0
372	22	2013-10-22 13:29:40	0
373	4	2013-10-22 11:33:42	0
373	7	2013-10-22 22:03:42	0
373	22	2013-10-22 09:33:21	0
374	22	2013-10-23 05:44:24	0
375	4	2013-10-22 21:27:26	0
375	7	2013-10-24 01:48:42	0
375	22	2013-10-23 02:25:54	0
377	4	2013-10-22 19:28:37	0
377	13	2013-10-23 12:53:45	0
377	22	2013-10-22 20:26:34	0
378	3	2013-10-23 21:19:14	0
378	4	2013-10-22 09:27:49	2
378	5	2013-10-23 15:05:09	0
378	6	2013-10-23 20:46:58	2
378	7	2013-10-22 19:12:56	0
378	9	2013-10-23 07:50:01	3
378	10	2013-10-24 01:40:02	0
378	12	2013-10-22 16:16:01	0
378	13	2013-10-22 18:48:11	0
378	14	2013-10-23 04:21:09	0
378	15	2013-10-22 21:19:56	0
378	17	2013-10-23 15:06:52	0
378	20	2013-10-24 07:13:48	0
378	21	2013-10-23 13:01:08	86
378	22	2013-10-22 09:30:00	0
382	4	2013-10-23 02:10:38	0
382	7	2013-10-24 00:18:20	0
382	22	2013-10-23 16:45:30	0
383	22	2013-10-23 09:12:54	0
388	4	2013-10-22 10:32:55	0
388	12	2013-10-23 04:52:26	0
388	13	2013-10-22 15:14:01	0
388	14	2013-10-23 17:21:34	0
388	15	2013-10-24 05:04:14	0
388	17	2013-10-23 21:13:44	0
388	20	2013-10-24 06:53:16	0
388	22	2013-10-22 09:24:41	0
394	4	2013-10-23 16:35:05	0
396	22	2013-10-22 09:33:22	0
403	22	2013-10-23 15:29:31	0
406	4	2013-10-22 17:29:31	0
406	22	2013-10-22 14:38:53	0
410	4	2013-10-23 00:11:01	0
410	17	2013-10-23 19:40:46	0
410	22	2013-10-22 18:34:26	0
412	4	2013-10-22 18:57:22	0
412	7	2013-10-22 11:01:27	0
412	12	2013-10-23 06:17:28	0
412	13	2013-10-23 05:12:01	0
412	14	2013-10-24 06:05:59	0
412	17	2013-10-24 08:21:23	0
412	20	2013-10-23 10:17:52	0
412	22	2013-10-22 09:20:03	0
414	4	2013-10-22 21:29:29	0
414	7	2013-10-24 06:55:54	0
414	13	2013-10-23 08:16:37	0
414	22	2013-10-23 08:22:51	0
415	4	2013-10-22 19:23:35	0
415	7	2013-10-22 13:36:33	0
415	21	2013-10-23 23:04:42	66
415	22	2013-10-22 11:12:42	0
416	4	2013-10-22 09:32:04	1
416	5	2013-10-23 11:49:04	0
416	7	2013-10-22 21:31:06	0
416	9	2013-10-23 14:27:19	2
416	17	2013-10-23 23:28:13	0
416	22	2013-10-22 19:45:03	0
417	4	2013-10-22 17:31:52	0
417	7	2013-10-23 13:31:36	0
417	22	2013-10-22 11:44:15	0
419	22	2013-10-23 14:25:18	0
420	4	2013-10-22 12:49:15	0
420	7	2013-10-22 17:23:32	0
420	12	2013-10-23 13:59:28	0
420	13	2013-10-22 11:01:59	2
420	14	2013-10-22 14:36:16	0
420	15	2013-10-23 22:52:26	0
420	17	2013-10-23 19:22:42	0
420	22	2013-10-22 13:12:20	0
423	22	2013-10-23 15:47:22	0
425	4	2013-10-23 10:49:50	0
425	12	2013-10-23 04:46:03	0
432	22	2013-10-22 09:27:24	0
442	4	2013-10-23 08:34:23	0
443	4	2013-10-22 14:12:31	0
455	4	2013-10-22 16:43:45	0
455	22	2013-10-22 10:08:04	0
458	22	2013-10-22 13:41:40	0
459	4	2013-10-23 16:09:24	0
459	22	2013-10-22 14:17:10	0
464	4	2013-10-23 03:36:17	0
464	22	2013-10-22 14:43:33	0
465	4	2013-10-22 10:21:02	0
465	7	2013-10-22 20:46:11	0
465	12	2013-10-22 14:30:08	0
465	13	2013-10-22 19:13:14	0
465	14	2013-10-23 11:41:17	0
465	15	2013-10-23 22:18:48	0
465	17	2013-10-23 18:45:48	0
465	22	2013-10-22 12:30:04	0
466	4	2013-10-22 10:18:08	0
468	4	2013-10-22 12:28:56	0
468	7	2013-10-22 17:38:45	0
477	22	2013-10-22 10:33:35	0
479	4	2013-10-22 23:12:20	0
479	22	2013-10-22 22:50:17	0
480	4	2013-10-22 10:31:16	0
480	22	2013-10-22 11:53:50	0
498	4	2013-10-22 20:25:32	0
498	7	2013-10-24 00:18:35	0
498	22	2013-10-23 20:45:42	0
502	4	2013-10-22 16:52:38	0
502	22	2013-10-23 13:53:18	0
512	4	2013-10-24 06:54:41	0
518	22	2013-10-23 09:58:04	0
520	4	2013-10-24 07:20:50	0
520	22	2013-10-23 02:02:39	0
521	4	2013-10-22 14:05:54	0
523	4	2013-10-22 22:42:00	0
524	22	2013-10-23 01:10:14	0
526	13	2013-10-23 20:23:30	0
526	22	2013-10-22 19:57:59	0
527	22	2013-10-23 12:05:52	0
530	7	2013-10-22 22:53:43	0
530	22	2013-10-23 03:23:44	0
535	4	2013-10-23 14:50:56	0
535	12	2013-10-22 22:37:23	0
535	17	2013-10-23 17:09:51	0
535	20	2013-10-24 01:11:36	0
536	22	2013-10-23 05:49:09	0
543	22	2013-10-22 16:36:15	0
549	7	2013-10-24 03:19:24	0
549	20	2013-10-24 07:58:30	0
554	22	2013-10-23 10:35:54	0
555	4	2013-10-22 17:16:02	0
555	12	2013-10-23 07:10:46	0
555	13	2013-10-23 03:15:26	0
555	15	2013-10-24 02:11:51	0
555	17	2013-10-23 19:19:49	0
555	22	2013-10-22 16:42:01	0
559	22	2013-10-23 18:43:49	0
561	7	2013-10-23 18:46:13	0
567	4	2013-10-23 01:38:39	0
567	7	2013-10-22 23:20:31	0
567	22	2013-10-22 18:37:32	0
570	4	2013-10-24 00:37:54	0
570	12	2013-10-23 15:53:55	0
570	13	2013-10-22 19:05:56	0
570	14	2013-10-23 01:07:46	0
570	22	2013-10-22 16:36:34	0
572	4	2013-10-23 01:15:44	0
572	7	2013-10-24 02:08:24	0
572	12	2013-10-23 01:16:48	0
572	22	2013-10-22 21:32:34	0
580	22	2013-10-22 18:27:14	0
583	4	2013-10-22 17:39:03	0
583	22	2013-10-23 08:13:59	0
590	4	2013-10-22 23:02:40	0
590	22	2013-10-24 00:24:44	0
594	4	2013-10-24 05:10:05	0
601	4	2013-10-23 12:59:22	0
601	22	2013-10-23 03:05:45	0
623	22	2013-10-22 20:43:22	0
624	22	2013-10-23 20:57:38	0
630	4	2013-10-23 14:31:54	0
645	22	2013-10-23 04:20:38	0
647	4	2013-10-23 18:44:00	0
647	22	2013-10-23 20:08:21	0
650	22	2013-10-23 00:25:20	0
652	4	2013-10-23 01:43:14	0
656	4	2013-10-23 03:38:00	0
656	20	2013-10-23 21:57:04	0
656	22	2013-10-23 05:04:30	0
658	13	2013-10-23 17:37:03	0
658	22	2013-10-23 13:28:00	0
661	4	2013-10-23 20:55:31	0
661	13	2013-10-23 12:42:48	0
661	15	2013-10-23 18:49:55	0
670	4	2013-10-23 12:32:15	0
681	22	2013-10-23 09:40:49	0
695	22	2013-10-23 14:17:10	0
700	22	2013-10-23 23:46:44	0
703	22	2013-10-23 13:57:39	0
714	22	2013-10-23 13:24:59	0
726	22	2013-10-23 15:43:59	0
746	4	2013-10-23 20:56:23	0
747	22	2013-10-23 20:34:53	0
\.


--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY team (id, name, password, email, country_id, local, token, reset_token, ref_token, challenge_token, active, timezone, avatar_filename, size) FROM stdin;
1	FluxFingers	$2a$12$trUXIT2RHoeKmr8c83lnbuhavRqBe7SxMV5MjwGaaafHspFlhBV0.	flux@inexplicity.de	79	f	32d5489da728c4cf6ff181ff9a8d0cc284ccf17124e95e36a9818001134a4df4	\N	KHNalWPkBf6y7DW	8a82a21f-1347-444a-b750-d9dd1e73ee9d	t	Europe/Berlin	\N	13
2	Eindbazen	$2a$12$6ig2H.z.BzLq.Y8B2M1wZ.wkLAXJ44giMVaLpulRWKakX8bOS3lG2	eindbazen@eindbazen.net	151	t	f1b961a293c22fc67eaa9a2fc00d2bf6be9128eace3df2bd9abc073131988ead	\N	NCMwvXeRd2JFMKD	ad2bec02-e9f8-4f07-bcdb-d6fc8d37383b	t	Europe/Amsterdam	\N	8
3	Kuddelfleck	$2a$12$0NTrde1cxhbJmhpyDUFc5e6r3IQ.XS51m7oUofRWWqb3fS2Uo.0RC	ctf@conostix.com	124	f	0173329f7e57cf20d3cc4fe9d6c2418304347c0431635db1519b912f0842283f	\N	BAS4REP2FrUaVNu	1d5eca69-f0eb-41ce-8de6-1c2bb5cd7a3d	t	Europe/Luxembourg	\N	5
4	NULL Life	$2a$12$S8rUozekvsZ/43iFJVEm4.FlnZ9.XdpRZUbJlWJzdsaL75E1bLXiW	staff@null-life.com	188	f	b955caecc285b43745f5dd36533449082ccf2c08122b94d613a24535ae5b0d4c	\N	rcgq0KLg4MS50HF	df2d5a81-9d1f-466c-98ee-be90285082b4	t	GMT	\N	4
5	WizardsOfDos	$2a$12$bk8hE2nS5QGn7byPpUUaue8.2FqzVLoWMtx5/8Qomy3uNLV8XARry	contact@wizardsofdos.de	79	f	e7b7cdfd9a5a1d0809a980020c5bca80e42871dcd6871fbf238afec2b975d35a	\N	mxEHmKgGGtzuC2m	5d049909-4215-4374-a731-ab98411fcd96	t	Europe/Berlin	\N	6
6	0xBEEF	$2a$12$Q1xjLFVlsGLu4vKodxPsJeTHB9vPf9UP6OdImtFEKSdcrSNtfo94G	tienthanh050311@gmail.com	237	f	94359b0923533c7ca57dff17d3ba96b1c2abc197b88fcc9627907745f2460a60	\N	ON6jqe8Y9C4JzFo	ce09f904-df0b-48b7-b300-06d668bf834c	t	Asia/Ho_Chi_Minh	\N	2
7	Hackademics	$2a$12$Vj7doUmTyItAcgs.1ijr5O26lH2P8HZd3CMs.AoZGSUpnvKwhnTq6	info@hackademics.eu	79	f	5b43c9af90dd7503a3a16e43e71fe190e67092ea8a86598fe205bc9aed3dd622	\N	u7L4TUkXOiYdM6h	761b3874-4ac6-4892-a020-eed115e0f9d9	t	Europe/Berlin	\N	3
8	blue-lotus	$2a$12$IiQbfSw/Zpz8LFpyffA1P.pOov/qhAgQnPns47/LZhf9a/2XZVkem	blue.lotus.ctf@gmail.com	46	f	d8c9c4e5ed6e65348ef9f70fd10d257daf879977e251efa83e6c331d66b2c3d8	\N	w9QwWClUpfRZu4o	b4be4494-2d9c-4497-981e-a4c2c6d4418b	t	Asia/Shanghai	\N	16
10	shtech	$2a$12$ILLsYfLesBDtjiflz2z3VeRQ9tJxojk0ncLk9Q.sfwhEiZJ7QRrQa	mikael.bourvic@sogeti.com	74	f	9fe46c37751fdcd0412028d35ebbc7b9c065be0734de17db1951992a3fa36c94	\N	6hd8ispAqJZYoZe	ea93676a-0843-4c89-acef-50ad30867ba6	t	Europe/Paris	\N	1
11	Dicksoft	$2a$12$LdD9jo6ibjd18e7OnJIbf.qVyUhzzJQGn3CGrGILrgL9cuq1VzjJ2	root@codemuch.net	1	f	a0380db8da49b428c3848ea276efd1feada52bb95804aba99b2b4f1573468a78	\N	NjG5OomSQQGGjsN	35a73f22-27f5-458a-a87e-a4c0e6b08537	t	US/Eastern	\N	1
12	Abricot	$2a$12$7fKCfHLdBOBkRRrvPSlNUeuafBauBHVWMwVKn19IbPIIih4GgJaHC	3ffusi0on@gmail.com	223	f	c13f6b92badf2b97c5cdc75d77c49272e39e8c11d94ecacd886c240975f16079	\N	iU9RSQxGApKxFI8	69824890-7690-4840-8acd-bf1b0128644d	t	Europe/Monaco	\N	6
13	!SpamAndHex	$2a$12$qGjdi2Iiy/DpSQZcAmC/K.qAF7KhnDYrtW3v29NUOgg4reuBEAVZy	kiscica.ctf@gmail.com	94	f	3c08cf60e49a5b8da89b613397f108f95ce6d9ce3aeae58387a25a2541926ee7	\N	rxmqr3k5EIiptJR	18226765-4d4e-4cee-8fd7-4ded17a89177	t	Europe/Budapest	\N	8
14	TR-Team	$2a$12$V/ZEWvQcBWr0g.aJCYtMR.2czGv2RWjimitFO2w8B5nwqp.C3KXVK	stoffelm@hochschule-trier.de	79	f	dce66cdb4df8e9e1e1f5234fd7c259b109d8b720348ea3f6309a454ef228802b	\N	da8DBbsV58svqzN	6898469d-cdd5-4855-a309-4e162c1f9b58	t	UTC	\N	2
15	yHack	$2a$12$ITAAg/vbMzCTBFTAGJMA/e1lZ8CT5NAED3rh58bMyY6roN785Xr3m	rj.crandall@hotmail.com	231	f	4e08f26fabf47a9e6d755acd8aa59bb5a8f81f88eac582609c7801c7ae38e1aa	\N	YYTunMiVBGjwQw3	737e16f2-c52a-4abb-8a96-059b9d2414b1	t	US/Mountain	\N	6
17	Shellphish	$2a$12$8820bpXsMO8Nw0o9Zg2jVeHOwdaOlNzx5fIh8rqs.uxtbbqL3R1Ci	shellphish@yancomm.net	231	f	517c56dc9c73fd0031642bb99ee00fe06c4a09841097971d8de2a7bcfaaf9e30	\N	BR9VEsVqDVPaUCV	104e149d-6743-43a1-9ad1-fea385d94dcb	t	America/Los_Angeles	\N	8
18	Hexpresso	$2a$12$1BUzBaIXACwW/WhBnYF/4O.b6kiWmaygbDZuoT/DA7zmjeCujdjN2	luxerails@luxerails.fr	74	f	7a7410b3daff74b0c1dae61f107f7eb1cb8c9160c4f435290dd58511e45c2e87	\N	MJOAqChwFOo89rV	3f010736-0fed-4211-b92d-186b97dd8b04	t	Europe/Paris	\N	7
19	$7UNF15K	$2a$12$spNNnMujE29lsIbQ1.0QBejUZPooJYyWyFSRsoEwEcE/Zkc0u0K9a	keesvandiepen@gmail.com	151	f	15b236084300e503747248fb0d93148f7142391e8cf2047cbbebb898742cc6b7	\N	GDpCs6qijyP5Qbw	b6e9ee3a-39ed-4199-93a0-0872364e5684	t	Europe/Amsterdam	\N	3
20	Pantarhei	$2a$12$0WBJRiykrbRvBtyL.TTcIueMf/s2pAElNu.nmpwL5d2qfBqgMsk1a	aprilia_nr1@hotmail.com	151	f	0bca7dec24db859f812630fe00d1c1bac3eaaa0a63df5b6c494d0f4f40bbdc12	\N	QfvdztWtHQJK68d	68550380-71af-473b-8cfb-0c6809863535	t	Europe/Berlin	\N	4
21	SegFault	$2a$12$ZDeaFPX.gfkd7vuh8g8k4Ofe2Am0o/DVNnjZzYXzdQaEwruJDKqDq	testdata11@live.com	96	f	309bd656481ac24eb6fdb6d93233c2f3507f5938d6aa5cc1d5573eb12694380d	\N	WnyZmeoZjDhMCBt	e8baddd2-3537-4f9a-b73a-83aa72ae3cd4	t	Asia/Kolkata	\N	5
22	squareroots	$2a$12$zPpuFFloYBjatVHTJfTTNe9ENi3Kk6ZH4b/qDcRM7lDZsFneMUVw2	jochen@squareroots.de	79	f	28ecab67e6db10de691f51d727b0a369ab894fa477530b5b087983c1bcf549cb	\N	expHC5j8qQjVSgy	cebb126d-97ed-4766-ab0c-3693b0916bcd	t	Europe/Berlin	\N	6
23	Pwnies	$2a$12$t2TpqEnQ/vxy0zYSDpQYPulv.bqLDjCKIU5Ot3g4kfL5V0g5bcx6C	pwnies@diku.dk	59	f	787a22e73ae08fb01ee14356ecd61fbce8472928dc19d8e29c808288a023b07d	\N	PossSnTRoa2u8ND	c80e17c1-fc78-4d15-a9e8-d71f1ce461f7	t	Europe/Copenhagen	\N	8
24	Delusions of Grandeur	$2a$12$LsSnyDflFm4rRYwixg7ELu7GomXu3r/7OCM11Exbz9UIITbR6g0mC	Delogrand@gmail.com	231	f	972a010aefd2715d323d3a2aa91fff407bb1e522269565273f2cdd4acf948abc	\N	zp3tRd4tHkpShGd	e93a30a5-b9b1-4542-b2ee-3b0daeb81e05	t	America/Denver	\N	18
25	SexyDucks	$2a$12$6Jcd8QrRY9Oois1rRejwN.nlEFIgx3sShlD.xiqXC82DiNgvxQPCS	marcturpin@gmail.com	231	f	a5dafb10b030def01e33f1ce71c201a60122fd0ffa0135a0e4c4e8b7c4d32235	\N	7B64FzeuoSm7lN9	de2eea39-6aa2-4fc2-a731-c5e971ca4c61	f	US/Central	\N	1
26	vagante	$2a$12$9QK39Le8hR1ubcpIgRC23uWYgyDKOB2mVbFVsV6bvoB5etIG8bEty	vagantelab@gmail.com	1	f	19c8f64c8e7f4494fb3d44a11db970c7353bbd15584954da5fc36904786dbfbc	\N	7RdHotS5pdEMOaO	2b24aa86-ab77-49a0-b63e-fc1959a7cfe1	t	Europe/Paris	\N	1
27	pl4ks	$2a$12$LWWBsu4a4lxfBWB/3qgUa.7Eg9trYl8qwsHaQ5DlwPROfEtJCuvOO	akbar.dhila266@gmail.com	1	f	6688ee63489fbb3975a2d01f78d7fd9c8739205afe8193ef5b067438f4b86e84	\N	zGPCkwYyisi4PI8	426741e6-a1a5-4351-b2d6-5ef497ff705f	t	Asia/Seoul	\N	1
28	New_LucA	$2a$12$uqc9JeV1.6gMVwttdjwQUOndTHYtROkHNYfylBsiPPAbdUqlGc9SC	new_luca@yahoo.com	177	f	dc197832ff443d0ff61132408dfecc7fe98ef7d6291e27c7e531aa4a7e7bb6fa	\N	oBdoTh4p7AGeTdP	db9dc3ce-a602-48d2-81d5-248033dbe314	t	Europe/Bucharest	\N	1
29	VY_CMa	$2a$12$G2l54FO4/l65L4gc74aaN.n7j6OLiAU4JvYHXMmeJsZN/MDsRLxq2	akamajoris@gmail.com	178	f	7dbb6e1179cfdf8ed8f37799ced54014595e7705ac63fa7f93e7e27a06584e05	\N	K4hrl5Ff8b0n1ZU	c9ad9085-0cc4-4243-8204-9a408c712a78	t	Africa/Djibouti	\N	1
30	wget0	$2a$12$JiQIRzVr6UGvXwamPPjuHuVFbdSi33STs4Q0yO16XNEtHzZl1YI76	theassd@yandex.com	30	f	fa0019046b27aa2ea336dfb7fb2167ab4cbdbf9a6a01380299d1d18ccd51c40a	\N	gFSlxus4KabxGMg	d35a5d4b-dadf-43e1-8ef3-cc3f327f2b0b	t	Europe/Minsk	\N	1
31	ReallyNoNamesFor	$2a$12$xpVBiqQ0me9r9No/1Qjer.lwfVZ1.ExFml6lXSmuvnvzGaUO3fH8O	reallynonamesfor@gmail.com	178	f	fafded4bfedab458fac0392dc756b717646919a09926a4710ffdebc4bc79f4e4	\N	w2bZh1JW5xz3C49	d0e5a185-d2e4-4602-943b-2f943b82af6f	t	Europe/Moscow	\N	7
32	Hexcellents	$2a$12$9QgDnjdWvRq0ZKzW/j2Iuucov8unTTmLjmn8R47ExiGEpuuNcD3.q	sinaelgl@gmail.com	177	f	c55bb3d425eaf5d5ff786af9ebde9a65b7a069063e4dffe241844035324ab780	\N	tXbV6qWcRr111h2	2b9665a1-113f-4b09-a948-2cbee1c33c1d	t	Europe/Bucharest	\N	3
33	More Smoked Leet Chicken	$2a$12$ElYMD1t3JDtwGUKh1eQjCuFBXY3Mk.iSkb.znXdvMQycDeVINJLTG	mslc@ctf.su	178	t	617b02e55a6bedb1c01807bbc76bbdb1a8d7880afe00671497e209aa87a63782	\N	wuapMr8ruTSyuHp	28cb34a9-d461-4cfd-a32e-93c89524999b	t	Europe/Moscow	\N	\N
34	DevBy0	$2a$12$LJuoFGrdCl2QBKBtLOu/6uMqWaMClDKTiox6ouGQq.XUCeGoIKSyK	grizlik91@gmail.com	178	f	b75b524bbb5d3758ab5f4395e4db1fb5f76d8ab238ffa015db5a2266d509cdac	\N	2SCRzPBDCJm5F3O	bb745524-0334-4521-a1fb-28c65c5c428a	t	Europe/Moscow	\N	3
35	japanAntivirus	$2a$12$gbVueUyRWSlKDnn1ULmFnecrsoCyaenMxaGZqG2B017mcuIB4nw4W	vietwow@gmail.com	237	f	4f7093190f7ac06406dd3a1a0ddad385d44e8aa60e07462cda5fa5544c3ef66e	\N	hvP8aZATzKLwAoX	5dc24e90-5c08-437b-98c1-4597cab3bffe	t	Asia/Ho_Chi_Minh	\N	2
36	baNULL	$2a$12$0m6BRFBvlKnhOcgHA51c7uZP8MCKUtd/fhjJb5Qh6burGueJBVBeG	dtouch3d@gmail.com	82	f	47eead0f77e7ea7627e2e3b783b4d109ac9fb882f5a0e6b9352092a47ffb42f0	\N	ewbLjPVYRyI8r5R	8974483e-061b-4c46-be8d-8bd0fb17d5e4	t	Europe/Athens	\N	3
37	tasteless	$2a$12$LNuFKOAZAvZyO7aVwCEDXO5WqNO54cMRV7Vq4Vc9H4VODZt1c1Tp.	bryandehouwer@hotmail.com	178	f	6a19a0ebeeb35459e7a4dcb45b6060e20ba0b088775784d3b34a25dbacef320f	\N	YQLYmpEXnwUmpWQ	9505933e-9eb9-490d-b600-2327bd33414a	t	Europe/Brussels	\N	6
38	vodkamatreshka	$2a$12$prF2XQhPTqE98FZ/bdZxBuRl6zpfTXu16Xw6/mNMCUmZgViqLnNCa	eshreder@gmail.com	178	f	8b017d407b81c3918a44593f493bf6be38d5cd61ecb750949d9d280406e621ca	\N	aLTbglc0Xi3wNbF	26f89989-e269-42f7-947c-3b0118e36700	t	Asia/Yekaterinburg	\N	\N
39	BalalaikaCr3w	$2a$12$KDaIyMZrDiXwcesIJNIm8uROl8iHiT5z4diX1Xx7iTiksP7p1ZHTe	balalaikacr3w@gmail.com	178	f	da7eb6d07f2c01d0c5e5dd86685d94c5ade322d72dc6608161f79cec6dea0e6b	\N	z4jPRxKcIj2QEzN	f74af19d-7f2f-42c4-9e4a-c962985493c4	t	Europe/Moscow	\N	\N
40	ufologists	$2a$12$.35sF3r.RuT.VfHHiqpYQuSXPC/NbYw1bApNAVt8MTtqHlupDUfhi	ufologists@gmail.com	178	f	7f2fa869d4118ee0effa555fb970eae23354822acd2f536eb769fe1dace65953	\N	pOqyufLCr22MLDY	ceb4436c-2741-4942-90ca-c80e112debdf	t	Europe/Moscow	\N	5
41	l33tb33s	$2a$12$8h0MhUSi0d5XXo6DHR3A7e.1ZIeTMIUxLVbFvLDZncC9DjllcZaiK	appsecteam@gmail.com	40	f	3d8dada6a186ae76aab7b42e08ef5786869c56d79c798df9bf4abfeb93fbb174	\N	ryDeL8FTvTm2mo5	c3245960-3040-4673-97be-adfed303fef9	t	America/Montreal	\N	6
42	Autobahn	$2a$12$Pmm3iXKW1D5VR9aeQJQ/1uz8ewBBEjkxEdoPIlAfLjeJFvqRtvlym	rudi.falkenhage@gmail.com	122	f	f9030e2da9ce59dcb91332c7c35d3d420949af5be18544330cc88492f1fcd00d	\N	AFDaBM9S3IVUaTY	a330565b-3ff5-4f37-ba82-54d0b6db3519	t	Europe/Luxembourg	\N	8
44	42Dinosaurs	$2a$12$OA.MwB5oPp./1IJkM/G1MuNymUVc6NpVysS8XY/P6aw4e8WIzjL7y	ss186262+fluxfingers@gmail.com	1	f	52a6bbcc36d64fc8ab348cc1141fd82b5ebe95958302a8749c9052ed4815431b	\N	jOAzDZmavXHrHMQ	6a0e258d-cb6d-4027-8932-15f95a60567a	t	America/Los_Angeles	\N	3
45	Stratum Auhuur	$2a$12$tZ46hgpv3xDQT0Qp5avqEuZLKCqE0AQ3DEFeYTcqwBa4Sfm79KyIG	auhuur+tsuro@zero-entropy.de	79	f	ca0086be5b55f8bd1b0470375e2df2db9958ec4500bfd8950b458ff3e5d871d9	\N	pRFB0FbJs2iH7sL	378aa865-220a-4f5e-b961-7663b0a16314	t	Europe/Berlin	\N	12
46	lerpaderpa	$2a$12$1DINP9D2Uf3L/Irni8yN0.pUQusyZu2e5/u8g/wO68sl3PuvWKyxu	mahhaha@gmail.com	231	f	de944f2c514ee499c0103fd266de2db5c2dc36b09eedde8fb04860389448309f	\N	a1F2diK3wzRu0Br	85f636ab-c589-4c47-9c0c-21d3fc5df5eb	t	US/Pacific	\N	1
47	Forerver Alone	$2a$12$ewqLqNiVVdFP1aa0uOfgqe.AOfb5zXjZp8Yel1kDburSwprr50eMC	philip@schmieg.eu	79	f	30fbd84793ec28268defa65acd28336ae85849253d1c60f2315d09d0093d7909	\N	Ee6e4DTPVOcTExW	91d41f21-963c-4e84-950c-b13de0352df1	f	Europe/Berlin	\N	6
48	Forever Alone	$2a$12$611nqe2g0C7Qu1aVye5fpOKtXXcNllbMVI5Sdva8courFTTf9oQB2	philipschmieg@web.de	79	f	6862c921b0dab11287697964fab662260907651f8b500db7c525cda9928e6b54	\N	sN0SMqzcLTvpvCp	5d150534-f797-4669-80f5-53becb24d7df	t	Europe/Berlin	\N	6
50	GECen	$2a$12$3JbewVht18dU8W/5x1n3WeerubdqHSjvEeBMDsUszJ3w4/L2yStPe	GECentralst@safe-mail.net	79	f	cbf9376aa3d40a192641071d599a8a47f19fd56461ae42f65288a9b8aad0d936	\N	qrSQf6BN4xTNjrj	dbfcfc59-9c3b-4e9f-818f-415791794354	t	Europe/Berlin	\N	3
51	1338-offbyone	$2a$12$6hjFDp7e61kxTS/wK71pa.JWXFjx8Z1oCrP3KQ0l43vati.99hYHC	ctf@scoding.de	79	f	161fc11e3218dfc11c27ef276bc2f2a47620ffab8795820e563f76e27f21cdd7	\N	mXlRTtvwYbfe24w	552ec56a-dff7-4c04-bd0f-55d32466f246	t	Europe/Berlin	\N	4
52	ctf.is	$2a$12$FWNEEvgGvEqif8gKUtMw0.xQoq54EpjsBUDGr5anoggzwB9p.XR5S	slyth3r0wl@gmail.com	17	f	6409196777c73c0a32e72d113d12ac95649f3ffb9dcc4e62e312f71e96ef7439	\N	gzJaz6jXc89F7QQ	4b5efcd6-d59e-435f-8df3-3f2f42af4571	t	Australia/Sydney	\N	1
53	[TechnoPandas]	$2a$12$nmAh1idiBlfVKlQAL9FiI.uzWsPt/cyU7c27VNTAjEwQ25G4YQkUO	techpandas@gmail.com	178	f	c289e29445af60e53e1f8367fb4ad18c58081f4dc636dc3c0ea1ac492722cf5e	\N	gLcTWTlUB0k4aCx	0e2e3455-4845-4a16-a4bc-07676e58ac29	t	Europe/Moscow	\N	7
54	WeLoveCP	$2a$12$At5eSr93UTBSeOY4PmHHw.qw77xn9BpinUu2uFPH53bYiOd3RBz7G	welovecpteam@gmail.com	231	f	b0d1d2a6674e6382dd16b02d353dadb153139721fe490d0bd9ea7981f5f9a0c4	\N	PiXrpoKYArvhp3x	78ad1a43-ddd4-460b-b186-21379a03e362	t	America/Tijuana	\N	4
55	The Cat is #1!!	$2a$12$l98BDgwGb89zcdUfZqSh4Olo.zDulFgedcgU8p5ZcMdwOvJh9K4.S	patcarroll@gmail.com	111	f	c797ccac21f5bf14bbd94b77258a0ee947b854f310d59931abd3ac0862d2a62e	\N	MWyN2vwnSeo7HQw	20d6832f-d8e7-437f-aee2-d0958cabb59b	t	US/Pacific	\N	7
56	KoiBastard	$2a$12$Q9djvY7I2XARlGxQ6F2lT.FNcNyvh5TSGkWQ71pI4Qa.TG..pDY5S	koibastard@gmail.com	178	f	d481a1f33fd285c119b7aa15ebadb180dac9f317b6d2defc44c3feaae114b0c5	\N	Q63DEnOZav6ekoB	aa7be7e9-c302-4d27-b3c8-bfb39f642011	t	Europe/Moscow	\N	12
57	Team ClevCode	$2a$12$niwy.ZBOUn7jAD4MHQWWuet10f526Olc.eopvZHD0fAFkH4bgtV9W	je@clevcode.org	210	f	3288fd8a75f863b46f86d5cd78450685ce013801a195dcc2b2f32af211cbf411	\N	x9hPBLAsK6cV4Uk	c2f9a501-839f-445c-aee4-4f517df19f9f	t	Europe/Stockholm	\N	5
59	RooterX	$2a$12$dgCCpk1UzKo00tdX5jiiEOqNP1oIx63AU.WcnZbx/5pbcgkgREriq	teamrooters@gmail.com	178	f	00ea96048b778e1fd192702a172c62e5b7563659e091123158520878c760f98d	\N	rrkbkywMitwFXxq	b7b3c221-ef4f-4d87-87fe-ddae841b1f21	t	Asia/Yekaterinburg	\N	6
61	EpicTeam	$2a$12$cqyja1rXBALNzoF/ZiBtreMgysBB3DrRpHvDDLvXeYYnG1kUAkrHG	VitMalkin@gmail.com	178	f	b5371c0f58a576027ae6185da10cd3fd7c0854c16b48198436b209a6773de6a3	\N	pQjRpSz8CiNJ3mB	f759258c-76af-43f4-bdfe-da094c16d3f9	t	Europe/Moscow	\N	7
62	Paranoid Androids	$2a$12$u4KOHUvQ3IuHD/eqCs4QmueipxcT7cr2LdCRtJ0azsEKIQNJ5lR5q	verhoeven.y@gmail.com	151	f	548e61b5ee9fe1d961c70ef31b132f83e8312fff40c666912925cc5054d32d8c	\N	gqMP6lS9YMHvESx	3d2597dd-9c59-4383-99b9-6a2fa4808543	t	Europe/Amsterdam	\N	6
63	dcua	$2a$12$G3r0g06m/hPBKfIb//OCiO/61uZze58mbRLihnOPEshzjw55Ml1PG	solarwind@defcon.org.ua	228	f	a683a71838a46d4b282e4bd7474d57b17f8e7d10b10acf0cc2eac90be5433176	\N	WNEsvQABp4yCGeU	0d33aad1-26ae-4e76-a8d3-39cd07f8e28f	t	Europe/Kiev	\N	10
64	HIGIMT	$2a$12$6AsjVfqc7nlsKNRKZQ.VXOiTHvFdfHx8QMLyDlsaNo1ehrYbASiX2	hanno.langweg@hig.no	162	f	36b7967c8f7ebc74e0c0eaa32bc2b0f918cb279f3df270ee07c597093dc3b6d8	\N	uHWbQPInqX6l5PV	7ff6a670-c0a1-480b-9f19-539f8bf8ee75	t	Europe/Oslo	\N	50
65	CTF-UTOPIA	$2a$12$XgOPFafPzSXodFmhLPSx3uY9zbXwR8Ik20fI/xhq1TBL50stq986a	bbhw1210112@gn.iwasaki.ac.jp	105	f	c93a23aa1e522ddeffb3fb88e27cdb7615e49c54263d1d7170a7cd1f94faf25e	\N	xvb36Hv9yCSLM25	b7a297ca-00e4-403a-8109-43b9b13d214f	t	Asia/Tokyo	\N	1000000
66	newbieVN	$2a$12$/02fTfzmSgSTId7E24fNrOssVTGaxmyiESorX4GDxfnNzVOEgGDe6	nguyenminhtri690@gmail.com	237	f	825d46a2ac3687f43dc6624dbce252e01708f10f8b77d42b38557270506267cd	\N	1Hh4Cj1NlfMAOV9	2ce9fd5a-2bab-4978-9d81-24747909491f	t	Asia/Ho_Chi_Minh	\N	1
67	Abr1k0s	$2a$12$t95J.qr87QT.MJ1cLSwZSO7qNEp/X8v5u..ys/X236W3MdgMGwd72	Abr1k0s.CTF.TEAM@gmail.com	178	f	35077a4661426dfe7ca5e063063e3cda0a56f00ccb980ca40abf26149af66492	\N	3dxu8WkUg0WEspr	23271e85-626f-4983-8161-fc90bf2dc587	t	Europe/Moscow	\N	5
68	Tarik	$2a$12$HXkNyxpwD8fe9oOcB7IUYeuTRAFo8FfT7KJGe..Ie/wZtdpc45fnm	tarik_cwalk@hotmail.fr	144	f	a736ad291e0f80d46c8602ec9c5e80860baddb71f187c394c30534dde33d92e0	\N	uWdtZPplVF9M8Db	56b4b39d-9380-4182-8b10-ec2ad401a090	f	Africa/Casablanca	\N	1
69	ShadowCrew	$2a$12$PZfKjYhckifBKK6D7PBRH.t2.FXlqG4oApqlbPQn0eMCwXAA5v1xi	klynn@hp.com	231	f	5b3426321fb63de88472aafec7db20f5c343a5f974ac764cfe28c45f2b4abe47	ffacc83fb2298d22a4a029287a5eb217414f88bfc44a7a17ababe64b5979018c	hihS20jzqjVjUqK	dba505f3-cff2-474f-82c2-7b4e69584299	t	America/New_York	\N	10
70	BeginBazen	$2a$12$xBnRkArkQbft0EtqV1Gz1uwuon5mf1fq/mclxn9N.nDeVVeaecV7e	beginbazen@gmail.com	151	f	2025760b3d758d1b5c0b80a6d28b859d0e0b227dc8caaee3f733969aa1a25bc8	\N	k9oJVCjgq49FK9E	e0b83b2a-9324-416f-9578-b7439a7a0613	t	Europe/Amsterdam	\N	8
71	rdoaa	$2a$12$cSNBk72RMqciuOf3pBxrJeenZbeLIvy83cfbdc8UmcWE1sKRa8kQ.	figigo@gmx.net	79	f	e31b27855c18e329f406c5a0f6d47e4112cbb249925f9978eed776ce8d6dbdc9	\N	HdhAYAW4bsSprCz	0231ac19-f2e4-4909-8e80-440134815edd	t	Europe/Paris	\N	1
72	metos	$2a$12$930Tvk85u15o2Gr8nT.4peDXUZUDkujTa3VG33fYU0WXs2mmC5Ioe	metos@inbox.ru	178	f	e1a3f8feb194f5b3ea7cd9754fb8bbad5e026640dadd1cc3d511d051a00b7d01	\N	MxM7jRMMwDcBjAW	58f20ddf-9864-4f8c-9ef1-da61240168d7	t	Asia/Dubai	\N	1
73	HighFive	$2a$12$F8ursQOT3Igp8LGvJnk/5.10xyaJ0fBmV.qt4ChGJw2TD8ikloPky	ctf.highfive@gmail.com	112	f	a2e41a7ce43ea29790cb9f3e1e79cb6cc834c56a681331557c4be34d2b5c77ac	\N	9MSpMdDvttPxfxI	8b7b16c0-e47c-430c-ac6c-b316ca7b4117	t	Asia/Seoul	\N	3
74	CTF-infinit	$2a$12$QAu3tvthKtpRM3amh.KQteZxzTbShM37mgxylwpIBOCBiNfFYebvi	tadatadashi+ctf@gmail.com	105	f	8c68afa288a9753e0c44b096e9a4dfd7071221da22739b0db3d2d44cb3977483	\N	L1Jr7iJ74wADl9U	8caeee20-d585-421a-b33a-9d29e6eb2d93	t	Asia/Tokyo	\N	5
75	VLTN	$2a$12$d0ANeld4i.IBEosSdXLcN.mDBoZ25eeZeabrnQXaVOZJ63hfieWQ6	toilaabc123@yahoo.com	237	f	87885dd4c55ed72e36052ecd64e03764739db9ac68ce65d03a54ee34d501bcc4	\N	0g242DmdBiPJMnf	4aefc012-e71d-4c50-8f7e-8c024ff9b81c	t	Asia/Ho_Chi_Minh	\N	5
76	PwnState	$2a$12$5EZ/HGrCoivQruhzUDBnhuZdwjMHUbYfVSZKj5Z0DaiKCHsdkHeCa	chasemiller5@gmail.com	231	f	5cf58d0c208a8267c4642ccf13e9708564eb7647877ea17c766180df36bb58df	\N	RQh04ZHelsiOcYt	b7b71897-bcca-438f-baa3-aace34016362	t	US/Eastern	\N	5
77	Yozik	$2a$12$1OZorW.gM.E9pQPvVW9Xce6Obe0drcmHPWJbfLj9/IdRrOjf3SYum	ntpcp@yandex.ru	178	f	acaaed8133d48c120621763f20d340b539d68f2f869face2ab42c2c0027402ad	\N	tiuaMhqCBLOhrVb	e5ac8905-6c20-466f-bece-a73764544473	t	Asia/Krasnoyarsk	\N	6
78	tomcr00se	$2a$12$qE4f9J.DsZL7BXR04w0NFuG1zMsxpEXddxIexm1YQFqLuMxx0VxUq	geohot@gmail.com	231	f	163878784b2abae5d83a5606154e51f4121d16afbfb400b0e2d07471f510a07a	\N	ixklqNftkTJu6Xa	9c45e3f0-10fb-4bbc-ab84-a49fe4b7708d	t	US/Pacific	\N	1
79	Jenny	$2a$12$g.16HTX.9QcsI07tGRniY.rm5CYSt7ZpeSTPZ8VAeGW8pgharbMTK	joshua.kordani@gmail.com	231	f	12c5a31c936ac3058c83e38ffa5f9bd0d900b0885661cc84bc3ad6f32ec87209	\N	5ZRDcCv1zB6JiPK	6533741a-fc6e-42d9-b469-6bbec4619d2f	t	US/Eastern	\N	1
80	SUSlo.PAS	$2a$12$dI4wtfBv13FKMrl8i1TCvOaVaBjj9LdIPD9vgEXAJAP.SnNcD92dO	n0n3m4@gmail.com	178	f	773a474882543080890f297f9a7b38dd6c50e48a555a9c7715a2b7e66b1be587	\N	atfGr4x3rlaPdZz	b3cafc74-4559-4cc2-bf75-778e8e67bdeb	t	Asia/Novosibirsk	\N	2
81	Pi Backwards	$2a$12$hWcbETeqcUpRwTEvlwHPyePmA3Ghly3LJNhcRS38wTGMavuf3qw/6	altf4@phx2600.org	231	f	4e8a6d00adc0c08cc8348a687b7b7367281db56b261c8997c49cc3bc82647d10	\N	MyHl7CtvFtdqnfX	415217ef-ba77-4730-b5fb-a00e922dfa4f	t	US/Arizona	\N	8
82	itsgr	$2a$12$kxTd81Z2TmIv7ISlxGizi.9OuKuVYWld31ZsgTpU/H3.5bzxAqQWG	katagaitai.itasugiru@gmail.com	105	f	1b1534493c2bc23eaac4cff7654f635923d191f9f2dee097be43151c989ccbc7	\N	mF0R0MC9ZuZrE5J	a5f0e045-c282-43fc-849d-ce74280be0b3	t	Asia/Tokyo	\N	4
83	bi0s	$2a$12$UZA1T7IVATraDfLjp7HPLOr9ARULssFCJaffaAcRNuRY4nSkWSPrC	sraj.arvind@gmail.com	96	f	8e3be87aaa034fe019f80a66ff2c0c1b8bdaccc8d6bba9ee756d6de4322d2b7c	\N	V430b00aP1wX03x	b2e1f830-d86c-4dab-9880-58b46655c6f9	t	Asia/Kolkata	\N	7
84	H4x0rPsch0rr	$2a$12$H5XmHL46UUgHmILQ/xjym.uGWN30vec0XMpeUEPkWxKwrnmqFVJIi	ctf-orga@sec.in.tum.de	79	f	d5858d18cbbc95baeedafd598e0d9ea592d355b189fdf118d973f905bfe7c94d	\N	VrNj9H1EMuGI6ZQ	e644bbcd-527a-43a8-8867-568130e7c9d4	t	Europe/Berlin	\N	15
85	captchaflag	$2a$12$poHoNDRid2JBqFDD8ugFXO3OvhSkAlIYyhvwQ0F56kASQsKMhFx2S	captchaflag@gmail.com	231	f	2e801f7458d1f454fd4c24f15c3e7b1e31df1b767b3e1fd509ec857a001e8ab1	\N	PqPgexYp4lCHXjX	03af4f62-c360-47d7-9bd7-7b736abc7752	t	US/Eastern	\N	5
86	2mr	$2a$12$EYgVeE8I0zq5prnyA4pUqO4JXhzZPq9eEAxwt7PCWarvqlq1hvhou	m.rahimi@gmail.com	98	f	652b9de368983fa9e3ce6d50781fa414b7e3ced74f533e032c6f5c8f77182bc3	\N	BYPEz2MBB9q8F42	9f470e40-c648-44d7-81ae-77a9fa5864ea	t	Asia/Tehran	\N	3
87	c00kies@venice	$2a$12$P1fG9HV7Jq47c6JS/C7R9eMSuQt4nIbAnK4qS/zOokVlKZRIgq7dO	repnzscasb@gmail.com	103	f	5a4f029f5c0730a4d8bc69812d8f5851e3cfcdb60b855eb7babf56cf8980e6a3	\N	XJ4mFhVru7Ew7fw	b9bee0ee-d3e3-42f3-907b-aeff615a584a	t	Europe/Rome	\N	4
88	Vorpal	$2a$12$npdzdcCgn0kx67Ga9m3BXO7sAgbcIx.AdmknicAWD4mbFr8Zz5NPa	bbrock4@utk.edu	231	f	aaf64b43cd96da1b355afba88814cd35ceea85d3e7e1c78c985f0fa8bbc96448	\N	o5EgGxLe4CgkH71	e4b3de4c-4f97-4257-88a0-a582ce65d2b1	t	US/Eastern	\N	5
89	RDot.Org	$2a$12$ZdkNA6lFlMDl6wiNLSkvuuKTaId0yhfAotwnIqS.KoVvegmMGccEm	beched@ya.ru	178	f	c8f8b513de324baf736925c11423dd1b2f73e371cf2499c9a658ef37ddeeecdf	\N	3b8Ats5N4xHYGpb	2e90100b-8163-49e5-ab13-036226416859	t	Europe/Moscow	\N	3
90	kakeby	$2a$12$piaKqXwTRFXjIQo/ujodte8s6QQftQK6w5WJP88TBSKVtTsJH34Za	benni5000@yahoo.de	12	f	c0e6b202b2501c7064b227e224c137adce5c532004c44cda5689a5bc6ae05630	\N	kqkk6PkWYA83yHh	378efcb8-023f-4d24-9c16-c578b7d69a53	t	Asia/Ho_Chi_Minh	\N	2
91	BeatsAndHacking	$2a$12$2WOdJQKHF9p74xfsEPcmPe3HoYRGAbtu72214h5sGqRn/EQsRRNwG	kripto@hotmail.com	204	f	09c1c61e9051bf44722e43efdeb60ca12ca33d12f94989776c4e2f4fb93397df	\N	PMGLCEKW7Nmie5B	f5c380c8-3c57-4b64-8946-0f5260477464	f	America/Los_Angeles	\N	4
92	blabla	$2a$12$e8gjwcbeDUpo5y80iQycnOSBk6VdEMduVtMrKy.j64tHuTfEi4sUi	blarblarst@safe-mail.net	79	f	ba29692bdeadfad376bc4fe27c0f84ee732b8d2f4d8f8cbfe0d3ebf290a1cad6	\N	HSM0vwVFsh6nP6R	9fd39d4e-e054-49a8-a2a0-7081e82ac7b4	t	Europe/Berlin	\N	1
93	Baghali	$2a$12$vkgEaFFEzVXzJ2XmyS5nx..AObZmL9SpUTeNokOeqm9Ss6awAVswW	baghali.ctf@gmail.com	98	f	490207d583fb08a3f52bf625d40c3ef07e20c455d2048b5389653684ea5df6c7	\N	oHYlRIrjUmPzH9a	d673320f-2ed5-457c-a83f-b78c02d544e5	t	Asia/Tehran	\N	2
94	Glimpses of Grandeur	$2a$12$FkQNE7hBdhWWX.QsBMW7a.ccVjODJlTdGbGNRVWW66S8i3DRoK6/a	glimpsesgrandeur@gmail.com	231	f	441c080dfd214c879323bc74ae7688837922fbec180c8a93fcf36b8e1bee868b	\N	2jcH1p5Y1GLOvTg	24a6547c-465e-4531-9c1c-814424bc752a	t	America/New_York	\N	8
95	ZenSecurity	$2a$12$/QXCnT3b5K6/9VMrc2rP3.BOlkDq5C7sD9wsIWnV15yTlAQb6uDr.	mailto@zensecurity.su	24	f	b3fdb43ddfb946b2335b188237383a01b339251004ca18f2f5264518704c5522	\N	NUjfLpNaEff6Gpq	d6584bfe-be89-4610-8008-1bc698e2b1f0	t	Europe/Minsk	\N	4
96	HigGs	$2a$12$pzrQC0mi1GD0D8ipbB8xVeihijMsZ2dnNf7dBKSCpbHcN5AgPSdvq	spy.gfwed@gmail.com	46	f	ee9f5a9e57b365f4894cb1e4c1f739e6cabd430668725bc810fa7bd74f9d971c	\N	hVJbjD3vbE6li5C	5071b1a0-0fd0-411a-b32d-4e2ca6372a28	t	Asia/Chongqing	\N	2
97	ZeroPipeZero	$2a$12$OOm9vSwMHyEcqaxI3CTxJ.VzhjydKsnJYkGFb9lFYJH2y73OAXfE2	sandboxsec@gmail.com	231	f	6749f1743c5c17a8b61e2fefdba8e06bdfaac5ba5264ffe64276332feddbd713	\N	KWL17Y8l3BDg0IB	16124053-3159-4d65-8e78-4279769aca07	t	UTC	\N	8
98	0x4E534931	$2a$12$9Y0C8ddIkFmobczBh4MOyuutcuz5eUfsXo3qfWUQ9zJVugoqvZjUy	tty0x80@gmail.com	17	f	bc73b1ee4923153601e00e363fcf4de45f1aa6f0dee3e56ba688cbc7ad3274fe	\N	XoCAM8QWrIwJ3yl	718f47e2-231d-4a1a-8557-8d89ead402f4	t	Australia/Sydney	\N	9
99	Honeypot	$2a$12$iRd72aowOxL85QDFmlpd7.N6phhau9pQe6dqApvxDED3tVHLEKvS.	vlgu_hackers@mail.ru	178	f	165aabfb26ed7b57d12a76d2ceabde4eb8b75fdc81eac35dcacd25124f1ed89f	\N	fHpm81fYU4ZA7Il	20aa35da-18e1-4fc3-a769-09c0c89471ea	t	Europe/Moscow	\N	6
100	z3it_0r	$2a$12$xfsF5F4rvHkTRnV3sGgzMO9BPI/DEw9yYCYCFOLYNLaxgWgVtLnjG	tapion.sol@gmail.com	9	f	126ef3846e092f99fda65323f3f5bbd06b72fe621384103d3550b01be8fa0f4e	\N	81CUF7PutdZK0it	e2a1a5ca-a86c-448f-b616-f835b9f68509	t	Africa/Bangui	\N	1
101	BS Labs	$2a$12$W.pZOob9y/aFZXZ2KrA.X..w6e9BOI.6CtRRVFEUNYjMaKK1WWQO.	keapZJfkQoSTa8fx@hushmail.com	231	f	c0f8faa9304c58b6e46a8fcdca8b9e736d7aeb1a6d450c4c134765f6b3761ae5	\N	XFDGkBqAawAM1KY	8a758cac-3630-453c-81fe-e1fb8abb71a8	t	US/Central	\N	4
102	BOTNET	$2a$12$Owk8pAuKkftj4464RLvHT.0IbOFTi./vnR/omwBgLgs4llmZjWMrO	hk.gold@me.com	25	f	71b5c68554c3a77868f391a5824340b9a74f9cbc8903a556d6eaac04f3ae57f8	\N	LGG3QaUE7r2dFpS	d16d6979-d144-4c32-8d64-3ca7fffab609	t	GMT	\N	8
103	HeXA	$2a$12$Km2Ua651gHZGy.pQMbcAQ.mWILDySp/4wt15xNNVwbHIAMOwXQIcO	hexa.unist@gmail.com	112	f	d777ed9427be43cb739a5f553ad4e0414d3a451a81b9e7cefe610e56e67d415f	\N	b7zbluf5lr3WVCK	84f8ca24-d73f-47fa-9d0a-45ee8793c77a	t	Asia/Seoul	\N	5
104	w3stormz	$2a$12$EBhattxIa6ecsyGNETnr4.Yd9OHPdwxJYulROjDGX7vY1K0qbPh9i	w3stormz@shell-storm.org	74	f	79c48bdf4e2d086cabb41d9510f4dc78ba2a87130baff9734980129d07b71e54	\N	LoH9uD2k6GWj7li	768d15cf-2f88-428b-ac1d-8c0f9909b4e1	t	Europe/Paris	\N	10
105	h	$2a$12$GBwfaEII/y4s8nPKShfDSueqImZEEJFnJ5MdKvTX1Lb3TV2Ue9jKK	hcs88cp@gmail.com	112	f	eb998bcb3e6a15a401626ee92daf8ac103ce803c38b0b722f8d43b074f5d49c5	\N	wXBDtLdaqlg4EwX	f4268a6b-a511-4700-84f2-5326c21fb546	t	Asia/Seoul	\N	1
106	mongulatedm	$2a$12$yKRKhVRbqyYfIBe7OjCKlOgTX5l2J3JRdoKP3PRpgfDk8kVZOIosi	mongulatedm2@hotmail.com	17	f	86397a1979eac11a7694396046f17e7880154bd061058ed1c83c949d7ed10a95	\N	TARQ3f3IiEFfWND	0d2302a3-12dd-4e40-9641-dbe70109ce0b	f	Australia/Adelaide	\N	1
107	lesboverflow	$2a$12$wsiVh5SOzHdb3sE3EX4KeeEb1T7Kjptl1y0A.5W2S9x8VMxBGJjhy	lesboverflow@gmail.com	230	f	80d1dac26b547bce58725d916382958b915ff5484e815d766570cc492261e4f7	\N	L2cm1vLdlFZS2gj	4fdca299-338a-45d0-816e-b3d7e4f547d3	t	Europe/London	\N	5
108	illegal	$2a$12$Rpig1OeVLnbEtWz7gToSxu4q4P/p.lxc2JWC5EOdRTSVeBBvL3Ug2	ayushgupta.lnmiit@gmail.com	96	f	7df4b74871bfcd5a4c507b74a90768b90d177a3fcc415d963120c4ea565232a0	\N	qRDLkddY0LNggw3	71600454-faad-4ee6-b8a3-0678b9359bb7	t	Asia/Kolkata	\N	1
109	includ3m3	$2a$12$v708hyGYji8BHLBErp4TqOoJNcEK8fZG04gQeEXTQmZAR7fdwekgy	tommy.aung7@gmail.com	196	f	5eca8ddf05e395a94a8db4bc1df887676ebac565730df0849ecd7b43ad8192f4	\N	StjRAzVaaYxgDIl	4c6000e9-95a1-4a51-9982-c6d35a2313ca	t	Asia/Singapore	\N	7
110	Geek	$2a$12$ta4LOzOVQ7J4.4Zf1sxaI.30paYyCX7Wv4LFC03Zm68xebYyYTqJu	rmirzazadeh@gmail.com	98	f	9352e4f32d5386eec7c9d7b8494afea2548d8017d5814f554197b53a08307520	\N	IgVnSJBKOviDoC4	4adce783-0a17-40f3-8f32-1a8797f6faf9	t	Asia/Tehran	\N	2
111	ITB_Dublin	$2a$12$8HZ5VTqRM6J5joKz..YaIuq6.QC6EOMyTJMvd.Ho4HgEAAwHh7a6u	mark.cummins@itb.ie	100	f	0177162af35bfa5a7f20bc793872d83bb926a383302d1e55aff198c15cfabd0a	\N	AwrCSSqMDmUW5ln	02df4f6e-a5ba-4898-a4eb-9a0f4525f997	t	Europe/Dublin	\N	1
112	Pic0wn	$2a$12$F012MBbM7EP3wVqIuK2wDOXMmjtmcdrVM0Guv7gY.UZpkJe8d/w3q	pic0wn@gmx.fr	74	t	124fac302b10ec35b70f8d1a77f8afe7592a22ed712cca74d8e069e01b86d119	\N	2Y1McRL2MvhPUt5	0508400d-91a2-4d55-9ed5-d02414016ee3	t	Europe/Paris	\N	3
113	ForbiddenBITS	$2a$12$qj3xLw9xLu2JaJ4L9tpc1.NJ5y5veBAabadbA8LpPD1fR2U4Sx1BG	forbiddenbits@gmail.com	1	f	310f51c8ad8f02870e73b45e4417c6541cbe009d9c72e6895411c0fdbb7a93b6	\N	Om5G6fsx1AFBFDD	eb3b7648-3121-48dd-b526-7a24c182f9ba	t	UTC	\N	6
114	elzi4n	$2a$12$9tR5Oia8E5qtoqdcRERpiOpVfz/g9Iii6PIuk6./yEclBWYoSLE/u	elzi4n.sec@gmail.com	74	f	e3e09f7dd160e38780b2735b43105619d36ef26db2c700687e81a65b68d5588a	\N	Yw1U8tSiCF7ZzY4	72d46bf7-3bc8-433f-979d-43bce0483b88	t	Europe/Paris	\N	1
115	Stand Alone Complex	$2a$12$UM0XTeGazzglT3FYS2Kg4.gFzH7LoQURYFIzm0vNBMSA5Ao8eCHPu	uni.bonn.sac@gmail.com	79	f	a2aab10a64cab3a1d25cf200e7a239bdacb718286f1c15ed0acb2cc9427e1ae4	\N	0Dl9Lmo4yZJO3to	53f512e7-641c-4715-8a32-31c1d268b692	t	Europe/Berlin	\N	10
116	C9H13N	$2a$12$pnfFAJoFmjuMBxnCip.onug6PF2Du4jzGwEN8ZqgWWJTMp0TncyZu	mattias@gotroot.eu	210	f	af3825e30982a80a1d2cd775f0138f346da83a98038c1dab1f6d72a9553298d8	\N	z17DvBXJjYzd58P	6260431d-734e-4ddb-b1e2-ca3dedce574d	t	Europe/Stockholm	\N	2
117	Caspian	$2a$12$jBxLMZSDQ7onQ7Lo7xtv5O0qVJ09hI.3mB3J0Y7AyXuOQRrhqLmZ6	caspian.ctf@gmail.com	98	f	8002ef1d69f55c0fe0febdd394cadcf8df91fe685e5bc2a3706039e0b6a0fb23	\N	mhcXlHFudXvnsiW	dbc6326b-442d-410d-9995-fc0d20fe2dea	t	Asia/Tehran	\N	3
118	sec0d	$2a$12$2iLufutLahnrwuPa.l.a/ue/HETSCeyd55j2mzksRQP2MaSMdTOWS	kmkz@tuxfamily.org	74	f	8fc445a8d20d9514cb86cff5c8bb89c6fb998e6ddaa73a298509876fa4e6594b	\N	IZcTQx41DLnm0x5	ea8a07dc-258b-4241-aefd-4cb554612d4a	t	Europe/Paris	\N	5
119	Bits For Everyone	$2a$12$VOClZm3XQRl7W34XhuaM1eRcQJqpgZbWgjlYTPOUROzhzBIMO5dvO	jianmin@rainbowsandpwnies.com	231	f	57f1628b87240f94c43a76593202dd21fc229b7a8a6cbda13a9886acf48ae426	\N	DGB5WP5OcM0Eknt	d146dd72-5ebe-4541-9307-89dc58b56aae	t	US/Eastern	\N	16
120	DzGang	$2a$12$lUiU3Ut40Wwpy8Ji0CZIGO1QK6jMgwwexfmb1VQxqt3AyWgquI9hi	islamoc@gmail.com	7	f	521da8a3f06afcc5e82a75833b4baec8edc306812e6a3c6dc0a102a088f37840	\N	QkbYb8lZyPaSKpc	65f155d6-8715-4819-9656-c9b01a3d32b2	t	Africa/Algiers	\N	4
121	Hacknam Style	$2a$12$qVxSCr4Esnh0Rzr0g2Bjx.7Kfmte56OPcLH4UFKFvbIaRDSamFQmK	steven.vanacker@cs.kuleuven.be	25	f	c378dfdbec938bc746cc9d651d0cb7fc72ad7cb890ca01d6a692eeaca504266c	\N	ivj7VRpts8tdTCE	99833bca-558a-4546-98c5-465f30e3a8c3	t	Europe/Brussels	\N	5
122	ltett	$2a$12$knPMrPxF1IRHwtnv82FNVOwnE.TNtjQpt9joqkS5ZMqPaLH/v/3rC	ctf@ltett.lu	124	t	18c4d65f3df8c4df876427e1750fd45a246b5dedd5ab13c97552ac655ac99a7e	\N	HGINVjq0abBV4cp	09c90fa5-b744-435c-bcfb-5956189c0b23	t	Europe/Luxembourg	\N	3
123	stackoholics	$2a$12$6UChOlrOiIt5FwX2nIgMJOwSTlosZf8JJ1epjCrhp6Lxt85RcnqCu	stackoholics@leventepolyak.net	79	f	b47e53c805c0aafe8e0962e468ed9e58c9b236c7ec3c55a896513f06edc91831	\N	FfRfInNmGKkS6CV	c13b31a1-a611-42c4-abc9-9c705893b2f1	t	Europe/Berlin	\N	1
124	CLGT	$2a$12$Maiyjty0sgZi8r/2mtpbj.S/JgxrQ4IosFMA6svzbxQVQypm6ilju	skz0@vnsecurity.net	237	f	0a8c693d07d36d98b4d68e48bb61155e41bf3e8d4d27c7ee9be657818bc7d739	\N	cSQ6PvV9hjoWKsB	f6e3b1de-5c62-4910-8f2b-2496f6d87578	t	Asia/Ho_Chi_Minh	\N	8
125	Can't Sudo Touch This	$2a$12$2x.yBi.OhqxKifLj.jH/Fu1avRU51g.StvhNiIu/owuT2wzCgWPdO	sirapoll@gmail.com	1	f	1ff3e3686e5637386ba4acb97be0c4e1bc67f30d7628b2f870518d08635b3e24	\N	O2ArO8UPMZmVI7A	c76e9fcd-3eab-4d6b-987e-67a5d141a48c	t	Europe/Brussels	\N	2
126	mochigoma	$2a$12$iILYBiMi7eA9I5qMl/z8fuuQjbJkUSOxbPW.Q1bpTneW0oBlXBJza	mochigoma2012@iit.jp	105	f	dd79898ce243916a639fc3d751ea61de1a5676fb20590145872589b00ece1216	\N	frfRIQVrsGMS5Es	32661f62-e73f-4ffc-9dd6-5bfa41bb2ff6	t	Asia/Tokyo	\N	10
127	bit0n	$2a$12$5hiWNrCEZ3aMGKMnE0orJ.B4FvpWZNoU85V1QlzGG3u9C9ZNIsGJe	ufobit0n@gmail.com	178	f	930e5623f2fcbdf5c716b5a28fd446d5e2fcf3bfae1ddffaf0ef42e8336d5f4e	\N	d6K6XLIKIoOA5hy	01094239-9444-479e-82c5-69e2cbecd996	t	Europe/Moscow	\N	\N
128	Tierra de ciegos	$2a$12$/IdOWIxwSXmQNHrdjZ4Fxe8kGo4aDNcb.hdCMjBdJ7dHkYWvSd8vC	iglesiasg@gmail.com	137	f	b77fe96a713c1e10849346e1f83acfcb13c6622baf0b0fda23d1c9c57e18cf9c	\N	mL7P5sgRr4WNqjY	bafce532-71b0-4375-96fe-0d4250035dc4	t	America/Mexico_City	\N	3
129	smoked_bacon_stripes	$2a$12$4TibnbT8ZHDHXxCRnANpbO0YT5Kesw6caLf/t8VaJd80SC0Gmhlr6	smokedbaconstripes@gmail.com	235	f	cf154f25ed9a66e744ac0b7bbf30887af3d1a934d9e02823d494336e1c8843de	\N	2N3lokkAsBnxTVl	b1826088-a54c-4f1d-9563-4ea1067c300d	t	Europe/Vatican	\N	2
130	ViAr	$2a$12$HFtRBo7L8VSGh..riETgOu9jxNo/v2WG.waN5M6uNZ8Qy3A97UGne	bagherbal@gmail.com	98	f	0af6e952fe2f40792b48833e2f2f4cddd19718c910109f0190b998fc8e9a2646	\N	tNahC7JfzBeYRtz	825298e1-fa2e-40dd-93f2-9ad79c5d981b	t	Asia/Tehran	\N	3
131	FluxRookies	$2a$12$l5Mp.6BszRARYZ9onGeof.6blEZHQydMJMvQwhqsZzL.CmsbqU6Fi	fluxfingers@rub.de	79	f	ce4ed64a52b4a5e6f329a999396d72d49b34bd0921fa0e2fc1aab2ac0544cd39	\N	gcLrWKxQiHzzst7	e40eb351-f6ec-44fa-9eb8-5f5d3266586c	t	Europe/Berlin	\N	10
132	team_playerz	$2a$12$pvpBuCd8njx1XLNQ5jxsLetJzGui2te1CWQe8EJATxF1khWkfvjOu	lowroc1975@gmx.de	1	f	52b94621b78104885489e40670c835c5bd3e8e1f2a5ce6bc0f4134fe7befff34	edae79f080e498fd2081bc8e3ed18cce2acef6b3e3c0a87bc96c474597bd1594	XO8dpbmkBhOf6xb	e9ac3e34-8017-4639-9ef7-6cf2cacc61e3	t	UTC	\N	2
133	HighSec	$2a$12$hr0qicFbrlVlHSzLJeQFBe4PDQ5NZSZZDbYb55TwxlWCHy8iXWuZq	eduardo@highsec.es	204	f	bbe642358ebb0b2787423424df31fa13ca0ba3ec7bc8d99bd14795d6bfffea73	\N	8PYp9RL2HFY4tQB	91f7e385-cbeb-440a-ac12-f334c69b2bbd	t	Europe/Madrid	\N	5
134	Magic-Hat	$2a$12$NlHDftXJQLMFGjUVVBRtReUm4nx60VWUNi1fYqBikKk.pGkAsO2dO	ctf.samgtu@gmail.com	178	f	12f22b1fb4600256399b984f9041dea8da5916fce2be4f102775a20a3897019e	\N	9YrRjJ5JgaTudDu	e3cd617d-e7ac-4fbf-8807-a9dd22d0408f	t	Europe/Moscow	\N	8
135	PeakChaos	$2a$12$IBE1NNfo92BcsfWebeiO0e3FskvgAthIPvmdeTy.eAYNUnHqVMXtK	peakchaos@gmail.com	231	f	9c97daa2970621a36ad359a821d2744826ee3d805058d489dffee76c92b4b39b	\N	FbU0AdpGhRxTumo	c50389c3-ac99-4f0b-8cf8-6dd60d86e210	t	America/Denver	\N	25
136	fuffateam	$2a$12$TZiZLyhm1oUIkSrZWREJSe3nEmZ5n14H66MJ2pWEvQExGO5eXqqfG	fuffateam@gmail.com	158	f	d0d1deb77e8709edb81f81cfa6890b0877aafe15c75adad9f8d1943ca218cd00	\N	znRIrJiHIAef4gG	576bbe17-bea9-40ff-9036-c51097350c24	t	Europe/Rome	\N	5
137	polaris	$2a$12$vlzbUAh4OoI7h99VB5G0/ukaCUhRQRhJ0FqQ8FVm8jWP7VmZIa81G	saintlinu+ctf@gmail.com	112	f	d21fa1568b3de12bf7eded1f107216d82b652de8a9e509cc09762fa485e88da4	\N	YGCcFFXK10d9KHq	653594a6-8b82-4648-9b9b-0b5cd25435dd	t	Asia/Seoul	\N	2
138	alcapwn	$2a$12$DIKrhCPWySBt2vwzAD21MO9H2u.7afcZsA36WrFERb/tnKY3W9DYG	ctf@lists.irq0.org	79	f	9f3a84820e8e21ca9b6ae08e606ecf27bd133b3b7550dacaf1ac6b25b150e889	\N	zTXxIeg8pfhCodR	a1074726-9712-4a0f-b9c7-b97b7fa3cb60	t	Europe/Berlin	\N	3
139	CFL Infosec	$2a$12$PNwRV1.Rll0IeOipZ9GICum/B/tcY9A0kS20aumlTw3XfAkuZDpKq	root@info5ec.com	231	f	d4ed11e8ed9749a1c65c75f21c80a3c0ea4f2caa8f5cb08b90db356cf7845500	\N	tQaSd3XLB9fd6JR	09905cf5-7115-442b-9d06-305d57d34402	t	America/New_York	\N	4
140	0x1337	$2a$12$Xjpk.8APa/dMpphyUDTEKuEJAmeD7kYtVMEQ.y63NCPCBOu0p6ydq	samirxallous@gmail.com	222	f	dc4caadf6dcfccea5900fe7194c6e6b56afae8a410efc9eed224df64116a3ca7	\N	qmPWHLpjlxUatNd	de1d2341-c732-40c7-b596-d4081d3f5940	t	Africa/Tunis	\N	8
141	0x8F	$2a$12$mejiNiKspzvJCLVULLFjFe2FOCBSFiRYYCqsmg.kw3dAtpFjoUuRK	captain.0x8f@gmail.com	230	f	00650de22893347946142b705ffcf6553009f13e5f07fbbd05a763f1941a24a6	\N	nxCF4CWbcU9Lysx	c5a3dbae-ffaa-4402-b0c1-04ad63b7ffd9	t	Europe/London	\N	3
142	Shush	$2a$12$ejK//hTWE8iJT48yfKnfBexOit1YR6sJXbHmeEdyEtMbwot2iDpNC	svharris@ucsd.edu	231	f	c97324b731c680edfe80235cf2135c1f010057acfcee4473132c4df14b718379	\N	ZXKABn19jUV9fx0	c429e44e-c02d-44f6-9159-5eec4c0ac770	t	US/Pacific	\N	1
143	NULLify	$2a$12$RssRefvTV6a8GIyF4I.41OvsZ024BNjfmkPC4/0Zuc.tu1omcaddO	x64x6a.nullify@gmail.com	231	f	7c5fe0bfa26550d3c649c6ce935b970199dd5a34dcfb42dcc1e82c4ddb42d9b1	\N	9QuqxqK7h3bLGEE	eda156cc-45c6-4f98-aae8-1d0f1e0518ae	t	US/Central	\N	4
144	Team Tr0n	$2a$12$1xY4IGEKQslBCusldla6gOS9nGpn1zuxZUah1Dyah6WV5PI/p0sJ6	ben.thompson09@gmail.com	231	f	5bd45161cb82d2cfce3799e1345d3442d685a8fc26591280c7544913154c4586	\N	LOhi5ShpRI6HaBC	0a9e84ac-f548-4fa6-8fdb-d75ce59c1d72	f	US/Central	\N	4
145	O	$2a$12$xf3.n.3pwlyDZC5.BP16Au75vQpKbDdYjbvW7iYSbqU/d2jgiHuBa	murphyx@live.nl	151	f	cc84fe2238b129d87de17b6c0a66c821c0e01ec71079cf64185d1282d9272579	\N	d7jwLivB0Ar42hY	222747fb-bd6f-4846-871c-0a319c779187	t	Europe/Amsterdam	\N	1
146	Team Nullspace	$2a$12$UMP3GDroM6SBKVF4YZFHmuVFRGrY5G1PH35MzhjmHofLYi19RB3oW	gleepdc@gmail.com	231	f	7fb6cf80d7af561a1200e47070f3b1ac871f38277302173080f420c6432dbc6e	\N	4wtWIeAKfhxEGeZ	13b43999-7cfc-435f-a7ea-55aba6c37839	t	US/Pacific	\N	6
147	ASIS	$2a$12$912/Bomb0irQZnYR7AOAHeG5GAokh/RN17kzzXLXvycPI5YmvTBaS	awareneo@gmail.com	98	f	aa10edf36ce3ec7155a9c3cb912e51225133b79651d1d38648e7f5878605ab7e	\N	1E6TdcRIdSIkhvq	7ef31e72-a821-462e-8019-0ad7c480c188	t	Asia/Tehran	\N	1
148	unprofessionals	$2a$12$3dXMyew/aunQ/IBTXkSQv.Dag5gU8GwfMn.8ZMBCrTmrTWYNVfToO	anony666@yahoo.com	18	f	1c3e946c8f2f3d5c2b475222bfb65865e5329e246e19e83965656c9de7e060a9	\N	9IudBxpXQvUWrew	ba947213-9427-4843-bfde-32405240b61f	t	Europe/Berlin	\N	1
149	ThunderNerds	$2a$12$mL2/NrXms2ubiBsaCN.Kl.e10bE.kymcjnJuEaLGIfkl94EmYprdm	thunder.n3rd@gmail.com	231	f	5ee7ac10c252f0264052598c19e140535147e3b04733571998c913105fd92689	\N	0iwJSxY4mfDThUC	cd462e53-e992-426a-9e89-e0d382f7e9e6	t	US/Mountain	\N	9
150	Knightsec	$2a$12$OvDVb4S7I99YTgyHLbH5KeQjF1F89vTdLRMXjjQ0JUugf.qsIQez.	ops@hackucf.org	231	f	035693585e31ece7ef685cfbe904057ed64b54fec786844515f948bb4cc7d8d3	\N	WvGU3hYRaNBAxXm	8581b3ff-bd43-4258-b31b-1aef46e9a4f6	t	US/Eastern	\N	12
151	Incision	$2a$12$CSfJDsNhABtFaXvqHgdUXO81CNKFGPl3WfhW01TkopJQ2upZM87Ze	Incision@gmx.com	231	f	7ba702686f057f18f4e80841fc02d91995ce2cd73e6a219329ab5b532deefb0c	\N	K0P8f8UTcjQf0mB	baab2793-0ccc-4c4a-8126-67dd472ef64a	t	America/Denver	\N	1
152	doraemon	$2a$12$erYvoqKBb9DJ.GYM59WKGucw1irilrJcHNeju6D7ivVCP7J3mPqAG	doraemon.sk8ers@gmail.com	196	f	62525bfab8561da1736d543475a42eaacd65e28a4bc5118a74c9cc8c79cd8caf	\N	OVhwkRNYenX7VJw	b48b8a61-c649-4795-988a-491a81a619e4	t	Asia/Singapore	\N	7
153	Batman's Kitchen	$2a$12$KVqBoDZ9mpKtXrYm7Qrace86TFdTtQqpITVU/K03.lDSu9XyD0wN2	secdef@cs.washington.edu	231	f	4cd3bd1619fa1e2b4e6ba449a4e864774f4caf2d968b878b0f06cc9f343d1e13	\N	r8JsMXvpQPyFYDB	3da4db86-79dc-44c6-b597-8e01051dc5e7	t	US/Pacific	\N	15
154	NullStack	$2a$12$ZRflhWxM3EYu5HJTYHuNz.r0CPJInYtKXKul73IYyLb2jSGd3rwxS	nullstacksp@gmail.com	204	f	7a3eb66d9e5301a1b80f9801a929c36c7bb93227db5a06585cdddcac587b38df	\N	h6kRJynllmPJniC	cd8814e5-ceb3-426c-8db4-f7cd61e48e85	t	Europe/Madrid	\N	2
155	surctb	$2a$12$TpzR3QpwXU4UFcqRsJxUGeNv3JBiZ.oNgR33BtrmOsIEOkJ2hQdBa	surctb@gmail.com	228	f	e879c2c8cbea0ed92d654b121a83db0387b4c6f1ba88d02a185017b7b260a80d	\N	9KnsUt9dzQETW8V	2a6c7ead-31f2-43b0-9820-f84409b1f8c2	t	Europe/Kiev	\N	5
156	Wheres_my_lunch?	$2a$12$n//UKd6VI0Z6w.91vi3wbuXzIMZbTygRhn142PhBC/rH/aZhJzhWm	moonaguy@gmail.com	230	f	4bbd94bc0a093cb22271069460b68a36846fa7426fd27770531a03135fc01b25	\N	xTPJr7VUyg6xupe	2f1123d9-e2c2-43b2-bd96-f1b21e3e06f9	t	GMT	\N	3
157	PUMA	$2a$12$Dt7OojcQtNnEYVSnGUI6VePoNDpGwhUlfjNfws7/BKEnP2v5otcLO	gomer1700@gmail.com	178	f	915b64dd918c31823f4008c2829692757495eb41e17451fb2e9b4fa97f477380	\N	9pj2Q1SegVLQHqD	77f142a2-ce69-419e-9716-7612b52bb7ae	t	Europe/Samara	\N	10
158	rand(4)	$2a$12$17TeyNB7iAB/.VYokyFPrOiIIF7ETEc6hfGKvooqMNBl9xJTlnj3O	ctftime@wrl.co.za	202	f	889fe48b094e2cae36005d588d602bb1463dbe3c7080fccfe72a63a206ea7cf1	\N	ulWT4dlT4c0aNTp	11f952e9-894f-4b33-9ea2-add54b5be97c	t	Africa/Johannesburg	\N	3
159	girav	$2a$12$KmDUjGLeKtFqoimyXBQRHuZ9omMa4YY3V71LnJdSzKjTVX9Ubocr2	giravctf@gmail.com	178	f	e969847f7026fe11b50fce5efa77136075491cfa6910d9c79f3f981c2af6bf94	\N	4VcK2oDxWAmR1iw	d1e6efa4-0fe7-4fb7-9be4-e05a717f7b0f	t	Europe/Moscow	\N	5
160	BungaloveCrew	$2a$12$OpEi2CNi6SwNXigInOoLgeQkLAmuHTEb4rqjK2Ytpsp0Fdrd7gu2K	lu.k.philippe@gmail.com	74	f	5b01045d1a03b2e355b093649ad6e67e210f590c47acbdd4b6873cc3e32aac29	\N	HDcGg94BkG2Eo3X	506ff985-389f-4c5e-b8b7-8df71e1f23be	t	Europe/Paris	\N	5
161	Peterpen	$2a$12$rsDP/AjntAIaq2ceIpkM8uAMBJve.cCfj2VjpL4eXwz1eT74POAE2	awengar@gmail.com	178	f	4fbcd0fc3a99188d62c2ced122f7bad63d56dbb1a64ff3343249fb711b584f9c	\N	ooPaSnghoXJWH9h	3c4b9b24-13a4-46e8-b5b2-38532024adfd	t	Europe/Moscow	\N	8
162	GingerAllen	$2a$12$hc9eNeGU10vUr.r0BhNX5O75C1TRGTM2GFudLCUgcHcfQb4aXiq3G	tb1446@nyu.edu	231	f	21b97feebce418c9198ac895e9acde83ee1cc385af9bd76fd5ce7237991fdd98	\N	Y2NwgyFVkgXYV4F	c67b00ce-3cab-4f95-95cb-1fdfb51a861d	t	US/Eastern	\N	2
163	grustny_team	$2a$12$WCKD6rxjuqAK4JFnw74IGOka/JVLKAtl4BjzW7pMJfsJuHCErD9ca	grustnyyy@gmail.com	178	f	0137d0dda9f26b794cbfce041943574f228cc05005a3ebe097d33ee745e8e190	\N	1uDHRT5eBqLK1na	f3d9ed93-533f-4754-9e9b-5b0c1fdcf581	t	Europe/Moscow	\N	1
164	EpsilonDelta	$2a$12$o/fspdIJ0zK.SfrME69tieeIh5fVt2TSiZOaWFLGNZUsBaO3UlMgm	hiromu1996@gmail.com	105	f	6767588da195fba7f7d856740c7fccce7b7752c4bf6441c8d2a444a0fe3f5f98	\N	FRB2NKzlWZPREck	bc429408-316d-4504-a38c-33502c82c848	t	Asia/Tokyo	\N	4
165	UTACSEC	$2a$12$ryNUIfh5UtgPktUKW7CvI.m6FHANFFiXRMbPr.Fc2kM/JVMRHCWXG	utacsec@gmail.com	231	f	5a7387be46f062c818a35c9d1c0198a1b30b7eb183e05da052daadfb43758f6c	\N	e2S5UdvLYAC4okT	baed5042-7734-4b19-a58b-aa26609e742e	t	America/Chicago	\N	8
166	1tchy	$2a$12$rQSIypmgaYVaQyu.X0KW2e3YTc8siPl1bwGE8qrU.us/HZy26ZgUK	realitchy@gmail.com	112	f	a80771816d71a1ca84331192c087e6ee03347b06484e026107223bfeb48d515b	\N	I01gkMbAqEQs59k	bf5e0e27-be49-40df-9e5e-0568630360e6	t	Asia/Tokyo	\N	1
167	Team Edward	$2a$12$Ra6rVBMUrTIuq/Ob4VKajemvw4ks5gtWUiT9bpyrI1BiAcn9Y0df2	edjekyll@mail.com	231	f	815d1ef2308ee511d14f0058689bcd5112bb099730a60ee039849f2dd02d608f	\N	qF4fXi3R5XPvxzk	ec1fb3f3-ad50-4ba6-bf3b-dfd395417f37	t	America/New_York	\N	1
168	Entr0pia	$2a$12$BnSQhFny9wjXACgFEGwBdubEs4zRxSdifV3RNIinh8zK6r49/G3dO	vlex@inbox.ru	178	f	dff032b6e539593c3487e7afa8d2101bf895e0ceb567e093a9a2f23f44c4b29e	\N	YVVC6RZzok4107V	85b73c9f-b6dd-4ff5-ab79-ad03d1564b49	t	Europe/Moscow	\N	4
169	sdss.pro	$2a$12$ynOQw9yEXf.TGQulktPKzucJ6cO.uHi8L/nZH0ZoCqmNU.FfNCA2S	wmkmail27@hotmail.com	178	f	257a3073b212fb9a3711db9465bd9f04e0038e32fc1bdc14ab0002ebd158bcf6	\N	xeMTbuMi8HUe4EB	fafaecf0-080b-4114-b756-6531b65a0ae1	t	Europe/Moscow	\N	1
170	lazydaemons	$2a$12$DPrtETaDMtx.TVAXfxHG0O8I0L05NVzWPVomFN.YT6M9ZgdZeJJbG	robkill@gmx.net	79	f	035dc9bb3d5a56664c023f078cef41f0859cf712b1e97cd51543194272df97cf	\N	thIyGaRpE8miLff	df519bba-2fa3-4a22-a1db-8f6bb01b3a85	t	Europe/Berlin	\N	1
171	Disgrace	$2a$12$IvOHijJy112rGyuo5pmvDOm9FXA/.X8HRGJMYIa0pGcsJ49/JmBvS	disgrace.infosec@gmail.com	74	f	c98f8441e05f5c6920acaa67c155ebafdef8b20a508e409b79bcfb46cf8dab6d	\N	JHPf2HpYjXN3LGj	94ce95a7-74db-49b1-8186-b7087841411c	t	Europe/Paris	\N	5
172	509	$2a$12$OYos3sIRUFvYrdA97aEzwuVm0X6QhBuU/NEQ6JPrTFOsnHOMILioy	ctfteaser@gmail.com	237	f	a3d6ee94a29a6951009676c91b3729250263bd8fd62f3a8b40cf04821d771c4c	\N	ZjbLRpLSqa3e80q	753a355f-d5f9-4f3b-be97-f0ae7281de28	t	Asia/Ho_Chi_Minh	\N	10
173	Noobs4Win	$2a$12$pqjT8e6LBBCBlU96jgHxJuKUqKdBSxfdqBqgz2O0rwLS3ZVrioOB2	noobs4win@yandex.ru	178	f	9726f990b3c126252d978d75a6f670ec2ee73b665afb1b61d88a058befe8aef1	\N	vaCk85CHMWoRbCM	5d24d52b-dda8-4424-9bf4-67588057291a	t	Europe/Moscow	\N	1
174	backzogtum	$2a$12$.i91LPSat82R5u12MWHWSu2ErmS5ox7mk49EiQs7xJfg28XgK1sKy	mischa@mmisc.de	79	f	ed8924e55813a800781abcf392868a94c6e6d134a7cdcfafed0bfdfbc3980be7	\N	c0lpYK93FaJq0ro	27577972-6d04-48f3-ad78-cc5d17e868b2	t	Europe/Berlin	\N	3
175	The one	$2a$12$TRK1psjddqtvi2MhMnfOfOh5VSWaRzx.ovCylrcXigRS2bDtmxCTu	kostya0071@gmail.ru	178	f	9802635e376878ac3df51740ba0da87e34ad8f5e5ee4e178933ce8414b5406ab	\N	XrgW7u5szxE0YzA	e6c01b44-6bc6-4aba-b2a3-48d7898a3f0e	f	Europe/Moscow	\N	4
176	The one team	$2a$12$fDzRiyju9ZZWFjgIPEzDg.T2FA9ufmtNhafLUTE2ZjPIl9VEzMoMe	kostya0071@gmail.com	178	f	3ead0abd3ff2f0defbf9c820e3d0d1283bdcd9e6f9dbb4e127b503a5db391868	\N	hZKx7voXyyii3QM	d1da9d2d-4b45-4f5b-8c70-d394ccbf2327	t	Europe/Moscow	\N	4
177	Mogul	$2a$12$gCSp.20kpWMo25Mc0ulTQeeqGAh1duL0mdfydd6sj2tGYjB00lRnC	mogul.team@yahoo.com	141	f	2ea7a170bbf081665ef0d3c02116412168428266da073cc00da4af93bacbf7c9	\N	ljh0r1XPvMMAyRJ	fadc70bf-b6d4-4821-98f2-a43b1abb89de	t	Asia/Ulaanbaatar	\N	4
178	lemur.aegis	$2a$12$klQLKqHTY.foYbCIS3l9puq7qTX0yY/5G.aKxIvjXG/BMW.2Z5rzS	lemur.aegis@gmail.com	96	f	b0723bad5ad5791d39b79321b4072dad6ef90bfb451aeeb1d889150669ae1c48	\N	40yPH0bZVnsFIVh	ca905f47-fe33-486c-8b63-b7753922aadd	t	Asia/Kolkata	\N	3
179	ECX Inc. 	$2a$12$6FZiXQGeYCg7e9fa7GZJe.2cy8gNhh8y0H3Y83wqjuCno5nyQUVaC	ecxinc@rocco.io	231	f	7e220cdcfcf4ede17d06f9efd54540fe32dddfb696f64490c9dfd5b8af47568d	\N	DeqgXfANDiThoNx	0f9082fe-8f18-467e-a0f6-7f2a9e07c9c2	t	America/Detroit	\N	4
180	PPP	$2a$12$gUhSGLSY3m3O6WsZD4lj0.Val6wNACay0Kaz7GU72NVEOKJmz9ZsO	plaid.parliament.of.pwning@gmail.com	231	f	dfb01898332d347171a92294ae9d9d0ae54667d4ba2da0c411da07d7eb0daab2	\N	QYtlqe6KzHZP8O8	46298c83-af5e-41e6-9037-52248e0ce58e	t	America/New_York	\N	8
181	cr4ck3r	$2a$12$KIHqBklBEvYhYw6lBoXDMufeF43b83VYabHOxYCsF3FOaSxqw5NVy	karl420smith@gmail.com	96	f	42933558d998d756aee58bac34aa244a952ed565783943bf7f568ccce92d02ba	\N	ePYIomfUEku3MCO	658f0dc8-8733-4a2f-aa38-58ded8deb299	f	UTC	\N	1
182	g0bl	$2a$12$beWd3HnergX0V.79/o617O5S.V98BOnLL6DXm9Nw7XZofujtCx08W	byobyo@zoho.com	231	f	7f1e897c3e4f43603153b6876a6379496f2d2f39c66261c25bb8618a4758edaa	\N	fHsCOPIqX5dykEV	0319e80a-0bc0-400d-b6fc-49ce36039430	t	US/Mountain	\N	1
183	Vasily	$2a$12$woWIOTBK29cclFICvfdlrebbQC1H.T9oM/heR.4OPzwxLRLhrP0N6	alxchk@gmail.com	228	f	cb1e847455097e4c0ec372664920d9508acc648f3adfdbf94d776717ec14c56f	\N	I4FDfYiXvgIETq1	2709e498-35f6-46df-bb65-1b012e80336a	f	Europe/Kiev	\N	1
184	Glider Swirley	$2a$12$SdG5bYGsQbr/jMck8xAqJu79OagXN2.whUlkUjhk9bWAG1x0V7jKa	gliderswirley@gmail.com	1	f	4c052b30e8fea1e643eaceb2c40e821412a8e6ddc451408814b059c67bcf2841	\N	tJxETwiFeUFLGMV	b293230a-b135-4c57-a4c5-d2797c5dcebc	t	Asia/Kuala_Lumpur	\N	10
185	m4khm4l	$2a$12$qFDGzvD8ZqA8YUosYctj/uNkAJSOdCefZstbw6pzVlVWsGGf0Cpz6	sharifuniversityctf@gmail.com	98	f	c670a267b5a15009967c940ed1f96d98fabb030f7b9e0fac5a23184b6cd4553d	\N	2j0Fw0fJriDyoQt	e6ffdd9a-e9f7-483f-9b36-5a3a58e274f5	t	Asia/Tehran	\N	3
186	Tr0gd0r	$2a$12$6q6kgQ9VhdBgksiR48C9K.mFdES.etxsEVRmsNkktu.ii9go/LrEG	joshua.bundt@gmail.com	231	f	ac76ce99027952e3a005c8fe9cef46813acf41e4454ab97a342cb5996a53fd27	\N	afz3GVYRXxnFole	22d0b1fa-9e61-4332-95f6-8a39ac4cd2da	t	America/Los_Angeles	\N	1
187	dj	$2a$12$PZYIdQIu1lpARhJnuxdzW.yPo1q2niuMSihWNiSPoRpJq7ytvHB4C	a@dou.gl	17	f	e1064576949f2cc34c6146b48a37b8a420ea19eb4b69f116ed816aee84c7996b	\N	ECxiNBtZpfAKVDy	5534ad6c-7f6f-433f-b6fc-55052f25cb58	t	Australia/Sydney	\N	1
188	keva	$2a$12$l.jTlFSI5LkL3W0YMnivPeDfiqj/MEbRwwNqzWCDhiB0Itp8pGeqa	jcd3nt0n@gmail.com	178	f	0d2948e998a2ad6d351568a450ef8a2b0ec80a5e103b8066a93b055224634aa9	\N	J6naBnhQIa7Le7h	9801ae9d-b693-4e05-811e-030f9d3ae5ec	t	Asia/Novosibirsk	\N	10
189	cyberkastike	$2a$12$t5oP.u0fOxScyIkQmj7CzOQ4ljhz7Wrb1b6ALesXY7qsuozg8iZ9K	akos.pasztory@gmail.com	73	f	a805178c4fde9d3bad19dcb0cfeaa50f665bd162a0ed500c551e4a6dcf3ac748	\N	WitxAxOfFFu2vvr	3b276f56-994c-4c4c-9c24-807cd5d3e373	t	Europe/Helsinki	\N	4
190	wasamusume	$2a$12$C8JKUd/6fzk0vZ5lxGEz7uF7hWqDH7tn1SpsWClZjZJKYAQq8lKWW	ctf@falcon071011.com	105	f	de3e5a2bff06548d68fdcb9d2d2a1c61d118716718340dd33c1332933f65f777	\N	gEXyisvodMmtxRL	42294d7d-1d14-4028-9100-335c1ba4a4be	t	Asia/Tokyo	\N	7
191	SiBears	$2a$12$QpfYTSkP.rSaBkq4ni2nfeAtRUFGnwxU1p5vI/o05De5P.r/QRWyS	p.y.sviridov@gmail.com	178	f	2c8ea28e9023a778ee6926364526b2b3b4599b4a6132af037e5c93dc683e8ea7	\N	jG1x43wOSgYvgww	ab0e5467-cefb-4657-b3bd-06ae3105fbdf	t	Asia/Novosibirsk	\N	10
192	w0pr	$2a$12$K/P.lsNMLILyo28qKfHrOunCD2abqr9uu.SAo80alDAkLh4z9Cj.q	team@w0pr.net	204	f	656d048565a5ee437a643e2caf521cd58eec951c7d75505eff7017906bf8b2ec	\N	U2Ef8ryReADUBgN	cf0c79ca-f23a-4f13-962d-96bf50aaecba	t	Europe/Madrid	\N	7
193	ba111b00	$2a$12$ThxDCp3gwYgBWUo3bLcWNurLivO5d4rnjhVO6/ZmKb9e2DzkMVPhq	suto@vnsecurity.net	237	f	cdc6c1c25f4d833ac014a6a4744770d9b34793fac78b75885d715dd709743b9c	\N	Tid65TOr2sao6sl	f7368c9c-5ecc-4609-84cb-56154c00c4ea	t	UTC	\N	4
194	coolcool	$2a$12$AYbF77bMYtriw3bAuK1Se.gdvA/BYWE80Zbb1zstXZdAILp.m68IW	coolcool@coolmail.com	19	f	539ff1901ca16d5e5ca93763d0a5e779b6fd3452e68d1d2bd951ca4f5faf026e	\N	sTyfcglVT5qD1jm	b39b67ea-b766-4399-8b87-a4cfa6e89c20	f	Africa/Dakar	\N	127
195	coolacool	$2a$12$dA9KQxGcnZypMTzuwJSxc.uHj8lm0F4uQ2dvyWZUDocxSJmcg1Jy.	coolacool@coolmail.com	10	f	fa898bcd967da4ae63a71147e0651a50a7618b3aa92ffd9e93f732855fe903d7	\N	D8WTAkJRnNAf0n9	f44975e2-a6ca-476a-a18e-68d9bc8ce17c	f	Africa/Bissau	\N	7
196	coolbcool	$2a$12$UWxVdy0aT2PTjaGGDP9yse49B1IDghkSqVbXjK9Q98Q7qsdXBfXiG	coolbcool@coolmail.com	6	f	4bee29729ececea420685f70d29874c1e7656dd2d4ce2f70b1a45670540c5872	\N	mKb3LrYkXqmVRLF	1f6ecdd2-4c59-4034-8709-c72cc7ddac56	f	Africa/Accra	\N	6
197	itbank	$2a$12$Qi4mc8rJF9N/cxdOmjZvMeFo8.dKCcpJr/BUa.tmXOsZe7eTZo5hO	kdj2438@nate.com	112	f	e8b21ba9b8089e63804055a5808dce46ad7ae958c022abae054110060f15c8dc	\N	bh7a3fymktKOzzf	685f8e5d-a797-4cdd-a0ce-17d55c2a4220	t	Asia/Seoul	\N	10
198	hazard	$2a$12$pbedTUiWWtJzsBTDkkha1etXfShMXk2HC/sA7ZKJ6apHRlqhoUAIC	tsugumo2004@gmail.com	173	f	87db02742d158ae3295159235f8303bca7ef32e63294b978c072267c8a6d6836	\N	s5KifQf9IRZCFxA	6b820cca-749c-4359-b549-62252f8e7263	t	Europe/Warsaw	\N	1
199	g0at	$2a$12$95D2WriyDf42iE/ReRNtGuU9OAgigutFs1Y5/0X/3Hwj2R9kUejpW	gameredan@gmail.com	1	f	d7cfcbceb05c1a65f1f57b4e4740521f3071eabf808ac7a516fcdf68be0c13b8	\N	cvrIxlSvvwGNKEL	1cddfbfc-8bca-4efe-9a2c-762d79b19ca8	t	UTC	\N	1
200	Flaming Trolls	$2a$12$JVpyN.AXJ6OPTQB7C7u6YOhHSyTrM7DCtgwkjtao3Sep/Geuy2PtS	poprostuimienazwisko@gmail.com	173	f	e37e8d1332f5d1c689247d7a6417c6a6fe7d93f9124db9dc539d3da9de70be0f	\N	nVHLMYYana2Gxll	39607d1b-10eb-49fe-845c-ea0ac76bebd9	t	Europe/Warsaw	\N	4
201	Akatuski	$2a$12$eLh5FPgrgAJ51B1ZQoyWuOuTMcKwiU8oy.hETtwmgf09Pes6SWMWC	ganji.kiran99@gmail.com	96	f	b6792223b12fd6886fa65ced1b171128b7f06f3fbcf6d65ee77f428b51366e14	\N	SoWJTYQE6rEDRYz	e90a9fbc-f986-411c-a8f0-0d34fdeb2a31	t	Asia/Kolkata	\N	1
202	sec.se	$2a$12$mPiNr59FB0HMaVWgeAQpJuDdZS5aEzxVklSOEteHU8nnXx4ZZTP0i	gilles.se@xn6.org	1	f	db15b89e816cb447cd5b78ead19b7bf62fdb65c4370a3b2dd1000a75a70a2885	\N	R49ICMV9Oh2FJIH	2c445f31-5343-4ad7-982c-f2d5b5d81405	t	UTC	\N	5
203	The DHARMA Initiative	$2a$12$Ra/enFfsqon3vDz0bCk2Z.NZ.Hk8cM/lRV2gq9sKlFZ7bVgLGWqP6	WnH238Npw43456x@yopmail.com	204	f	f32d03bd5a23ed6c9da233365dacf0a523349cb334d90a94140b7076b9cda9b1	\N	XJTaiMEteAcvKZF	3c7be988-dd4b-47d4-9599-3b86308b1d92	t	Europe/Madrid	\N	1
204	Vata	$2a$12$5xqfv/8T0jIHbcDd4bgnluRT9qqGPAk/NXaPq9Rrd1z6VhMxmx96m	dniwe.12@yandex.ru	178	f	544216a086dcc14b7b21d9d610072d422f4669f7f9089cdeea73e3e479b12f2b	\N	UEBPsPUmQYlTaqq	63fd258d-b263-4dc1-a4d6-cc86168c140f	t	Europe/Moscow	\N	3
205	secse	$2a$12$1wT6BLHoBc3DZVKlAqJvnuKpD6pvf.gWRxbN74huMs1FgY2J7hzAm	terrycwk1994@gmail.com	196	f	c2e7951812991c7d6de4afddba4f15609ee515f901d09bf66a7ae698587d214d	\N	EeobA87e2J9PnOd	6c558955-6b56-4c04-b9ca-718f7bee07cf	t	Asia/Singapore	\N	10
206	OnlyUri	$2a$12$Oxnxnc10WqlFZ5q3mwMpbuzU.71HHIw7TqyoNOZgrEBja614Ef0TG	urif15@gmail.com	102	f	dc8759315962f08e48b7fcf8715666162ec36e95bb3bbccc40b58698c4087bae	\N	rzhtgHtjIp9pAje	bedd89a1-ab00-4128-ba68-ee40ec59ceda	t	Indian/Maldives	\N	1
207	keysec	$2a$12$lzjVuWqBmz9IuwppgBaMW.T4w8gOqdZPEtDhehCsOh44rl2NwGWs.	paf@keysec.fr	74	f	6fb675f87e048105034fd5f520493ea11a82995c639dbf5ad1da034674b60ed6	\N	D0RNAv2WKEuSuVa	d20116be-6ff3-4801-bd06-9c15d73cc36e	t	Europe/Paris	\N	5
208	Cloud To Butt	$2a$12$52iavz9UZcBDfarUD.mE4eqU8ZbM7iLtV/hlcb8BbRSV.vLX2.FGW	willblew@gmail.com	231	f	c8211d1345cc74e76b30152ff10edd9efab779e9132ac132b6296f56d93d3159	\N	DdgRpHxb4J9gc7G	766e2098-9146-4e57-afe6-d2f6f176cc5f	t	America/Detroit	\N	5
209	lol_It's_a_CTF	$2a$12$AAz.O.S7S5QgoAgVqNX0zuMmOyewGBm/80CRxKw0PUGWfeW/O1992	shikhar38@gmail.com	96	f	d797e500d6d5adb771a6db348e01f3e3ef5834dcf95c2dde9594895afda7d558	\N	P4OvYXkY4vLBF41	2178f5ef-7ecf-493d-afaa-864e492abc7d	t	Asia/Kolkata	\N	4
210	Man In The Poison	$2a$12$.er4h/045.o8SFHI1zXvfO6q9E9zGX6NjoQmzQV.wZUZaCqR650vW	team.mitp@gmail.com	1	f	0cc5ad3f92a5b3368b8b1873ae1c5fb2f17c9621893418e85afc2e0debba5e0a	\N	BPQegl4xBWSSdql	1b917029-30e3-40d3-beae-6fe0ddcd7276	t	Africa/Tunis	\N	5
211	MMA	$2a$12$XLUqK8VADWq5dV.RSHPBAuDcGnWKQyfKmMHaxqJml.ablqyp6SsmC	ctf@mma.club.uec.ac.jp	105	f	3fa1590107e24ed3e2573aebb2ccb902184d75c7a0bb3920d00599b9562822d2	\N	hcUhmDA0pW9FL61	8bf6714a-ef92-462f-b624-79ad7a8d44ef	t	Asia/Tokyo	\N	4
212	aaz0z000000000000	$2a$12$vfsX8sPlzlbBUZjCrDlQweFMk53XU2YGYCBVJXDKQu.gmISG7A5rK	a@m00.com	11	f	2b7ac40a1807b26223400ea52282dfff4938d2dc1a39cb53d1e41c97498e3e82	\N	TDqHUSMvV3WJWT8	0ecb16aa-b19a-4b26-a096-e7eefc2057d6	f	Africa/Banjul	\N	12
213	m000	$2a$12$8kM/iiaVfnOBXZps/M5CA.XDyniV2Xf0x.YEIgR6p1a4kxNtziKqW	b546831@drdrb.com	11	f	34d3d68ecd080998d18b002dc3993ebd275bab901a5db0841438e1a217a6f797	\N	OV70EQcyc7GtVkq	095e12f0-188c-4123-8190-af389c18a49e	t	Africa/Brazzaville	\N	12
214	anonymous	$2a$12$K6G5xV.9j2pOg2n4isHPUeCvFoXcr2AXvQ/ia7aGzJT77HF6M9j2G	rishabh.92m@gmail.com	96	f	305c04284a84a9fd1fbe57d1d3ca4741c3688a3b00aefaf25d4de3688c3ce5c1	\N	c9USj3GYelZemDl	e4b5bfad-494d-4ce6-960a-02b2b8da6654	t	Asia/Kolkata	\N	1
215	Dystopian Knights	$2a$12$NJIe2DaEF8uhrxyaErmtMOi84PtZK/9tr/R6kp7/DrKgC5INxK3wK	dynadolos@dystopian-knights.org	196	f	c1fec2fec8251effdb5835a90323e7327b963ab85d43854ee6034721108178ed	\N	6Fva8APxf5DpAdm	7b711eda-87fe-4826-9f00-07ff9e9064b7	t	Asia/Singapore	\N	2
216	IndianCyberArmy	$2a$12$8C2s7LwVwbOQVrVwtOQU7ObpX/UB8JBuQF.uQl3BuPif3E9ChzAv6	republicofbhatt@gmail.com	96	f	1453de0e2fcee502c9feae4dec186c3371f7019b0163aabe9513b2e9eb4e6638	\N	OcrojwgQl42eNjG	27997e26-6153-4236-a9ce-4e557ac19660	f	Asia/Kolkata	\N	3
217	JollyJackson	$2a$12$0oYTHvqpF3qYwO.7RiaJtu93HZfDirLS5HAOtmkC0WIXG9nR4NH6S	magnus@maggz.nl	162	f	1c9ec5c18dac3f5fea04f90808061bdecc592411afa93a22945821b072a2ad72	\N	e20EjeFUNwKe6D3	9f8051b3-dc3d-490f-a04c-4ab09de87ec5	t	Europe/Oslo	\N	1
218	ADS	$2a$12$YcTu1yZcGy3VCU4rSaqbf.qHlnjbXdnTPN6O7visKKatJhxbWxD6q	adhisingla94@gmail.com	96	f	8afebd8f3f49428fa0f711cdba2d54c346f828e181a401f7dc9237ce2b6f0a8f	\N	sj3CBmFeJ9iNn2N	10be7dd6-4746-4845-ad2d-2a7a2f9f7ad9	t	Asia/Kolkata	\N	1
219	Nightingale	$2a$12$TQ/g9J1T9CwId1nELsehZet/NfkLUHYhGFjTU6JMwLafFyR6lBKi6	ali13691989@yahoo.com	98	f	d6e4102079561e11164daa5add01ceb811a185f8fd2395bcc79cd158b6c330f3	\N	bckzZS5alTWLHjb	a24bc505-5801-4654-b024-56328467a6be	t	Asia/Tehran	\N	3
220	kapa	$2a$12$PMHuDp3HoUrMyd2RLTU0kOV.nUXdqNo93pazE8ZUR5DKKzMfKAOfO	rahiko2td@gmail.com	112	f	fca5585b196c594782d7322a5edac77ec193b7d3c4c422021954dfa3f8f6f9de	\N	AmT3vbibz7NFAov	47cbd1e7-0ca5-4a65-b040-faaceeb314bc	t	Asia/Seoul	\N	1
221	lamer	$2a$12$0uAYpKr2AVzYL8oLbFwvnOzf.llwzQDI5p.I/OYCC/yAfc.Shz.ma	amir.mizer@gmail.com	98	f	bb6271b284a1e3bfec503330aa219f9d932fda9289bd686d9ad149778d2c7a32	\N	LtZcA6qC4RLWk94	97e7fd04-c338-4fe9-b17b-9769ec705bb6	t	Asia/Tehran	\N	2
222	Zed	$2a$12$kSJZTE5D3lJSaGl16724herQFyfxd6B0gHmsgowUvNtUXr7frEN1W	ir.cyberspace@gmail.com	98	f	55a8e177aafb7400734796ccd34f92b66803a723bf79cbbf60bff027b8f9d204	\N	tdBGcvjfJFuojYQ	1cf62729-6cd1-4137-8c7b-cec177b78447	t	Asia/Tehran	\N	2
223	test	$2a$12$ntFjf9ElDWyZ5j7QYFla2.xu5bEGT9EBcRPr8jxMgw2dc03I2JkSy	mrbesharat@yahoo.com	98	f	0eba08f63638beb127d19e899affb36f775e9a2cf58e0210483f5c0a0b858aca	\N	HCvWPpg9yF2ATwd	7f487171-3d0f-4b01-b367-a7f21c6652fa	t	Asia/Tehran	\N	10
224	9447	$2a$12$7J/ASWeytE9jHUHECF3Avupf7o3ghspf44R.3l58e3j5ah5WNgqna	9447@epochfail.com	17	f	a0d877022efc95e18ae1330f61a01c6ecd7f13f686ab7f27ba47e63336a161d4	\N	qYCPUuEO9g9id5Z	2906405c-b877-40fe-834c-e9b4f06b04f0	t	Australia/Sydney	\N	6
225	cyb	$2a$12$zE0PnwsuhWd6Y8h3LeYbW.QowazVQrOR1CuKO2EQwX8p0gpTmNcsu	team_cyb@trash-mail.com	79	f	8cdb7eafa581630864fc8b20e667e0118d0293f7891adabba13dc82287404575	\N	MV0emoPwsNkVxgx	e5ad19e7-d090-47c2-afab-2d5ede7a3dec	t	Europe/Berlin	\N	1
226	madlife	$2a$12$qw1vfERt1U6F2l31qpmXv.Ob63wrptIGOAVsrelSOa8VOq1G0Wg/C	madman00go@gmail.com	231	f	bdd672714c8e51df53a211189eeae4013958709662203c9a4be26c7d73e04090	\N	3yvy0Sf2AddJpqP	98720217-91a0-44ec-88c2-f02dd2391b6d	t	US/Eastern	\N	2
227	bananer	$2a$12$u8Hy.VK/oTlB..LppQxprOCRDmJqTKLjNDZPXqw.zYCBE0zZsxsKy	ich@philipfrank.de	79	f	7c2d999f8c5f1005dafc19e6a85dde0742abfda89b9b5d2ec662b71f56f55e6c	\N	SJk6BPyMORmqqG8	4a1c07bc-88e9-4551-8183-8747f1d52ad7	t	Europe/Berlin	\N	1
228	bitSpeed	$2a$12$rhlhQs3zegnJZXWX0NFnJeWgNDzVsvA8uUoQC/lBc8YegDgGAuVWm	rconnor6@utk.edu	231	f	f4f7bbc631482d01f2d97c281c751e0b7ebffe865a92cc4fcfe4826b17db5d5c	\N	B18EJRi9jPFj02V	7bc17a25-f21d-4fc2-824b-daa59ccbf81f	t	US/Eastern	\N	1
229	md5(ctf)	$2a$12$VYgpM4ey9.8gBGKKws2tBeNkiUaYzIWLQ1wuOf2pwSVfFvESPD1Sy	ctfs_are_awesome@hmamail.com	231	f	6774841b5942795dc28655fe802bf4705af74472ac93b0be3a0430b89ba493a6	\N	14y2etYQFgqvimO	11be5c4b-b21f-4ae9-970e-c1d58e9db1ca	t	America/Detroit	\N	1
230	AutoBits	$2a$12$Edme8s1ToNw3mK57.gBLUOiEIk.KUOcdGkJnXQ.teqslpwES476ry	6d.6f.6e.73.69@gmail.com	231	f	57afa70b4cf8753176ea6c5d01e9401a8e4f4d4a23b529361a1d3c731cb4d9ed	\N	9I06gO1YPJ2zm1D	ea88c7ca-4fe5-4277-9ba9-c4095dad5b08	t	America/Denver	\N	4
231	cyber sauce	$2a$12$4vSnIrrbp1TcON01Le5YHuAozUkIrGiVoConWpQI6ivOa3RAYlo3O	m8r-pcyxg7@mailinator.com	231	f	f66afefa665b5448ca14f28e62258232a4b76bd8823ef6a12507f38e217e5bc7	\N	QjaadtF9ActlbDf	92115b55-bc00-4ab2-b405-eea96a53e12a	t	US/Eastern	\N	3
232	Pwnladin	$2a$12$An2Bv5MS.THfpOoRZsM27.815wTc6aXxWtYnBLxfN7Pc1o/56GlGe	xelenonz@gmail.com	215	f	4bd886e217c2e33cd421d04c5f7f9ce2d54e65bffdfe4239e79aa958c1ec34dc	\N	mfGl76ir6psYDet	a4b96249-5412-4b9f-adb3-8c389a8b6b7d	t	Asia/Bangkok	\N	3
233	FAUST	$2a$12$7aSS3YZFgCIYP41WlKOlpuTdZql4FyU/KY3jEno1I24UniAmDM3RG	ben.stock@cs.fau.de	79	f	5909f5f86bbc803d711bd8b494b5d8d2d13c0fef8068e1d295006d61f41d315b	\N	KiytBUie2xOoltt	5aa15a09-bcfb-4e3a-9d40-5c115595cee4	t	Europe/Berlin	\N	3
234	Vegan Zombies	$2a$12$x9VHBepFbbYDzlHiz9dwoep3HBxjmBbQGc/DXAUtI7J6NB96.CNVa	sibios@gmail.com	231	f	c53a0350356d1134c298e891945a23b2e122ca9b6b074a705606875a843cdec8	\N	wbBmYvjRs1HUkXc	eb2acc2b-3c1d-4ddb-8829-86b6b5aaad9d	t	America/Los_Angeles	\N	3
235	movsx	$2a$12$hYwz3ouoNSys4hvLoHE.Ee8GhonuHWd8wEGtYmcK1Tgj.pm4LP.2W	movsx@mail.ru	178	f	c40cc1b3c2ce9cc470bb5af0c9a7a4b19a0ea849f571f3174bc1ba459ee3bbb1	\N	V8OQPa38ef5JJ9w	6f75ff1a-1523-42a2-9f7a-579fb45b8566	t	Europe/Moscow	\N	5
236	RabbitNet	$2a$12$OXEF0JGgC9jeJEtq7DHHcuxFtKwTum0MhBxL/VZnkMM0Gb69pG1Ja	foxnet@firemail.de	79	f	74407ab7257f0c4502b54cb47e7bb5072b3ad84de2e2a38664818b905de2d0b4	\N	EEBvOQFU6daJqpF	f1378b3f-6106-4efe-ab8e-39e0447aa38b	t	Europe/Berlin	\N	1
237	srs	$2a$12$Cs4cU7zKWjsNSZnYNy5PIusN1bMwiGIWtIhgc8NVHn62zSZaFINDy	root@srs.epita.fr	74	f	637c5fadd63e378e0e7c0bcee1d81853da946bd5095308ef9b2c2b35451f9501	\N	qSjrafXp2sLXdMv	fc529e0f-8b53-4348-83ff-906ed5581371	t	Europe/Paris	\N	5
238	penthackon	$2a$12$0U4T1tK3JBplv3qwSMpnneteNHeBekQ5I6kkbm4Kpf2/A8B99jOse	penthackon@hushmail.com	1	f	7020634bf202a8b473378bac573585504bd81a13fbc4e2a1a14e8ef9b06401bc	\N	zRLvr1KGKfRZNW9	ae23eeb0-9c81-4bdb-8288-6843dc82b8c4	t	GMT	\N	5
239	Swamp Donkeys	$2a$12$j/cKJx292tiZN95nXqBhSunqom3Mm9OrqSxiONrQDKaOClAjgoSTC	kevinjcannell@gmail.com	231	f	462c757d9be619d26bfe9c4d8d18d029be36ba6b7c9ac52610e67e7b547bf3c7	\N	qnpLm3C5Ku91aiH	ca15d550-c914-4667-a207-99ddf49497e6	t	America/Chicago	\N	7
240	_m00dy_	$2a$12$B3AN6X5WfKLiZX2xazVW0.tps9V/b5pi9jo4OAWWz3JOum5LJ6Sw2	m00dy.public@gmail.com	144	f	adc2f778ae68ff32f47e613d3a919b832b5a654718975d03f7a45f45c4039ab2	\N	OiJaFjCEQVp6mGN	b35c244f-d8ef-40e2-8771-9dfd1863d487	t	UTC	\N	1
241	V	$2a$12$nbWFRrxwQINJ5R73z2EJ/OLTDq5zwfDDuR78M0tk4.HlPxguBa8qa	lsh_kv90@yahoo.com	235	f	94f2e5a62958b5cc42a7aab71d9ea2ffd61d030acb4e89755cd7a81cb51a23d0	\N	YA4VlxlM1u2rqKB	42cb354a-8d9d-402c-94e3-e525226a3825	t	GMT	\N	1
242	yufan	$2a$12$I8xDcjhXq3wQcekD76e9t.LXTAMsUWfLa2oX3wOVWQKWRIh9okLnO	yufanpi@gmail.com	2	f	2b85fd4d299599a5295af75e54491a428a24975eecd9804c9158df564b8bc65d	\N	KPtNfCKrknKOA2p	0a978fdf-0cf5-41e7-be33-50d01d9e1c19	t	Africa/Abidjan	\N	1
243	notsoleet	$2a$12$z05n5gZsQRbI5KraseIUM.wYvBZU3ekX6bA7lwWROcn9.fMCglKD6	aspman@ya.ru	231	f	38d77414c481892b9833b93c51cdebcb92386e4abe332cbaf908da7002229b0b	\N	1v505wCa5jrMgHU	79d5d410-4b73-40b2-b30f-b8967f3c8a8a	t	America/New_York	\N	3
244	Jetztzy	$2a$12$TuHdrtdKpbHWZAaqlc11SOzPKqGqEu2/Ff1wsyDingmVZHcn81aw6	ganzt.cccc@gmail.com	1	f	918645a352613c25152f5b77832b965dab67feab2754d2b870be99e9164d54a7	\N	LfB3SMKvQGxF3w7	61893733-7791-43be-8a21-5e3aa5fbda22	t	Asia/Bangkok	\N	1
245	Non Madden	$2a$12$4ylfBj/tJlgL0wZrebIQK.ABTe.hj/oGMu9xXIwTDqfHoA8BvsTaS	nonmadden@gmail.com	215	f	1f450e48bf154b476fc2aaefd51c63801b81591f75de113d1d26c0e46f2156f1	\N	PS6IBFBtJ1Fan6y	885d97e1-d73e-4d37-a6e3-4c27a2f0a875	t	Asia/Bangkok	\N	1
246	Thufir's Heros	$2a$12$gFSBYizr8Xf/ciEQuVvROOoLltQKIKu0gNnWDZNYnhIRuBGhYsnEu	thufirhowatt@gmail.com	231	f	1553d7e9f423cabd53b311073743c4f5c9933cfa793a4c42655a8465104a9fcf	\N	oTDTCcjOasWQQqK	0c83e4a6-64c8-4a1e-9460-3dc5fd8ea9c4	t	America/New_York	\N	1
247	z00ggee	$2a$12$5Qnds9qxZKIbPj.32Htuq.kfYUDi7rQHo8uJtiGGxPwRQZ1tgNffi	berny84@gmx.net	1	f	299f49a59d5076d8312a00c4c1428b6cc8d26d7fc3090c184f5f58443043c78f	\N	kRRUXt6eEtYhDZI	0ad803e5-db68-4401-b1a2-33c0f077d005	t	Europe/Zurich	\N	1
248	kana531	$2a$12$RlYM4mVUY6Y5HwzbpBrIe.aOi0zdR2LhoDAvRc/7d5O1a7kkoTA2a	dm@kazuno.net	105	f	28a6914470ac4bf54b3c3c46cfd9df9cf8fdd6d43a2f1c6989c5deec9c8da90e	\N	0yTA9IpcnjHW4VV	aecf4300-03db-4f18-acd9-eae6a7895958	t	Asia/Tokyo	\N	2
249	Maverick Hackers	$2a$12$pRDBdqLqzmIbmfEB3pCOMetgIACkyRlnFbmyOSKr.ooVSJuR6O.e2	rahulsathyajit@gmail.com	96	f	2e5142fb7e9f4d91fc4664c8833350a89640c14738a67bff3a9a75adfc305cf1	\N	FC54hcovIYtKInu	3530ff5c-af7f-4a4a-95b2-db5bada506cf	t	Indian/Antananarivo	\N	3
250	veb3r	$2a$12$8/HgCyUfpRcnB43jlwPrIOLV4Zl/9OFAW19MJusVvj4HQRKRkhtlm	uart951@yandex.ru	178	f	e3cc99881cfc40d7e730136ba4559da768f34635a906fdd8900b57051a6a190b	\N	FzytXNdtkxsCNld	808452e5-54a2-4c17-ac73-5b54ea929fed	t	Europe/Moscow	\N	1
251	Fun-loving Criminals	$2a$12$BxR3VwJfGrhZ99c87gy0Sez5DYp0H4SVi0Z19i2wxdvAxFtZjcdv2	andreas.ribbefjord@cartel.se	210	t	dd5a2db6d3df06658dc05c2696129b0f2dd02dc464fa60089ba9f79497b11b58	\N	4P2w6mGdPkq4VMU	b7ea46cc-b03b-41dd-af79-73c213b6fe61	t	Europe/Stockholm	\N	5
252	CodeRed	$2a$12$WMdqrK//PoaITuCn4l2oMu.8S2kHwTdlGDmNhjFTGvUlgPJen.5ku	setuid123@gmail.com	112	f	bc1839a39508a29e481bda86124ac01e9e1aa43d38482039c76de23cd802fee6	\N	RtaxgreQAKXZRzf	4c9ad8c2-3630-4d3c-8b29-89c5eb2b289c	t	Asia/Seoul	\N	30
253	lokistrain	$2a$12$k9MEKrpPebjm2nxf//G.VeU5fN4Y/7b2XZwsNd7/xbkLZSe4Xh9la	rramgattie@live.esu.edu	231	f	c81ab54ba4acac8569c1b953cec3b1d2cf0bcca8e5738125b5537f8283c712a1	\N	3o0bXEGPHWeQbx9	4fe42dde-27e6-450d-95d0-8e6e3ca8a2ae	t	America/New_York	\N	4
254	Magic-Hand	$2a$12$Ak8AtP28c8zlgdNivsJ7kOYRjjxxiBwgci/pZtxMghoPqRTk2VFsm	kluchnikov.miha@mail.ru	178	f	94154a7106e2c1b218382160e12ddb06721a33002f14aaeb56a8e3da35a914be	\N	5PTtSkF1S1SE5bf	ba46c166-0d09-4d28-b4a8-22e991660406	t	Europe/Moscow	\N	1
255	loga	$2a$12$6OL9HmP4TZCMYNGrALzBNeUb2yQdniK65BESNcHN9MJtMpDMrgmrG	logach3@gmail.com	178	f	84fbee0ae4bd5294ce5517a198614b651b3efa50d0916226cc733c13deb17077	\N	vkGbanya5tlJ1PT	96623a40-5575-4bf0-ba06-851e15b67118	t	Europe/Moscow	\N	1
256	poseidon	$2a$12$Qzg2QMt2VCuxRh4TWT/JfuamjVq3uCSk5EuymmSvKSrRkJooMpR6S	sreeram.r86@gmail.com	96	f	66640f2a0e6de3d88dc9e2facb7e7190acb436fe0e5547d6be05e9ccfa7f9cb9	\N	MeVWLj30PrhcYlB	2608970b-59b2-4347-9a94-9c148acd4f43	t	Asia/Kolkata	\N	1
257	0x90.avi	$2a$12$/1nBwJ./ZGJgAjXuXn8INuehmXLJH1OqpClca43ZMmYa0WEvpixX2	tjbecker512@gmail.com	231	f	ebc523f87fa843f4e4fbb624fac404b5c6b73167a0ec3ff4a43840a1425981f1	\N	VnV1WqL3C51EdX5	dcedd97c-57f2-4a87-b106-e0bcac808fbc	t	America/New_York	\N	3
258	Cothan	$2a$12$RrcVT00Kf6o4yr3QjO4Bj.IUxHj1RO78/S7kPSmMgwiCm54uD4QsK	cothanhahaha123@gmail.com	241	f	eb8330c2bc35b3edda2afffc9cd1cb0d9297ba735a24d8047b6ebf64f335f7f1	\N	gykfWIyTpAtMayP	c8852071-f801-47b1-92d6-427bfd74b84a	t	Asia/Ho_Chi_Minh	\N	1
259	MSP	$2a$12$YzeDh4NI4wNQcN8fSaZWu..eUzPOsEWk.3v/51MwTf/Oa6lj77PAi	sebsway@hotmail.com	40	f	1b114dbe8f7dab885e4539a4c4ad9b452d348db1af88afc14eba8cddbd0413a3	\N	GrYykzegIBbpNtc	a3cd1e4f-c738-4784-8f8b-82b49b0c44e4	t	Canada/Eastern	\N	3
260	Cerberus	$2a$12$8YZAX0nNnsfQelO5lEpOKOq8bY0DbAwHpNse8XXd49g51/UWiPXma	nmp@utk.edu	231	f	a4a67893063a7a48f860278f0b05446f7a7e09bd45cc18f85cf0f41cf14da13b	\N	d1nLfSMfmaCTWeB	7cf81806-b209-429a-9892-175f2c9961f8	t	US/Eastern	\N	6
261	Crazy Dealers	$2a$12$Z8yH7d7SL7Nje3QT9bD1l.PdT12TUmZxDqm7lPux4C/BdYCEWMMiG	naile92@hotmail.fr	7	f	6c7d0210e00ce0510e326b5dcaa810a8b8a3ac458dbfa140886dbefeed681d6c	\N	qMOlkW0q2KZkhEq	e2f2182e-2a1d-486f-8544-4cc310e9280e	t	UTC	\N	8
262	KristoZ	$2a$12$lv8rhzXHvLClfWTCTxMGJ.SkOVh46Iq.iG1VhOnpz4c2qKtyToKE.	kristozz@gmail.com	162	f	aaeb48563a9159ed8bc1b8a7c680dd48774d3a8701b96e1dfb766bacc0a9670f	\N	vP3OztkRwdJeGyf	9e9ffb85-65be-42db-afd6-d0a372791000	t	Europe/Oslo	\N	1
263	Kimchi_TwerkBombz	$2a$12$F2Ik7zN8q8OQix5AWXgFXuPDYy255dTGlgrPTwoLPz31X6uN88tQe	kimchi.twerkbombz@gmail.com	1	f	06aa62062fae852e173a6289c756a6a5fc98429b0524b16fb53f13806532af4b	\N	L18ieN8Pii62Adc	4cecf9cd-8757-4de7-bcba-ea77062ec24f	t	UTC	\N	4
264	BobLeBricoleur	$2a$12$MNEFQZ5N7dZkgxnFeIPyIOEqhEz.ebi0zwb1ytoeZDSwMomtfKfSS	l.lengelle@yahoo.fr	101	f	dd5b1050846e2580cc3f061b9bb2c8566944d8f3bf00bc622f41d3934981dd83	\N	er4G02UloJj1mVl	3f52fac2-2a26-4e7d-8a4c-24f642dee13c	t	Europe/Paris	\N	1
265	Securimag	$2a$12$zRGOGdtcsQbg2naSaWH.wuihEt1CJ9r.nQuWVTltECr1U7Hqce3ZG	desplanf@ensimag.fr	74	f	76d3c678b8f2ab8596cc441eec2f456ae6f450a4692ff770fbb44f4a0b46fd74	\N	Qqo2KjirhgKzTz1	5b8dad62-a187-4622-b277-d65d3f1c7391	t	Europe/Paris	\N	7
266	Big-Daddy	$2a$12$y6t63y53K1VJTQCV0yM6eeGUw9zufMs.4sq2fHg4nBbygoCzWfCQW	contact@big-daddy.fr	74	f	1c3d2ebc06cbb619931d5118850014f0a0c1d1ffb0842af315b6c27239f9a181	\N	xE05SNmOd26rDSS	3bbaee60-b5f6-42ec-9516-d848f58ca872	t	Europe/Paris	\N	6
267	Nullis Finibis	$2a$12$vXZS.r1CIUbP8w0O0CcreOpbCeZPvfXPrDNjIVQYbQqdfUCli0jr6	jdkwhitehat@gmail.com	231	f	2524626c41fe6d48d4144e43077ea8719d9dd6337832bd95f26e04efbbc364fc	\N	kBbUiy3aV4hvsHy	513838c0-97d7-4678-b850-3ea13caf36b2	t	America/Chicago	\N	4
268	dev007y	$2a$12$BDUD4pvb3n4Xilxgit/CceP80Erw04Rr0/k8EcFdZ1CAVFLE/JaOK	akhilmm555@yahoo.com	1	f	012a327fd0d6be91d288a3a2b1c7356148a84566e59ea5bb52b543d2ea99271d	\N	5eQAwBAPNXIpKIH	0cab1efe-5920-4623-867f-2171e491cc0e	t	UTC	\N	1
269	Bounty Mutineers	$2a$12$ETjzu4xcuaDeO1vZpwYiuOt8DAdkRlEsopoI/zWRaB3krFRCeSrR.	guenael@jouchet.ca	172	f	05e1c18d4f1197f2d263d7d53702dc92defb62ecd43f2bb76bf3ab230893bcbd	\N	izyb4fgZVMdNbt9	c642fedb-7ee6-4759-b65a-594093ae0aa9	t	Pacific/Pitcairn	\N	1
270	dscuctf	$2a$12$i.zevdUbdqaS64jZqAUBxunrlFS1qNQD.VWyY8CYkfkX.J9Eiwtjq	dkohlbre@cs.ucsd.edu	231	f	b318c7e13a554e3f37c3a0758090dc5ed458cb655251ceaa6adca0d5aad85432	\N	3E39O73v9Ua1TtP	ee09ce0e-a342-4cb9-a7be-19cc604f4768	t	America/Los_Angeles	\N	10
271	Swamp D0nk3ys	$2a$12$2jsnYRSa7497tHaXQLMbau3O33Ac6xeivksIouvLt3lasFe5GvzOW	swampd0nk3ys@gmail.com	1	f	f871513f89544cd7113c00c2351be08c731a89c5838b47acc683e60ebed65b8f	\N	7Y6MM6khRK4wvK1	0fbdd548-9133-4974-b133-82e7e0e64d32	t	America/Chicago	\N	7
272	Fear2Fear	$2a$12$SXVrA78ClAOamNPhiqXOn.Y2f8vyBE47dwM3KMav2veeUubaUV28e	admfear2fear@gmail.com	112	f	2ac29b016e3d1cccf02b17e96a843c9c1bf2550ebb2e871043d6d764411e6bbc	\N	PH7nhQutet40IcE	01c49034-2f18-4557-9865-ab7e67394cec	t	Asia/Seoul	\N	2
273	Pax.Mac Team	$2a$12$BxyEJr6wquQtWiZXe6vXmusRxtCGBXOnoc2UeC6q7D0ueLCTJIc/2	bruisezeng@gmail.com	46	f	b44e123a2f30181d9a19983769b2ea024fd020ca52919c74a77853cdf46b5cbb	73ccb53cc75f912142b374e6586f8e9a81441e8cd00a4654e98e4fde484a6814	NhXeeB2zqHZDvLg	99b538cd-0129-43be-b800-78d08f4e7d84	t	Asia/Hong_Kong	\N	15
274	willtho	$2a$12$gR5PIG6LN.a5P2G5W.ntley8PQQqqdhFt/Goqyo4UJcuiDzyhkT1C	willtho1@umbc.edu	231	f	494b03297203d088b0423d67cd0be2e6b4919e3d6e1ac877d46bcfb3218a45b2	\N	WY7MWOiWxRhtRdd	616f43ad-7b61-4e75-867a-b373d4671801	t	US/Eastern	\N	1
275	PiggyBird	$2a$12$Fhf0R8IFTyGWSQBVmFbvQuBNs8vIsrV0kLBy2TbZmyUMjp7bpuTca	p199y.bird@gmail.com	237	f	495caeb2e47d44ca558e77ca94089011ae8a9a0cf2aec12400d649d46cd330ad	\N	rgxTKEmMeFkHEyp	27735ae1-cc42-452d-a7b4-ebd4f9b320e6	t	Asia/Ho_Chi_Minh	\N	5
276	k3arn3r	$2a$12$zAO7Q80byxrx7lfPkwapGeKmnovOdAi9NqioGHzdcWzN7xWPHPMOG	horfunbeehoon@yahoo.com	112	f	57fe6c75d444d0a1306d2613069814c861360dabcf7a9491f91237fa0ef4f5cd	\N	0fUymvVzlajtMu8	00f706ab-a433-4c24-b044-722d63fe6f23	t	Asia/Seoul	\N	1
277	StJohns	$2a$12$28uEPx0236Xxkkx.DY3Ln.6RPf3OCFXGPzKS07vrItnuq3rvK7jGe	ferdosicc@gmail.com	231	f	3a0df91a30e30ba90f48e2f7b6f2142a4294878012b28cc62d19f05efa57aa26	\N	2q228rn9BBT1ALC	7226bc2b-b7c8-48e5-89e5-63da818de49f	t	America/Chicago	\N	5
278	hyoub9un	$2a$12$QEUpokoBL.0LJV12o49tGemBehRWBLJRXy1pPuZgjOyvZwmj8d3/a	hyoub9un@gmail.com	112	f	5b5a78d28a32d00ae775ad81d045f59cace40d6beee4e0c1cf4a295db502eb56	\N	qOeKSfBNDLiismA	06cc98e0-5d59-4b6b-abda-1eabd40d0fff	t	Asia/Seoul	\N	1
279	0x01E6	$2a$12$pIHdAWrTSzRehi3pmfORxOwogFqXoVEPqcj0x/rznbgaLbGYSm6G2	x01e6x@gmail.com	108	f	5a51f47018261ce1e62d3a95a92970c30e0a22a4a575b5c2e32a710e64f30151	\N	hCIpbA1ASeaaVET	7cb7b8b6-9a2b-491d-9c34-4beecfc889f9	t	Asia/Almaty	\N	1
280	YMHC.gz	$2a$12$m2Iy0l0A5/72Gee.Cqk20.LD/VqTqpI4YQJW9STckcMjvXOxnA0qK	ymhc.gz@gmail.com	105	f	5bcb42a86c76f28089f2f5f259d9e91badf9efd4b8b66ba06a2649552940205e	\N	BH7EGxrEfY3gSS6	0023f817-d313-4bfe-8c2e-9de6a9adbe15	t	Asia/Tokyo	\N	5
281	e26bf7e90a6035	$2a$12$DFTwXKLpdXxegabLqEZOwuEK689wWooWF3jfOV.SikxMR072Ru.gK	RakyaymWeuvTuOt4@163.com	46	f	b6b5c3135d49805747f4113421efe0fa9de8aaa8935b03b376686e7b3e85e7f9	\N	OfcuGnXfg01ihAb	141cbde1-0141-4672-9649-646d7cb4dae3	t	Asia/Chongqing	\N	5
282	NaN	$2a$12$9o5770rs2ZLiaavBsJrRk.g8B8Gjli870G6vKb5a4JIi30f.k0QUW	nopnopgoose@gmail.com	1	f	9006186a3ea2b6658379c3c8c99ae1230be7f53cefd4fa1e0dc85ef0d965cdc0	\N	zkO4Ur3uFdnNrlC	4dda5060-cf0b-4956-a172-c1c929b11543	t	Africa/Johannesburg	\N	3
283	SoloQueue	$2a$12$1e/Bbcr2xYgOFREuG6Pm0.TfXl7lAjeEAsN5.xDRFNVvdxy/X6pkK	awhite.au@gmail.com	17	f	a7b67d741084bf9d37fcc74bf12612d1c61c9b40f39d15244d40a8ad195903d4	\N	J2w1HchkGfuyf9r	50944705-d1ff-42f5-9658-d31f52d2bcd7	t	Australia/Brisbane	\N	1
284	disekt	$2a$12$1sPW3OZt.95HMIlk95qh2eylW0KFNddc4IAJGYxv9hsuV/rxii/We	ctf@disekt.org	231	f	7237da8156442e15b9b2037a513782ac5bbfc86f7c3fdd5098536d8b4e5f9b14	\N	pzMQZXhTQ0oUDQ9	2297337e-e7cd-4ef4-8796-ca466747e85b	t	US/Eastern	\N	4
285	r3b00+	$2a$12$DaEINXr7m7.LNl/wegOab.UGt.Gx9GkBV430zuVcEHRGsvOVk4J.m	cool.nagesh320@gmail.com	96	f	b2c47e39f44674b5abb6d85ee2a2b3c7c8b8df6e83f4ad59704a16dc8f8def45	\N	pnDxQvEQYeDMY1G	155239a1-412e-4d05-801d-0a550fa9ec6b	t	Asia/Kolkata	\N	5
286	Postronic Quadrant	$2a$12$i4mNqsGgdjmUO59xZYJIVearjQvwtdJo8o777lesKOW1B/g7/DBoC	milkytom5@gmail.com	129	f	548fd4961b84f170686fcb902e725ad792d5d8009d3f6efbc31e3a79954cb8cf	\N	UTj8fz67wtdjhno	3f908e3f-d20f-40ac-919e-b98416ab559f	t	Asia/Kuala_Lumpur	\N	5
287	Na`Vi	$2a$12$zKyz2SiI2zGem/rtVOivPe/JUk2TOFsBYiWurBKcpBL6yVxds8MJC	metal.dragonxxx123@gmail.com	237	f	f780729fe580cd88af324adf17765d05050745b5a3175cc0a6be9a4104337fa2	\N	vbJ77zA7E1uK8nT	6cf830a0-0bb2-4769-b7ef-a5374352d272	t	Asia/Ho_Chi_Minh	\N	1
288	hell_fire	$2a$12$Pr3XuWscoAnvK0JIxYPBD.0WIqr39pNCTUrJelWd/x2PL6zf7ALiq	hell_fire64@yahoo.com	98	f	b99ddcede86d668684bc1a4b993019ba975d47d328260c7358d0bb8740d4f74d	\N	WRz6ytohtYD75jf	4dfec4e4-e062-4e3d-abff-8158f5d90af4	t	Asia/Tehran	\N	1
289	Dragon Sector	$2a$12$6J9JqkpUTJDzLoDSHc18BuglLrsYcvQEP.bJcQfRXc.AxIqP7j.Qm	gynvael@coldwind.pl	173	f	a1fe6ecb16da663834ab22743f40cd2bdaf98ffc4301af3ed1ba625890769147	\N	5xMkn9dM1nI9XMB	e696e04e-ce9c-4d4f-9751-b16011bef31c	t	Europe/Zurich	\N	10
290	r00t	$2a$12$/Fv7mL95iJ6dxZ/fMaAe8OszlCFEfsDdpzcdz4s8Syn2fuD7WFctm	adithyanareshbhat@gmail.com	96	f	5b36efca198bc9f62d7ffd35126afa1cf455c9d19c920f7773c8830b73783e8a	\N	YpF2q9j07RRZQ0E	7af76c7a-ae37-4771-9ac6-45ff12247b02	t	Asia/Kolkata	\N	3
291	valengreens	$2a$12$xCi66LFe5Lu02S5MICLCHu8EFTNLPIDbG3FRPnswVqKVZG2qnCFL6	valengreens@gmail.com	105	f	ca624ca0b7bf34b0e20f7881f87f1f9433fcb1b6d34436ab9e3d0b989977ec0f	\N	IWG4zABxXs0yiB7	9bb6b5bc-8a77-410e-8692-53eb98a7be77	t	Asia/Tokyo	\N	2
292	0x01	$2a$12$v9rB7IibtnY5hXJRqvtV8eKuyQ5s.uPL3JT1fueGA1LtqQEx9xE6S	houndberlon@gmail.com	32	f	95ff2e56c58744a488cff30f44320ecb7490fcab95127decc1380596c7735e80	\N	sqomwAvCL8szRvo	bc0197f4-cd25-456a-b8a3-ffa1c38bf326	t	Africa/Dar_es_Salaam	\N	1337
293	H4cktu5	$2a$12$SrLvamI7O4h1HqccEiybKubaElagDODtpR88P1Z.sDnu0lHcMWpk2	arixec@gmail.com	74	f	306efbcb2b26556850d8d1ab30d3a6f7d0b98ac5dc7b7fdf3c64994dc22179d6	\N	7jNnwAHT6nrMRIL	2b7874be-bb89-44b4-9983-527399c3fa1f	t	Europe/Paris	\N	1
294	sutegoma2	$2a$12$yGA/zUSdOY3xJ8yNoyJXWupaXI/vKm6LrwFx8d5i0cZtq/1.QzutW	tessy@avtokyo.org	105	f	b7c881c7be64b571365033b4de8aafbb82a05b9acb90d434483b399dec0a3e3b	\N	SILmkaUFeGhyuEj	de2b20ac-cc0d-4bdb-82be-03c1d147019d	t	Asia/Tokyo	\N	10
295	nobody365	$2a$12$ol3.Y4vLtowHvp7gM8QQN.fIKUlzQimjdId3rMOVTyAckV00twP9S	wykcomputer@163.com	46	f	8c5e9783e3fb0c655614ca776efd93ae523c3689568d5cfd5a50b87cf0203292	\N	4whf7qx73xESnXR	5af65eda-2c00-435c-898e-bda044b21223	t	GMT	\N	1
296	NDI=	$2a$12$Crt4NfMyi2hFbA1uqSTKr.tfiRQD0m6v7ywemD.9mVB3emV6E3etW	hydegood@gmail.com	25	f	f1dff004137ca2a083549bbb9414e958c3ef134c140a6cd2a9a54cddeb3bef16	\N	2HAiBYoU24y7WJ4	5fd18fd4-80e3-4d4e-a7d6-d76f21897c1b	t	Europe/Luxembourg	\N	2
297	bobsleigh	$2a$12$rTwxgCLdLR5kk.WcozYxj.041bayxaAztc5SPbPrdRfDB06BDbpcS	bobsleigh2013@gmail.com	74	t	4491111fd59337e787c7ea676fe5cecd4a43c37b536f5cb24d918f55fa19e364	\N	9wzO4mX6TO3rPkO	80be8710-b526-496d-9bfb-346adf49dd7b	t	Europe/Paris	\N	6
298	decrement++	$2a$12$cEMTiCJzfsDEgSGCTvIrK.ijHJCuZA8iTWOlZp2FglFSnI3ZUhJiK	doyabookpad@googlegroups.com	105	f	5e7e9e00d00b7456db6f1346bc7f19779304ea6cd0ee8281bb3d25385d160232	\N	h4Gi6ZiWnnGvZJE	9bb9b7c9-5d7a-4792-9223-9261e084e6aa	t	Asia/Tokyo	\N	4
299	Team Dresch	$2a$12$sDezfLVPerB7fRx9aRN4YuAdfy/IOQJDh5TI4S69jGsN7zQwe5Rha	sub_bourbon@yahoo.de	79	f	039b6cfdb3fdbfbf60696eeaebf473a1fa7ba771797d99008b1b8973882da6af	\N	ds7nG3uzV20Xmxc	25a7c34d-b639-4acf-81f3-5217a1d3bbe3	t	Europe/Berlin	\N	1
300	LSE	$2a$12$/JzM7iuN3fH9B/xgkUlfReY/xf6A1n5/Y6eenYe9IW49hZkvfVbMy	ctf@lse.epita.fr	74	f	0ceca17f81c84ba7d4294fae68e193f8c81db6c3ab4d256bdd370538a30c5fd1	\N	YWPRFLprPaTATuu	27936c42-a0d4-4451-b224-ee560f2efb7d	t	Europe/Paris	\N	5
301	dodododo	$2a$12$mcybxInWLDtOjm/3.EadBevj.uBqWHyfNe7Mq80U1Pt9w2aLHok1C	t.akiym@gmail.com	105	f	b6e02149a5141f959b7319b588b61a1d081355203990eadee0f6e0ced8a91d72	\N	KmZroDZxYN8pYLy	c4e1a4b7-eeeb-4a00-8e44-90c760f39114	t	Asia/Tokyo	\N	4
302	Rhackers	$2a$12$P4BATjwZRNV.twhIHGZjnOcVytxcjdyAAfI6agpKgojjwzgnuufCu	auspex.net@gmail.com	174	f	ee038ac0f23a36458f16466669149dc4e447e4a2fef4d78282a0fcd8c9887527	\N	7sPhW3S1E7rHQqj	89af7203-10b6-46d9-9580-3cbdb6ec568e	t	Europe/Lisbon	\N	1
303	d1am0nd	$2a$12$UDGFDYHlNRxBbOz6KuGCZuFuexblanTl0W.XuG.9MNV9LYK/vxR0u	d1am0nd@mail.com	98	f	be071a46fa75bea2c89d50b1a3d7dfd14eaa782d9e2ec4b0f9ab8f159b7b5022	\N	klgjFGbEEHdpLu9	e6653ce6-59ef-4d65-a9ea-3265b5d0d0d5	t	Asia/Tehran	\N	1
304	scan.net	$2a$12$jI6pI/f.XmnySUbDuDbdnOj/2fTLU9QECcZ./BcKgrUm/F7VAN.C.	scan.net.info@gmail.com	18	f	2db5a66b96ec3a3d9533fb4da942fd613f9fd4d1edf096ef317f20512513e66d	\N	LoueNNqCVmareE1	56eaa1a2-9b29-4d75-82d0-b3ad9e8c3830	t	Europe/Vienna	\N	3
305	dsns	$2a$12$b/s6IZALK3QEujZ0pydbXOYn890.7PRDlf3dfou0JpIq1EphxZduy	bletchley13@gmail.com	1	f	3412f27df252ae2cab930361f94dc2bb5317efbf217ec90538df9907c5e6a3bd	\N	Q2NhbgZx23Y2Lss	b8da62f7-4d38-4952-8d0e-9b6c0e01e709	t	Asia/Taipei	\N	8
306	TRex	$2a$12$sT6Uza.wUlN9pFohw2zmHer4T.khjKixU20ke74thGt8D3p6rO7m.	sorokinpf@gmail.com	178	f	069fe8e6dd30e29230ea6ca935cac4011f108399266d422b713f8775e4c1f8bb	\N	AwW0DTxNFIwYxjc	b378dbbe-d1ca-4fb3-a68d-2c6e7c14b557	t	Europe/Moscow	\N	5
307	ThreeShadesofBlack	$2a$12$qaIFz5sZvyFHXS8DDSv.wO71YAE3GCIYsDIft7IgpPufx9BI/goru	coffeeblack198@gmail.com	17	f	dc5372dee495902b4ffdcffc90bda42166647d536f1af88297f7f240d6278e5c	\N	GHXRxY0gs3MwxYS	fa07ca61-1d2d-4d3d-8228-cdef25cdcd14	t	Australia/Sydney	\N	1
308	Schrodinger's Nuclear Kittens	$2a$12$b.WU1DLtKuIgi3f9CaFLzOtHBoOyDmRQA3KmTbSaL3f9k4OMmn46G	schrodingersnuclearkittens@gmail.com	178	f	8204b71d48e2e786be745ea4210fd19e84ee8c5f9443b683e61e2552fbf86490	\N	JagigLUSzxk3zPW	0b593745-46fb-483b-80f8-6d9fcff61e01	t	Europe/Moscow	\N	3
309	kknock	$2a$12$rBQUBO52echTonQ5yso/HOKifmAkmf6ylOqk0gAXSNJzqEZXqVmRe	jsh0801@nate.com	112	f	a2882bc2ef1c7a171183f0bb8c10d7527a0344d955638ce4c739a66d5dd01fd8	\N	CGMl3IpSMWfzKZL	b743fac7-f502-4a05-97b4-cc0aae2b4b30	t	Asia/Seoul	\N	10
310	angel_killah	$2a$12$K9nPVcFBrHiCo4/37eOgZ.yJaCBqu/OqfGOJQcYeMR8gN968DDd12	nicoinfo.c@gmail.com	74	f	98866dde76f3dcf8ded557f8a6bf8fa1fc43c1ae76afeaf1e1473e1249ea97e8	\N	pEsvVuVqOaWubhe	bc61993c-2c26-4f88-b38b-239477b98ee2	t	Europe/Paris	\N	1
311	cyberpunk	$2a$12$Utg0rfpehbC.SKUOLqvpG.PQEXOYDayJR6BYThs9ekbrDWhOLw2M6	thota.nagaraju1487@gmail.com	96	f	1128841edc38abe40580c3b6f75cdbbce949a142a2667b4a1f80c7d6745433d1	\N	G4Umm6cgA6kEHOP	cd941e8c-69f0-4eee-b226-801a880ce004	t	Asia/Kolkata	\N	2
312	iiiterror	$2a$12$LZbByZgxV1WJjBrnbPCDieRoPy4aUkXAYPnV1y9/5b9uArm8wTItu	ashokkrishna99@gmail.com	96	f	e3f1e26c81d151802c8a5a81153ed0836bd16a47b5208247cece37f2fa36766d	\N	0IPua8edRfNFeCH	0808c495-9992-4446-a6d3-f526576f9b13	t	Asia/Dili	\N	2
313	yuu	$2a$12$e3l5hrRi/HWMojXE5Uegs.Ebhd.1tjHuXAC23Dv15xXL2GhRGPXFu	yuusuke.ichinose@gmail.com	105	f	49f575f6cd0c0d23308c74d85e7cd922e14979a263588b79276d31445b322c24	\N	6FRuFJLV5jcAsPg	2e72435c-8bf2-4638-bdc3-164183972d73	t	Asia/Tokyo	\N	1
314	sigma	$2a$12$VBoPvU7pVUl97KSyDZHJyuc4NvfTUzacOWmJp2vElE0sXHFZsSYxW	81105460@qq.com	46	f	b9df4c1a69df704693c1c4466089531170cfc179617b9974e07ea22757333191	\N	LL7EXVYgcHYSBAe	38d8af37-95e8-45e5-885e-dfe321b91c43	t	Asia/Shanghai	\N	17
315	f00bar	$2a$12$JFD4FL9sbA3FqW/vXwL2rOFDBr9az6xFIbnH5r3R55Q0RZTRGMkxC	f00bar23@s0ny.net	1	f	fdfe140c8a15a8aabc397c45fa049527135bdf57e49c28cae8f016ae06e24079	\N	6K8z6UcqnriZWBH	0f69ee6a-a2c1-45a6-a9e7-7e6b068298bf	t	Europe/Berlin	\N	1
316	@man	$2a$12$lh9k2zxmyl4WT/pSpaSGXefgbheeJcX5LE40Q7etTGHxZV8.P7Gw2	atman@lukasklein.com	79	f	f5cae0a2dbed8e7e74ac0aa7af4b233adaefe4267bb5b1ab0ffa6597d8c4a5e7	\N	dHgpUP4Teen63G8	faa400d9-3570-461c-9f9c-4b81c6c5bb2f	t	Europe/Berlin	\N	5
317	B1ackTrac3	$2a$12$Q9EqQ7Y9Zq4DFdba2tzKTOvZsm9tIXyIJ64sgoMoc.HHYr/mwIhUK	b1acktrac3@gmail.com	46	f	30794e6335eaffb48cf9cc22e8ce92b541318274acd2339bb4d8a5b3b8544978	\N	lfEnT9ZTCRwnTn2	7e9b82f2-c2cb-4896-beb0-cea545841d95	t	Asia/Shanghai	\N	3
318	TSU_1135	$2a$12$YiuErA0vuw7PQLU50QgxmOJQckECJq2utRou71xYF2mGHgIi5OSH6	mike95@sibmail.com	178	f	69ee94b36f92718dd2aae0039a9e3d2fdff9f2cfd4c563aeb0aeb1c725e6d315	\N	NXWTfq5RfqE0opt	45eca05c-908c-4228-b66f-a7a3e8d403da	t	Asia/Novosibirsk	\N	3
319	AM	$2a$12$Kl3x2aIvQIbmmuRsAz51OOqZw8RzGGqp6p4/gjECxkNZLJvbFI9T.	challenge@advancedmonitoring.ru	178	f	3fa873780992ddb3894b9e8bc00678f7fed7ad2cd857dbd2e1dde8c3fd8e80b0	\N	TZFyk3CeI7OL6xd	8184a0f3-5ae6-4505-9099-3769dbdbad07	t	Europe/Moscow	\N	7
320	n0l3ptr	$2a$12$0y0Pt2d3kfgG36AyLtZnAe4u44dRwnTGpttnPuqj49PyO7D/SfS9O	clark.w.wood@gmail.com	231	f	80e557794005a7c57e46f76ee8a7c82697a06cdff271fd7052bdb6d23ec04565	28de3541dfa4d1f8e34fc4cdb3d25361b1311c19c281124d402c5a05c714bf32	gIpojKduxmTc3yo	375bed6d-a0d7-42fc-aceb-34d9c5eb902a	t	US/Eastern	\N	10
321	NOPS team	$2a$12$AMsjyNzlOhmmyejwoUf6mua355aUKR4MBPezsItL9Vmg26aqTyBBm	eurecomnops@gmail.com	74	f	a0f151bf97160fa8e2eb35ad6dc9bdbe84fdf44fbfd6533611b84342835e8d87	\N	67CRa06UCIuCzxa	47ddd617-383c-4cee-912c-30b0e3070ea7	t	Europe/Paris	\N	3
322	spb_ru	$2a$12$3MCbbuGcGEdjuK56Oj6IaO2G7HOi0gwZRUIic6EbZum5wGCucfY2a	lemon.fw@gmail.com	178	f	4887aa109f3ca206e70aff9c0044cc4aa171987e86fd30403c393d93caf8315a	\N	zqqI9CFLqx87WtW	fc558244-8388-43f0-978a-4ec289389001	t	Europe/Moscow	\N	1
323	Buzzes	$2a$12$J7aPxbOY0IACPnDp6eaoN.83X7FQCRsmQr9PCuk6OGRaVHdvX6IVu	realbuzz@heeerlijk.com	151	f	26091cb3e0569f5bdbd7b2e5acde64aea328cdab78bcec136be4459207a69f78	\N	UvSnBJ0DHb310wv	60d1a6e8-b629-4ba8-a1de-cfffa452af50	t	Europe/Amsterdam	\N	1
470	Than	$2a$12$Wtaz74FcjnlJ2dfVRzxDtOWgMfhwNDUaE09wtbiCzMMJdEigV3/oW	thanspam@trollprod.org	1	f	f7cacf352496176ba85dff16a9e38ae7f0c1bcc472a4af51376cb85412494f9c	\N	vWNcuMJ88AKWDWW	47080036-1f1c-4021-8851-8eda38d29277	f	UTC	\N	\N
324	pwnthugs	$2a$12$TqaWkweOA0HLPG7t30QY3u3FVltWcymiW//8ErX0OF3sI3getmjSG	every.day.im.ropplin@gmail.com	231	f	4e77b3b9de45b85f33246a866e8949209a89f89cb9dbdb18cd448fd391d37c93	\N	pkfss0KYgUtEJsX	71a5a650-111f-4eef-8b25-13546b6c7d9f	t	America/Detroit	\N	5
325	EverTokki	$2a$12$UiXeCG9/rQzfhre3essAjeekSQNF7cSn9wOaBIuS7/hEIFN6YfY3O	0415cbl@naver.com	112	f	94e62aac28463ee8a5bf31e7770f443b8c66a7067757126c8c2990589cee24d0	\N	JkwgRkOse92lKVW	1ce09aab-6c06-407e-bee2-7a2599eaeec1	t	Africa/Nairobi	\N	1
326	The On-Net Gang	$2a$12$30L4Stn0yByRqDGucvwF8.2ESmMS.oDxme.nxcibhwL0oiCip7kOu	james.zeman@gmail.com	231	f	0e1e54e8e82bd1084431547ebee760f8a6a736c9bc2abaefc6c7d155852745ba	\N	bXwE0K5Dbk9kEz3	5a03936d-1916-4bcb-b1f1-8c2fa2f0648a	t	US/Eastern	\N	10
327	MaoPo	$2a$12$BwDTCgEtZjumV3Tagd8KjurfRhdOUeOsWXbng/k5Iy3wvTR9speVS	kk@esu.im	46	f	6291f978df8732621e6d7deb3eb73b5be26b14b5dcf9e0cef5ea9ccdb036eed3	\N	Iqw0DucQMTs9rsc	725babd7-63d1-4bfe-b56b-1da55dda1b3c	t	Asia/Chongqing	\N	10
328	crazy0x90	$2a$12$fydlQtoqLT/h4s2nTpXOY.DnCXFSUi6ewrIPiD2s4fs2u0GSH5gKW	crazy0x90@gmail.com	46	f	6bef1f597d36aea86c7bf58cbf10954a3ce2db22fbec6fc2a286b5a8283df0c2	57cb773d44868bf79a09d155a4e14ecaf1a03aa2bcc9e13df230d197d9cd2ee9	WxKSxc4LuiLB1it	c6548c7b-0d63-42f9-9757-1c5a7f6c9acf	t	Asia/Chongqing	\N	1
329	TinyWings	$2a$12$L2MCWqe/Xp1WpEhoMZcE2eTj3ezLruThwrEptYCRadGQ.sfApxFK6	jan42685@yahoo.de	79	f	2661ced06d560df838b00760c5403c7a773b0f163fffa02411abc4fde0cc50ac	\N	dYpNzMl7uriX7iY	fd3c6e7e-3654-4d4f-a379-2f562e48bee9	t	Europe/Berlin	\N	1
330	Ariadne	$2a$12$fsi1XJ7p9lye53aEjn07duLliMyRZymMimgWMWJgVkdcrd4Ey2Y4q	Shtanko-mephi@yandex.ru	178	f	af23f2a1dfecf8ac00f7256c6083900bf534019b030d6bbd3b2c7a078d86c592	\N	gqXPH0ZUhvEUS1M	5ec33de1-4a0e-41da-aa36-df4b8bf00344	t	Europe/Moscow	\N	1
331	l4m3rs_rebellion	$2a$12$gVSfxykOZK0H4gRhWbChWeNTll/kl5yf.6GYxqy0Qv2jvhWeAbDNO	searlesj@acm.org	231	f	bca284418c1659e04ebb6d4727877beb1002a38fc7aa58acdf488c9764f7d8c2	\N	2xjHlKIdqCrWwdC	ee4fa8df-e877-4623-9f65-91404de9c87b	t	America/New_York	\N	3
332	DromadaireBleu	$2a$12$xV5eb8.eh1lHxdgmKlPH6e.w/21Y.Mry9TPNrky6h.wPxipj/mU6m	sebastien.charbonnier@live.fr	74	f	4af075feebf1e74a4c3458682eaeb6eef06eaa542002694d871af837e209107c	\N	5zTWmFGQjZ7zeMy	f83160ec-a1e8-4978-8db6-fc5c9d08a95c	t	Europe/Paris	\N	5
333	Babouche team	$2a$12$pOIhjjdjxUxEWK56Icfc8uq95pZX5GKCgt2aSso8h1iNERCTjr23G	babouche_team@yopmail.com	124	f	6a16295ac377bf13e8f9193b0365864f8a6926b6a98870eb640368229605c68e	\N	y2YK1SPcpy75MiT	db026a12-54f5-49d7-8ad2-d711c7a18732	t	Europe/Luxembourg	\N	1
334	0x14	$2a$12$LZfhTKrN9MiVriKJ7eXTK.TWF9vB7yqMVKcwOFVP67CPmzhL/RUw.	jorge@tuenti.com	204	f	5cce63859d712b95643ccee88e292a1c5f4644b06eb0503c90de206c5f26eace	\N	tcgGntmTLa6Pp1p	375e4509-4263-46bb-b4d6-17450fa78487	t	Europe/Madrid	\N	5
335	schmoosters	$2a$12$1OQtHvhKBos2NzIoIpUEb.9FK9tOKKeGujjPBYFgJ3Qgb1bivWV7.	popptopp@live.com	9	f	004ae4473314f43c384f2f8c635d8f72b1940cc047f9f99f028977186ba7e70a	\N	dxjTeSGHeBjveXu	2490a437-8129-4aeb-a886-4ad42bca40eb	t	Europe/Vilnius	\N	1
336	Brooklynt_Overflow	$2a$12$08vSH.9alJCPkcXb1Hmeb.qSg1vx94EGUc0OhyimAm38V.E/UQ3Pe	ctf@isis.poly.edu	231	f	6fe6919834ff37d94e1551c9e51525efb609f3c88b71ceca95593bd7a670b3d2	\N	Ge7ffD6h72YEm6i	861a1db2-6001-4756-aa93-0f34e4e0ebf1	t	US/Eastern	\N	8
337	tmc	$2a$12$saUk4FuMVbXrIJe4Lv456OaOjDHBZi/w9D1I3BtrmgTb547C9PrYO	techmec2003@gmail.com	1	f	f73166674b8af3c2d1fbc859f3456a5abcd2579b959f0f01e6e2bfa88e050b12	\N	ZnZZ2cj8v6a9RXv	ce379ec1-b20b-4e27-8f7c-81488cd060b0	t	Europe/Berlin	\N	1
338	10111	$2a$12$YzlikAGjRqMmfpLDXXPCgupcmGDXRpCP41ZCyoLARZ7kJ3YlsUIBa	morla+hack.lu@cracksucht.de	126	f	3fe6612127e317df8a3a397fc437be575dcb282058f965665eba51786991e9e7	\N	HJsIUaJhBxh0ohR	5ac478b5-bc70-4b0c-affa-ed5a1715f13a	t	Europe/Berlin	\N	1
339	Op	$2a$12$RKahK59nSOfEXoLhpkNAS.DJzqd8g2RcT0UKuWI/IhLb9DocGeAz.	zeroatchoum@gmail.com	1	f	4932f90ec46980445dd3ffb90ffc535e279b03c6e98973cf7b514ab4ce6cead2	\N	u5vIjueXOG7JfWM	af59c168-825b-4dba-8738-046df564cefc	t	Europe/Luxembourg	\N	2
340	webfuel	$2a$12$kqG4Ld.344exxb/gUzXcROivOruoG6qMHVCxR9QJ/lj0zqvQh7vAm	tunnelshade@gmail.com	96	f	b98caa29d11c0e0efe44772f2225335970d5f813fdd909ab5858ba53c785a228	\N	A4ZuO4xKG0s8VdZ	06b4ebb1-9fe7-4312-8558-8097e9732a6f	t	Asia/Kolkata	\N	1
341	SummerHackers	$2a$12$AX34HnsPtjK0NrAf1zeAd.6pwJgwyuPpRDKIwsBYPWWdTH1fyZ16y	ssec.team@gmail.com	33	f	55e23e4d4b8f48ad83f90f3a7e0826e553968e42112bdb5dd2f61fcebe2a1ed0	\N	52yGKec5pk9AT4Z	2cf854db-b85d-494f-99f1-d394b9db1eed	t	America/Sao_Paulo	\N	4
342	TeamRedAce	$2a$12$fxyQgsspgdMTGSxogQDioeRb3R.kM7fUIpQv5mm2rIYXUmPmLTu1S	whizzman@gmail.com	151	f	7b0c048b440726f5aec4c2acb37218a8d00c451d2b6a0f639a4217ddbdac6359	\N	muU34UJqdz1qN8l	b8f4d184-f802-4604-955b-bd0be132f6d5	t	Europe/Amsterdam	\N	5
343	urandom	$2a$12$2Ps/Vuxr0uD5ntBIu6Uu2OZQ86TN8zmC1XIeMQNMF.I74M72TXBWi	dolphin.st+ctf@gmail.com	105	f	ffd4057cd75cfc5fd544766c26bd81babb1087cf44e4b87f9bd649ecf9d64d0e	\N	5jU1QictnNxtcXe	7d016654-412f-4956-b4fa-fae042661bf8	t	Asia/Tokyo	\N	6
344	szm	$2a$12$BEStcnCrqOCSXrk8cVZQf.fteeddFI.ETk4giBOf1EyTiCEMsmmWK	mitsuicn@126.com	46	f	67bc70046c574355c430c7dca79152b9d1212ccafe66a22fd27dd81668b00d27	\N	FszjxOKSlNiXxSr	8342b0fa-f272-409c-a6cf-fb0431fd123d	t	Asia/Seoul	\N	1
345	Lord Darkstorm	$2a$12$5e0FrW0/ygSJuOiCueuP7OkJJk.V/mCzx6b19m9tcY7dvc2j4z9BK	darkstorm6@gmail.com	173	f	7e03dda0a2e7b92c0ac1e18d64ccc35544bb8ac4a09be222b16afa863451b063	\N	zHZ7HCe2ZkcGR0y	504eb464-7b4c-42f8-a64b-609f4eee3532	t	Europe/Warsaw	\N	1
346	Beunhazen	$2a$12$zH6wOSmYFzjEpZn3C4yHouK7I7Xve44cP2BHJOyjayorPxTcMpAki	beunhazen@outlook.com	151	f	eda3475997da1615e4415d91544c347160a12a3597790dae28cb814facdec9f9	\N	lf3ynquXM2ydPNO	41f972df-bdef-49c8-a79b-0a3daee4e57e	t	Europe/Amsterdam	\N	\N
347	koibasta	$2a$12$mInoc8NpY2AQDRp.ZvRe4uAaqDDvbXh9oTL8RmaP9F6dpi35F7c0q	ex2tbi@gmail.com	178	f	3be5dc94228f71d14efab3d490c1f1a3bd013b71f1123db4af456b39e7adc129	\N	FajIDPiB9izGztx	be925071-80e4-4349-a9d2-463b0c162e83	t	Europe/Moscow	\N	5
348	0ops	$2a$12$.wN0tFyCVCl6eme0h5ApduN1j9S9KXSdqtLkQyyJf5aUurBDgduw2	slipper.alive@gmail.com	46	f	32d84d59a77feea91bde6274925916d632a86087413bd0182b5e326893a60b14	\N	P2eg2pRBlhGZKIJ	547d3a0d-985c-4dd5-b0bf-e130c9414aea	t	Asia/Shanghai	\N	6
349	on est pas contents	$2a$12$JqF8TSYlMmYA9fHvWVilNeZyDjglPfm8I9DyaCWZ1IhApbNf6Mo72	0xerr0r@gmail.com	211	f	65859c281a1c6681a5c7e97b426221718cab2de220fd2a357eb620f000964e14	\N	cQaIdaoa1134pEe	8a688d5d-449b-4e7f-b608-1aa85732a94a	t	Europe/Paris	\N	3
350	Marauders	$2a$12$RP8MJ83FURyBElag7TJbS.P.HbU31UqBvg8psQJh9H4VMJ.qkXGJy	jay@computerality.com	231	f	86b8c7c51ed1a1c678ca8b54f2d351c3b22501df170689ba046f719b4ecfae12	\N	KaDDNzQoS0c6XQp	32cbea6a-c3c9-485a-9299-ff4ab9454650	t	America/New_York	\N	8
351	[censored]	$2a$12$6Xu0hJHk8pBXQ9Yt98KXn.hqzr7QBFb1nAfaN3JLVYNkjhiroEbkq	timurterminti@gmail.com	178	f	40859f05bfa045246a9c24f35843d3f95e71218e32e1e518e07ad0deba83ebf9	\N	RLrmifnMxrDVf9X	d2552045-9d02-493a-a47c-e6de723fdd35	t	Europe/Kaliningrad	\N	7
352	FFF	$2a$12$zfqOL2gtX/.Bx7IdE5OvHe2bbIFQju8IhctFJ.CxjTRNIlt0OW6qG	minhtrietphamtran@gmail.com	237	f	1329f973e7283cb64f21ee486695eae5344a6e95f7aafb6846002cff8ba66ccd	\N	7xYpAcceEDfEEuk	4edb16ae-4940-4f4b-a861-0e46c5bd347a	t	Asia/Ho_Chi_Minh	\N	4
353	0x41414141	$2a$12$tGRHJ/wObH8wKkM8bmoSquv..SrpXwb8sXlvNJFDA61uuoF92R6s6	58cents@gmail.com	40	f	06117756494100cce57aa816ced5c2c624b0fdffb4f75a944e9043a2b609fc82	\N	dq5qYsxwjC0SscV	57625007-3758-4038-a65d-070a3dcd57ad	t	US/Eastern	\N	1
354	emblem	$2a$12$T1tWVMmjSkTFYczB79ugcuD3wRCVs1PosFHYvDltsTJH1VMczhluy	samtron1412@gmail.com	237	f	540521a0dd1fc6feefb06fc7b5ef8e6b0b8c672e1419fb13713a189f7b22d7c9	\N	ry99xEcorKMFExu	59fec3f5-e48c-4ce6-8d42-74dc314b9615	t	Asia/Bangkok	\N	1
355	$Tr@nG3Rz	$2a$12$VnIWdVgMd0ECZSB/oXhjMe5jD2SOAkOo4LsExnulpgPxQlxw4YQ1C	fta_boy@yahoo.com	98	f	d7fecc47c7e301a8cd0ab7d89446d39606e964b30963dce6be807ef30ecd694d	\N	wHlxeZfxxOZTmDT	5ff27ec8-7d8f-4615-b677-f3f7c81965b9	t	Asia/Tehran	\N	2
356	Serv	$2a$12$jqx0orNcxvj7u5uDkaEgie/UzNdcMv9oq3TeEZQo6mlJuuneJCt.y	testusr@web.de	1	f	ec9bde67d2c6211d72f4d52cf8634b5dcb772eb7ff3eb6931f5b7e547eedc37c	\N	HPyul8kkzNZt6jb	8d486bfa-c635-4f5f-b64d-66b4ced0d7ab	t	Europe/Amsterdam	\N	3
357	TaDaweb	$2a$12$ozAanIW.b79vozCrx.nMZ.MnR.wuuqTXJ7chm4jSlP/ZtuIpf/GTq	n.boutet@tadaweb.com	124	f	adb2d1103330f61ad9cb0b67d37daf3c76ee8e39f466c7688173690523a27a06	\N	6scRS9PQFFrdpjd	691a090c-8ff3-4092-8b0e-6619580ccba9	t	Europe/Luxembourg	\N	2
358	BadAzz	$2a$12$DPLf3Ah7QaMs9zkubGcrlO58boXxaf9WHTmcelnDL.xozubvzn/LS	noinspiration69@hotmail.com	231	f	d4b1589fc59fde3529b6561854b2b75ca0c142739ce97ffb9a8f961c92e8e72c	\N	ttcp2h3bpXbjquL	756fdacb-f33d-4646-9c5c-919253d1660a	t	America/St_Vincent	\N	3
359	testttts2131	$2a$12$sy.UnrDZJixYWG0.7mLZ0OUrrd7YOERWGpkLRMO0LKNSf.OFo6Wuq	grfx2@mail.ru	20	f	fba74a14f8eb12757bb2da242ba801c333ebedce6ed5ea70240f65602f85afb0	\N	qsCSA75K9F57eAq	9c94df59-ed21-48fa-8c43-0af85f74152f	t	Africa/Dar_es_Salaam	\N	4
360	xbios	$2a$12$R61FEKzQXFNuneRyj8fzH.21eOI/QloFbmx0S/rTGRMa8GzIVOga.	mail2aghoshlal@gmail.com	96	f	0ed2fe0ef08355fe41c0d87331dfb632d6571d5bd6b91469ffd972509101df35	\N	UzXcEog2PrcUOrg	2f58cea8-b865-4596-a685-551ca0a9d55e	t	Asia/Kolkata	\N	6
361	K1ds	$2a$12$KTxfrc6cp1dyacuTjGmaveNWEkBGBIUksezLZwk.014iYxYKrp5SO	wastebaskt@gmail.com	24	f	b8620ee2d21ac46468b15b09f6c191d647947815286680c958ca45a5b851713d	\N	7zPQ6ispyvrB3Qr	5c9e56b8-b476-4636-891b-5afb9abacd1e	t	Europe/Minsk	\N	1
362	WorldofHacker	$2a$12$bBjQxr3Ucm.Qq8zdwF/Mrez.TQw8yA0Dc6yPk.YQBP9CelgzlD/GG	worldofhacker@mailinator.com	231	f	8e3f1c4f9713d77cf4a047a93421517fa4aa309cf9d46a96f96f2c0f80d86281	\N	TgkmeqhCYzGzD4G	d167b626-38ff-423f-941e-7e8e8994bac3	t	Europe/Budapest	\N	1
363	pADAwan	$2a$12$7Djz32lEseEzC1g8Ri50ru6pzhajj7nNk/Ges549q6paBRJBSvqn2	santiagoprego@gmail.com	204	f	59504e29bf6fb60281ba487bf50da2bf67656543bc9c3dd3ed9a7e69417fb657	\N	QS0zUA1Bl1BUmXC	1398443e-3dc2-4942-9920-387fd9ee85c5	t	Europe/Madrid	\N	4
364	DPS	$2a$12$TWlOozeE/0XVJnbkizGskeDt/dp9Y/YcAS8XP5iGbrlekfwkxM0pm	billy.meyers@defpoint.com	231	f	43941e1cfcf27623a8413518caaccf5580f08617d29937a1f4e5a98e7ba03585	\N	eSNh0kRj6bkunTO	2c73e02b-2b75-4489-bb17-7ba8fda926bb	t	America/New_York	\N	4
365	BreakingBad	$2a$12$nzzdw0VOWC/JvGXMFjIbieZNVVNnZhRFXZz2yU1sDWk9UeHXWALrS	mcflyonly@hotmail.com	231	f	eb2b1585dfd07008efc55b8953f375e033fcbb1d9acb3404256378e6fcaed857	\N	nUmIOfQEhfKUmq1	fd6914c5-d098-430e-aebd-dfcb624a191b	t	America/New_York	\N	3
366	Walter	$2a$12$bGZeaF1tcA8mqzNlcvH0xuTIKs1Y96SzWRMEAr3pY1fF8Rw2g6JYS	walter@belge.rs	151	f	39bf61fc0d604e33d0bc724bb4917ab4ec8d0fecba4d1406a5ede0545470f6cf	\N	awAwnIjaQAvS9ih	55bb221f-4241-477f-bf49-8b68a1488705	t	Europe/Amsterdam	\N	1
367	dragon trainers	$2a$12$3LkPvjw247KqcvI9wbaKK.n5sOFLXInhXcQPnC8295sYtk7Hg90jS	joohackjoo@gmail.com	231	f	673d31cb6f859a7aed1b3f4a8aaf50adccd404b9e4867f022c76d11117d698d8	\N	Iug34f0IIx3f9EL	523fce93-e694-4118-a95d-7f2e69dda1cd	t	America/New_York	\N	10
368	sapheads	$2a$12$iTFiHgFCnfqNhkPuvfUoU.dZrP6Sm65.Bjyw5BSLVyeBIUz6IyyEy	justinswkim@gmail.com	231	f	899090ee84a6b855e945189747d09072a1d45483a389b40687ec5ae791298e48	\N	MbdJUOB9kUQUueb	9256cba6-ed1e-4dba-987e-02f12978fdfe	t	America/Kentucky/Louisville	\N	4
369	Silentwing	$2a$12$Yjh.DqzHqthk16oMH6lXX.HIoHwKc0iH7KSAMl4Hp4phBGyglHH8K	Galciv12@yahoo.com	231	f	9604964b3b2f022b142b38f7b6168921b700e2b4df4068012794b67935469d5f	\N	e9JYIZgwq8Cdc3v	96870aa2-ddae-42ab-8a14-f92bcb38292e	t	US/Eastern	\N	1
370	n0Nfl4gs	$2a$12$UmCMxrpe3kCCaPn9D0d7ZeJVXrT8GJkhMX3L4DGtY1CF4oxpjHVaO	n0Nfl4gs@gmail.com	96	f	70b19c4d78072dcb2da01686f91027a9788488bd5e927b50d4dfe25cccce46cc	\N	eW2XsQNwmwkNynn	42910175-283c-4ea7-ae71-f1178979c42d	t	Asia/Kolkata	\N	2
371	respina	$2a$12$u1dj35hoUeCHkclsUF2eyuencjfwxUpIX1ZsBoxICxsGK7fEolMYW	respina.caspian@gmail.com	98	f	0be67f19194486e967011ee6a1b3eadabfecd0c5428b6aa7c33b43d05de63503	\N	5rVX37jobgE9yTA	589fc776-cb8d-4529-bf19-9989662efb78	t	GMT	\N	3
372	sandbox	$2a$12$J6h4.wGjSpaKqcNYYSB9k.6tAnMF0lJ96Qc4zoEb.Zdvi/AzUWSVm	13blackbooks@gmail.com	178	f	bd9080af64205cc7111b99857054adcaf8e91ed8947ff073683c81d718146195	\N	yZp1L1jngoxbVeh	68fefd0d-1898-4c0d-a951-998ece3e2294	t	Europe/Moscow	\N	13
373	pumpernikiel	$2a$12$q0qifSjg1mRN9LtbpSlvt.qDcG2tDO20wvI02DTka5r8phtfQ1ftq	pumpernikiel.ctf@gmail.com	173	f	d2738c31ad59e66426f7b34facad8cfc6b4eaa814aa3b08d35ac82613c4523be	\N	YTr56kI4clgyGgF	b6a4e188-d973-4e4d-8812-a2dc02d96590	t	Europe/Warsaw	\N	4
374	poseboy	$2a$12$g4znxQUjR0O/qtweWTc2g.ll.7XL5IyjW81ZOg06GDjE8foHyXuZ2	vessial@hotmail.com	46	f	68a3376d499ac712d7a5445babb5d328a8bdca4ead3345f7420220c377f8b327	\N	66WEAonCzGOi52H	9c87bae0-4941-49ed-ac23-9d8a891b2a71	t	America/Los_Angeles	\N	1
375	GNU-E-Ducks	$2a$12$r12n8rpxVZSTd7dtHvqC3eO4Zl86JsU5.hDrsFz4cnZgUxd1fYZMa	geoduckctf@gmail.com	231	f	893e69e90bd01fa2fe7b7a768b907428b913d6aa56aec9abf2ff7a54dfd1de78	\N	oSaBba5IScd8V2a	9f5fb96d-1870-451a-ba47-12f73b0e1ba3	t	America/Los_Angeles	\N	5
376	Cul-de-sac	$2a$12$nVbJee7VIthC6XSm8QyqxeZEboA0Gg1jWgYk5RCvKVYO0d.dUk.Di	ecneladis@gmail.com	173	f	41d9a697b6e459d5aaa819ef1e3baad8adb3d70ae76300e74a679718065f2786	\N	d4osmtNL3EHCsBO	24848336-18e6-4f7f-b64d-e3a43bb0c1e5	t	Europe/Warsaw	\N	1
377	p4	$2a$12$0pu1UEae04ddK5Sdmzydwe7hy.brdVrfz8.WR0fw0/y3okDhDvG9a	msm2e4d534d+p4@gmail.com	173	f	9e149e21f5df76783b980b8096ffa6b66e30a8c0b62a14e801904ced7e229a24	\N	3rAxvMvA4UcfVES	f5c7e9ce-7ff6-4d49-af0e-652890bbacb6	t	Europe/Warsaw	\N	2
378	pollypocket	$2a$12$iKKW6TNm5mfeINQKsHaFbeln4an0S/jgyRPpSAVgWsongO1zRKqu6	mortis@mortis.be	25	t	028e82acd0c9037415e3004efa88f46bc72acd94c2e58d762b3660372d5f425b	\N	8YD7QdfxkfLuXyk	2262fe60-d9ee-4cbb-9e21-529d38d1ef94	t	Europe/Brussels	\N	5
379	ali	$2a$12$ACX2JKWoLbjJ7nBhZLQ85u6zDOFLNZCVopjqzTtGHMFBhR71UhyMi	aliqader@gmail.com	100	f	5bb2c09f56e77749c674022dd3423afb164a55deb64fe81d99547bbcbbe26408	\N	fiAaRW4iWtccmQn	a759fedc-4535-4de8-a81f-1fb7847fb77b	t	Europe/Dublin	\N	\N
380	forensicator9000	$2a$12$HHi/O0YDzHh5GiSSe8hhDeOrg6W3l1B8wVELawQlDVwvTb1807eQ6	brecesej@gmail.com	231	f	0023bb44e9355c7023d791c7e85b76b4bce25c94c7a93a7c1b1f6a3e862e5325	\N	vdqDEx2EYvcBOak	f52ac157-7207-4b56-b44a-a6343a4bdcf5	t	America/Los_Angeles	\N	1
381	Hallam	$2a$12$zaAMdE/ZcZDZmwr3UvtyVuyMJmyKNowEjL7lj0hcoVDP5ee9cC8ne	hallamctf@gmail.com	230	f	9b318198a5fa92d35d02bad173012416f595ae723bcca6ebbf24a06b2660cb95	\N	fhw2M2vmfUovdgy	2f94feec-4b58-4153-929a-2e0339bc3d76	t	Europe/London	\N	3
382	One Man Wolfpack	$2a$12$1cjdwpUd1TCIBGFM/brWRuGE2v1XO9auwA0OLhYwVmFNAr6YRTBGO	twosmartfoyou@gmail.com	231	f	01dec5e5e66229f36ffd604c27576abcb3bb01d169fa8415f2e3c937443c4390	\N	gD3XoSUNEjHIk7z	f0293787-f88f-40c2-bb17-b5e245422f99	t	America/Denver	\N	1
383	just for fun	$2a$12$cFJiF/RjGnLdYDAG/Dw8KOAwjmACYJmAnBc80vxQfqFYaXRqyRibq	scuhurricane@gmail.com	46	f	29f06eb5997e54520a1ec2f6e3a9582349d97303d22094d7e33e471f9cdbdd02	\N	tWxzdYMVIdz7I0X	fb18fed3-86d3-4217-8f97-abf3f4fa00b3	t	Asia/Shanghai	\N	3
384	HappyBacking	$2a$12$X6fcfwstS3Ny0GONI5Yh7eqNQreEOUFxaAmRVti2t/UIjNcjbCuBK	hacklu@scaltinof.net	105	f	cfb5bdf8de2a20261c68d8ded441a23420aaeabe3039812d8810a6532941f98f	\N	4JSRSPwjlBrBHAk	82a63d46-d644-4539-a3e7-debc678b88f8	t	Asia/Tokyo	\N	1
385	T.A.R.D.I.S.	$2a$12$oaWonzsWIiFDlxJCAmHQUeL0oeyqcyJcPhMvbVFfV33WryxqLsxju	neinwechter@gmail.com	40	f	5af3299decae792fafa03589c4cf4f18808a9f5001db203eb74360992a627ebf	\N	fCt9sGdLIaJpZ1D	be48ac79-c3cb-4560-b786-33943c8ef6fb	t	America/Toronto	\N	1
386	envy	$2a$12$.2WbK76c2uzp/dZmVKNqBOtgxRm82RCt9ja/vRFqRpkR6TIraLRs6	dragonbahamut@gmx.net	79	f	6a152d158e802a5b156d6b621191eac45cfab31969d0a51da8827433c8f91ddf	\N	ukH3zAYWsc9iIlY	6824b9b1-983d-4334-b108-02d59248eae2	t	UTC	\N	2
387	Mitchel	$2a$12$z/7R4mQ8LRFJBCWN3edLWe0EJZnFmXveTD2hU.LKjydtxRClRVOgi	mitchel@byteflip.nl	151	f	8e337539a2a96f6a6e088661ee3ac9fe5c707b2ada6eb2204d1783ee001ca8be	\N	UnKsi2yU03AtVSj	b8055737-aab4-4ee0-8023-8a74c9693d93	t	Europe/Amsterdam	\N	1
388	217	$2a$12$CSKxl/N.DFKeVOUW92Lwde1cdi2cnjQRclVc0e3bvRxQ6Qb2H/mIi	seanwupi@gmail.com	1	f	255973484a5a533b2f6d70464896fccb1082729a4caa399e5866e5af1b2fb96d	\N	e1QfSJnKficHEXU	0cac50fd-38d9-41f9-91d0-517513db21b3	t	Asia/Taipei	\N	6
389	jadore	$2a$12$flp.1aQQzGcQB1cz4QWHNuNN30pCxYB4o1YMbposFJc73Lwk09DQm	jadore.nsfocus@gmail.com	46	f	3b01acaf94d75e6bc48748d746d07642639d1cdec8c70efc616f62c6b1b1fc72	\N	l3wlJ9350hUkXFd	2be7ec64-a6c1-4ba9-b762-2f69e00043dd	f	Asia/Hong_Kong	\N	1
390	csie217	$2a$12$uXdgmEYupl/ZK7ugzhti1uP0j8MCQUUSjbOrmc6Ln65H2xAhNLKIm	lab217@hotmail.com.tw	1	f	3006dff23ccf18ea461ff889470033f1f4920e93be01132077179cb1cfae1f41	\N	pkNK0qaDxoxEEk5	16fdfcf0-9e25-470a-b709-86a4de2ebe02	t	Asia/Taipei	\N	6
391	GNOUU	$2a$12$Ri3HVtYdvhTnziz.W9lch.Qu8XxiUHiFKSKjucDBvBedkEz1Y.hha	xiaogozaijiao@gmail.com	46	f	c74f533fd1c2ac164b60d08332b395161aa30a7da6736dd650c6bfe86b4e3775	\N	7HTKRbu7K2zrK02	150731a1-0938-4ac8-aece-ebf4883c2d0d	t	Asia/Hong_Kong	\N	5
392	rm -rf [enter]	$2a$12$rO872VwudDhAqcE/E7ejWu3ZunheyVL7vxgL7ErU22gz59ruDw6By	rmrfenter@gmail.com	237	f	e4c5dfbe9f384eae2e0cf5d765b7af071cb1f7d460aef37a0b07e9fec45bd668	\N	hD0AOD3kG1ihilq	9a27ef80-6df2-48d5-a6f5-dafa533ea07f	f	Asia/Ho_Chi_Minh	\N	7
393	FieldsOfFum	$2a$12$.jrhXtyHa4NDBi469vJzRehFrss58R9W/NRDK.0brbkambxF55Ouy	nwong@utk.edu	231	f	96d64d466b351381005382a83dc3aec06cba0519f901a5dbfb51cf615ec2bf08	\N	765uC1GxFjzFDey	f47a8324-e370-4175-bbff-c4767b406b79	t	America/New_York	\N	4
394	rm-rf [enter]	$2a$12$V8.ProRWfxXfos2nTZUK2.mmfP6vL9St1c7R/pV/iCy6zKLcRgPDy	nstung0911@gmail.com	237	f	db6ecf2d5a830456f95e3971e51d7ca64f380dd65561cd3a7cfa0a0b694d509e	\N	dMVqw4Jsq6ur2ce	582d295b-8cac-417a-897d-7e2444b97b8a	t	Asia/Ho_Chi_Minh	\N	7
395	nasilemak0	$2a$12$1E4OgKLdhg6IWgBRnAJQr.jZBb813HYtZhTbIgRA2d4qOZhZ/8nze	letheleong@gmail.com	129	f	91889aa011e351968dcedcde19e5fca28ecb998d4ca83e049b7474d3cefe90eb	\N	hSiWqkUKXj6mZRY	dc2fd29e-5da1-4184-a22a-91440a3200dc	t	Asia/Kuala_Lumpur	\N	5
396	nasilemak	$2a$12$bd4pQEAPHxDzNV5T3ct4hOS4pwDAOOURK66.HX1vGtmFKQHcQ037q	nasilemak0@gmail.com	129	f	e30a8dd73f77a79fde07c30610f904776a4875b993f0ee979f9cea0470d77c96	\N	4PRoGPwJEMv3lTS	60a529c6-4971-4a38-bf71-212c736d1964	t	Asia/Kuala_Lumpur	\N	5
397	cipher	$2a$12$y5UoPgJG4DZ.K3MC/Gp52e65eGk9fPQ7IM/Hxkb8a3284Rs9ArKh6	brahmareddychlkl@gmail.com	96	f	c3738964d76db0b58630d3a4ce6c9b31768faceae7035c7e5ed5ed6e089cd9f1	\N	nx3ktFfmP4CcWZ5	6619c170-4c81-4503-ad96-42158aa24f12	t	Indian/Mahe	\N	3
398	m0ngai	$2a$12$oF.Gnk4HA68WqJxHjyZWReq4nJC8RCJ/R52xh3ZKHr4bIMZsFS.Hq	rsasho_31337@hushmail.com	231	f	24cb3ba344a4db29252bc0fb979fb16d56a6a4989a8009aa8f9bbedd5dcda7ad	\N	nRgRcHX8KB3MChk	d8004788-309d-47ed-b773-6f7499b19540	t	US/Eastern	\N	2
399	nopsled	$2a$12$p1B7uQHlv4bR2VsIQIrvUODZOVwLSFe/SROH5iZa8ekLMbQ7UDxJG	michael@fresh.org	231	f	041855c638d868bea337eec235f0b974524ef5128c9cb571155ce2f1b6615134	e5be3ec633cf2e7e218caad6737de47f6037857aba482266cffd30aa32074fcc	5hxgQKxsrvoZDsw	76f16dd1-3524-4a74-80fc-f7446c0ae6f5	t	US/Eastern	\N	5
400	pisces	$2a$12$TQ8/8ZcfSH7WzIg1OQdNCOOnbQrcCO.hzjrqrMoCa..J63Ho9sBMG	piscessignature@gmail.com	1	f	9483d35811ab63658a2af5b4e9b826e85de6178bf1a7174346adda265a1353a0	\N	M7fnz7vkVVRUnsb	22895026-d7a3-4cbc-8609-c7b71d317ce4	t	Asia/Kolkata	\N	1
401	coredump	$2a$12$.ljdY5AhiCfb9.VYivomxO0si0xVGKzeC/lN.Tfdx4bYY4JHjLyHm	mw@ccs.neu.edu	231	f	062ffaaab9bc22067155b1ba3c560815c0d664ee186b53aa032cd8ab9e136c2c	\N	MGk2QBd5vjblHOa	f96b54b4-bc36-45ce-9cf2-9b63a0b0c546	f	US/Eastern	\N	\N
402	inj3ct0rs	$2a$12$/nURbhgRRiteyB3RgaboPuVcLo2c7/SXqeS.n2gU6LYRoC0bR0dc6	naveenksid@gmail.com	96	f	234a2da146c676f4036419ed109c712b241dbfc331bffe0763142d39d81682a4	\N	U1jlBBybx7l6Cox	5bf8ed45-3a06-4650-a8ef-7dda22479d22	t	Indian/Antananarivo	\N	3
403	8tab	$2a$12$iTU.H5owa2CTfZg9/ij9cOQXUmIRZcO8BOU/Hz5MWtVlRU4v/GOAq	ctf2013@wp.pl	173	f	fc746a04226b3ff9997173ee9355e71b5a61efc492133afb0c502dfdd23a9bec	\N	ePmvAOFPNoy6gZG	48eb539b-8c43-481c-9146-4a9f68844068	t	Europe/Warsaw	\N	2
404	anypang	$2a$12$Fw5svA57wcmS4DwNi33uXOCSskDuHTxOkCVAKVs.oBBJXHL4JQAc.	pajamajadeen@gmail.com	1	f	6d1d3fd8007ead090cef103ee12688d522f52be3b13561a07a72e364022f3d2a	efadf8fbc006966e0860da2edc015a3fe1cbc09bf03f23ba569da77c31a4919b	EScL72h08WZyZxI	37b8e4e5-bcbd-4da5-a3a0-2b7f6f6dcec7	t	UTC	\N	\N
405	blackzerohackteam	$2a$12$3YoJN7LiwBiyHFoPrmF6/.ZHgesh1AmF/0.ud0mdo6caUZ6.nn3fG	pure2457@hotmail.com	215	f	92158f2300b2ff801855481e701df4c70a1c6c0e8e4b4db50d1db553efb1e0b2	\N	YuGLxyCjH0kjAP1	bdeddcae-033a-48c6-9144-32ab398682c5	t	UTC	\N	1
406	botbie	$2a$12$bDI95one/D7f3zcN2Oi1c.WYr6w8xMu7ppF5OXw3ERY5ge2kIpaYW	dungcoivb@gmail.com	237	f	10e291a3c4241f359a74102aa73ecc9810b00d905899df749587b8e991aad0d5	\N	TbXO65XC4MRehhE	c2ff5eb9-8079-49a5-96d1-705ee15c370b	t	UTC	\N	3
407	0x0F	$2a$12$NpKQzJhOT0o7YXDT7GSPbuOdESc.q6anD8kaGi4GfhObhGzybwe5e	wantusirui@foxmail.com	46	f	8ae0e8d13941676efabfe94405891cf6afb1f421b8689f2e162ca20657efa1a8	\N	X1bBugPvr5WAEe3	bda05377-d5b2-4ea6-8e03-daf6b6e26a75	f	Asia/Chongqing	\N	3
408	sw0rdf1sh	$2a$12$X0rBMeOjf7LbxwFYjoPlvunT0D2CdM.GFl9UTxeWA6Ww5DlcTk.4u	no1sw0rdf1sh@gmail.com	1	f	31d387d0ccd0170212c5f2869c956ef6aafa076756a790d264478cf5ba8f7f60	\N	RHmnizdJDqMZ4BZ	92189d4f-a227-4d52-8faa-e6cb3124e1aa	t	Europe/London	\N	1
409	Dospeed!!	$2a$12$dlvzywBVYrNdUQymgghaV.dh6mCjZcBAEh8vl3KnETp5DqJz0zBxi	0x726b@gmail.com	96	f	7a99e2fc058075d20b4e992f26529edaeb3cbce27ddf827f2c99f98a6e50d939	\N	JsCWpMqWUXci0xP	25ed6c3d-20e3-4ebd-8964-84cb43bbeefc	t	Indian/Antananarivo	\N	2
410	ArrBas	$2a$12$oEl9lW1v6bXxnv569LItGOKkS08vR5hhWVxNzaSUgVs7/WHeUVosa	mrcliffjump@gmail.com	231	f	78df927995f0eec06c979158ee13f24108388c61078f6c41e12b364f76f0b5db	\N	YNFJzGdKfzogc39	1fae0215-dbf9-4d9f-87a8-a1f867dd8497	t	America/Los_Angeles	\N	3
411	Hexcellents__	$2a$12$f7vtxl5B/1xti1O3JyXTye4BX6D3XG0J1u7PfDnfiwGqIUkGvSUMa	ctf-hexcellents@koala.cs.pub.ro	177	f	b33f66b47cdbbc4b8c01171aba7395e6b7ecaca5df860a93ce82c5f36118a26a	\N	nnPnvsnBNrQqY7D	241bc89c-99bb-42cc-b9cb-653334842738	t	Europe/Bucharest	\N	5
412	Hardc0de	$2a$12$TQSX0xBtYQ3KXktZ0SDLRueXSl2oOPkCWANUbQ5O4ig3l2GkvakTy	cyberguru007@yandex.ru	178	f	935f204f816b80da4f5495de1783bc5799ce00599bcea4b3da14f6a12322079a	\N	aDSSjygsjKmoqlI	4a415f84-40d6-44ab-9dc9-394afd587979	t	Europe/Moscow	\N	5
413	STC	$2a$12$TywYxFYtDv/tmUyoq3358.LWuuejsmVAb4y5NI62AcvNmAtX0pmEm	piratephoenix@gmail.com	231	f	8053ec6349824e5664f952b9cf45cf1700dd56b0956f64cebfb7a5e8fdf053cf	\N	cQcRHFSBmY9UTdd	82df6863-107e-4444-8b69-3ff1b9b97837	t	US/Eastern	\N	2
414	AutopsIT	$2a$12$kthpuh6bEV.GiPXT2jHEIO6Lv1Ml3iXXXKIBm9lIkg/kYxas/qWBq	benoit@autopsit.org	25	f	a9a401f4d8b93df6901c8ec465ce3ac49550b2d8bfc98d0f6f3c5daf2e517063	\N	kHVvTSHtiDRyYAJ	9ab78699-296f-4554-9864-698514b89a8f	t	Europe/Brussels	\N	4
415	Back2Hack	$2a$12$ckBuoA8quLWaDWK9GWuVQO4QJrRqSzh0apZ5APT.HY9bdJSMt3exS	admin@thevamp.cc	79	f	13e520e2f66e4a18c8cf264edce298686e5b9acd5ee41ee1aeab858595ad9f65	\N	ZzEdx0cbIlhCkDu	d11153ab-5c1b-4c13-a190-65f9762a661c	t	Europe/Berlin	\N	2
416	Kut	$2a$12$U5zMvlGAH8iDZoJzr2.maeX6AjLr.E3Kfp82FAHHs0gPSDg9zqwhy	pneumatix@gmail.com	151	f	643e70d3d58354cc4d8836b761d5f8b0fb6396a65d85fe857c84ae91bf4164d6	\N	WOMekxupRAxV2UZ	7512781b-ed57-4445-b58b-2d2d4e2ef70a	t	Europe/Amsterdam	\N	3
417	IntM	$2a$12$wpPF1OcPOTeDZ4F2OijUueNHv46bMGGN6Ai6mCmzwDMrtNyFMq7JW	ke@intm.org	129	f	b7c762a9f025264b63e34bc3ea5d6a599d0bfc5b88e4c06b5fbccbc816af44bf	\N	G6dJG8NtVIr3AWM	5e8383c5-bdc9-49b4-a4cf-90a70c6fa79e	t	Asia/Kuala_Lumpur	\N	1
418	sudo	$2a$12$wv1IGrfIMJf1Mt9oq1274O/Hh4E/iINoLsXBwUnMllnFgNCVa9Z3.	afonso.arriaga@gmail.com	124	t	7df42ee1ba6504f21869e6a889dd6351ca498dc5021962dbee4102eb8952e56c	\N	Qthkkn6H0zjJ7aq	73e36c9a-d718-4fa1-be9c-3958180154d3	t	Europe/Luxembourg	\N	1
419	CeTsFiea	$2a$12$LI49o.y5ZzNha9IdmStgQuWr8UGdxyItENoBbtiFHgNx2YDigpFbG	ctf.esiea@hush.com	74	f	053d5365a61a472a1695a22fcf1d8efcef8655062dbf6751721e7f9a88700aac	\N	HOPRxZVNZ9h4vZO	f2b4512c-0da5-468f-b0ac-6c8b478fbd52	t	Europe/Paris	\N	3
420	Fourchette Bombe	$2a$12$oMV.wklxny3yVBuHzHFBW.vJ9wSnEyBnaTy8SyDpdnt5om44.9zxe	swissmade@gmail.com	211	t	1eff2bc224e6b230c44c936d4960e0e0939ad2b0579dfa6a9595bc17d20203c2	\N	APPUBf7JjJbo8pT	b2a15676-7c01-439c-bb51-d19e2d8cfac4	t	Europe/Zurich	\N	4
421	MostWanted	$2a$12$vY/7.Tw0pRoccd3SGFbfvu7S9PhBGZDaODWxx2QS6Ini.Qd/otjYi	loger177@gmail.com	177	f	fed557388fd4f2ce8a76da67cbd68ea2295a6800677a663d9b73ed24fc5f9dcc	\N	B9XyFCae3E4qmQg	943619fb-0c1d-45b4-b5ff-519933237975	t	Europe/Bucharest	\N	1
422	hotzenplotz	$2a$12$8xeyFxTtbfWmNpxx.RQOVuNJLMh8Irlk2CV3YQc62hj/dGODivRky	m0083037748@sayawaka-dea.info	79	f	3fca0b4ddcf899bf20a17c1cec17dbb2f993bab5273fa3cf98a434fe89e233c3	\N	RuGJTFriaOvAzN1	62f346bf-1db0-4ab0-b4cc-2aa90a7cd229	t	Europe/Oslo	\N	1
423	COINS	$2a$12$dE2btGwrwMaRRs8xUkaLluhFh4rdy27PjxoWFOTMruCnrDFsBq612	yi-chingl@hig.no	162	f	808f2c530077af6651d3a5d18cba652b589fa6426ca42504f98e6313dd5c0d64	\N	h50L6LdmcDnzBKz	b3a064de-921b-4818-bf7d-f4513ec3d2bb	t	Europe/Oslo	\N	3
424	FactoringChaos	$2a$12$ioLG08BXjvQY4IU2KIJ0HOpuuqk0z4HDWlKy3yw4k1627nE3BVpVu	chaos.factor@hotmail.com	82	f	e40bc71632bd970eb5e9f8d68af6697852c6fcc498d5cd314c42855a430a600c	\N	fAyieSUz2qVzPwv	07c5248b-0f84-4ffc-879f-ea3fd60db728	t	GMT	\N	1
425	Hypnosec	$2a$12$L310UHDsWrGt209MnMPMnex9/Uaoi8WfqbgOVSQqBst21MrNEBFIO	auscompgeek@zoho.com	17	f	8d4847ed6fd05901343dc8fc5e48123b1e4780e8cf929b1e46183ad359e83286	\N	sZTDQY42OZxBpyW	8b47dbb5-7d88-4a80-b982-5c3deaf63338	t	Australia/Sydney	\N	2
426	LAN	$2a$12$DVlWPed/lfXgjU7Tc926m.j/b5Si0XVlUP5vvi3GDTeoPFexHui6i	ashare1.3@web.de	79	f	ab4f025ef2ca0eb953f9a4f96297e9914a07c061fcdb9abc79d2dc9c02978dc2	\N	3wEcwOoKnO1HeuB	af22e14a-2c7f-424b-a611-7bc4eed26d6f	t	Europe/Berlin	\N	5
427	tzn	$2a$12$evbbfAg5DFrucGJQKZkuJO.bnsrZO3d8A.3/xP.aNDrGcgj582xMi	tzn@yvanj.me	25	f	efd88344fecdb622fcfa71144e04b9931619061e2d08eac5b9e453a5d23d1cd7	\N	12J9Ea5Q0swqd3t	0224e00d-638f-4498-91d7-ed4f0f8e319d	t	Europe/Brussels	\N	2
428	ksec	$2a$12$YMDnwZI716jKGlryLsGFleYdiW641/fxIZUPiNVIIJfE24FEOIOoq	kevinkien1318@gmail.com	237	f	54edab64642e0c35cad10169545570fc81c1e0964b21e0e07044f32230f3334a	\N	wNA1qCtSbQfneFI	c387b9ae-4903-48f5-adee-170238645dde	t	Asia/Ho_Chi_Minh	\N	13
429	StOrm	$2a$12$nVRZMllASQb2Srouv/vOmuD2jhD0deFS5AZH8GrMc3KDIvq8Xq5ae	hung.ptit92@gmail.com	237	f	a4f21cefbea6b5b184b45296de42a284d4d19a9e6ec8d319a3bd7a991cbb0e45	\N	EIOwMGjIGbB3aJz	d50634e1-de08-45d5-b8fc-1b30bc5a8842	t	Asia/Bangkok	\N	4
430	Tic&Tac	$2a$12$4iPeIOUrLVfH.pIyBhDNd.s5CF7PlJ0k.JL.U0od/kZUAs6C08mNi	dd.mulheimer@free.fr	79	f	9ec4e806f15d65662fb0b8f2fe77b35863ab6f4eef5b64bec3d8f677f236362b	\N	iYJFJ9hLXj0N7YE	bb1a8d06-a441-43e9-9507-edd3316d9cf0	t	Europe/Paris	\N	2
431	RunRunRunC	$2a$12$iGfzvuJnGhnCngJy2yJ1Xu6fZ87XfmbrE/G6ftiW3GTzbROx7yJVO	chenjincanhsw@163.com	1	f	a1876f6bc3d9a5f4607c10b36095e54cd9645095bbdddae5a12fe3a2f15f98db	\N	DTuTbomh0qxZ8V1	06085d33-89d2-462b-af77-41b78e1fbfeb	t	Asia/Hong_Kong	\N	1
432	Censored	$2a$12$A4OMGUgy8oxg3K.0x8arU.pqWaNYmpUeo/zpujNZKmP.FSQ2IiFwS	artemiiav@gmail.com	178	f	d3ebad747c50965d70b34ec73790a2add3da1ce063350a602d50e4db7b2486bb	\N	LSKhUfBlwN9fOQh	68e66db9-8b15-4726-99d9-5ec88f7de8e0	t	Europe/Kaliningrad	\N	10
433	gief_expl	$2a$12$kbVnHclKJMUhOne.h/nk8u5EUym9btkxLVF5jq236.GmjD4sPZ0t2	shiftreduce@gmail.com	1	f	15c707b6714ba9438c2fceef67bc59e8690c6aad4bb18a8d115e5a9b113108a0	\N	AjEtYRZuL8gBD8A	6fcd15f6-f452-417e-8f58-07b6920005ad	t	UTC	\N	1
434	Darctech	$2a$12$WnqvW3keqS.o27tcCWm3QOuQy7vGP26xJo1y8SEbIysM59yKvZgxS	darcpyro@gmail.com	17	f	5a71c51e52b542828aad62ab6de24e3a5894f19df3ba1639bf8d823cc33a2ac3	\N	wQ1tcYpWB3aiBfV	72d9285b-7184-4221-9456-da95f4d941e0	t	Australia/Melbourne	\N	1
435	_1o2_	$2a$12$AkrbYjstJwpQm5vB0Ibg..jbRQfEmZTSqSJ4tWrZLLiNUUt42Ron6	o1o0o2o@yahoo.com	1	f	645d8e928ba8b0452029b2fc2e084a3f45f81765382c7e307f78d04f4fbaa6c9	\N	Usp3aIpOJY43738	289e3087-ffd7-42f3-8f13-9089817076bf	t	Asia/Seoul	\N	1
436	KQCQ	$2a$12$aA3AMT4YhanVjXOargLIQOlvJ8wWnvHPE6YQpRvFhSBNNgdKdlaVC	khoquachoqua2013@gmail.com	237	f	fdb6f9d299e1ee19725d8a3a7b39a533c3a020c82cdb255a4592ec45f59cedd1	\N	TLdCBXx9RARYGOK	5b468c0f-0157-4a89-89cd-5f568505b075	t	Asia/Ho_Chi_Minh	\N	5
437	123	$2a$12$wW0OhACK1ZY9hqdJanFFlubJdVvd2Dtu019JaS2sci3fqqHtXwjTu	tat@list.ru	151	f	44f7aed9702e88922b7b7c0ab27c2218f272822c95d6d9550980dc8ebae972e4	\N	WEhNoK7gGylfdqz	6ecdd776-0122-41a8-8604-e1de1600bc51	t	UTC	\N	1
438	QPURPISOG	$2a$12$xZdeZjUcxpf4enn.SvBKd.73kMvjhv2mvDNseonrigDEu94cJ6ZUW	andreeantoine28@gmail.com	74	f	8d44993d06eca9a2cf2c34c6edbb77acbba63bf60b68cd4a30f7deb5531e46c6	\N	u2N8N1aN1GwTNON	3dd51f3e-4d78-42a9-beb6-20f654b3c3ee	f	Europe/Paris	\N	3
439	kmasutra	$2a$12$8.vWAJAyXehSoEo53tLJjuQl/BGyYkn1YMB9Vzi36wdyx/7f8u8.u	km4sutr4@gmail.com	116	f	3d8fd399c5b33a5e16fbc82f1c94c1c56ec3ff138469f4a0ac52c496fff4fbe1	\N	BC71P9hjJeJ67Cg	9f0f24bf-f524-4846-bbd6-f10a78c99223	t	Asia/Vientiane	\N	6
440	@x5B	$2a$12$1OhIbeQ2P3tNpIJ7mxx0HOyx2PxgwVjhBQLzdXV0XeDvF561XEIgS	nguyenbathien91@outlook.com	237	f	9056397a81b50a544b6629cc1909829e3c51640cca8041ee92ccce05f71fdbbb	\N	jTGnRkuXDaGRSkA	30d48f96-8135-490e-8144-cedc92aec3c0	t	Asia/Ho_Chi_Minh	\N	1
441	thitcho.mamtom	$2a$12$AkGbPDZFEyUh1hCWbXcRZOZAmxUfC4JagpnyR7l4lpeklVMZbI0pi	thitcho.mamtom85@gmail.com	237	f	b6127b8750b4ad51890aded495773d9c6a0f32b946252ecc64b4506b56b658b7	\N	Y46w8XaC6iqE5Li	8f75bc83-9c67-4a34-804b-c020e8770f18	t	Asia/Bangkok	\N	1
442	gardemiwwel	$2a$12$oUxPsZg61BokLZEvax381.qBXx5pKOSZ6l2k1bzn7O50zwdp9a7j.	thierry@mona.lu	124	t	cb019646595c9d6059a3dceef072b0e4e5778f8ce4664a63bdb759b5364bb2b1	\N	4sUijDyDS2q8e2h	14d7e19a-b040-4179-b1ac-7314f01ac924	t	Europe/Luxembourg	\N	1337
443	KMC	$2a$12$ll7oLA3YX65n18GSxLhf4eM985ekOaiXUxEETJGB5/Epcr5HkGVHa	tyage@kmc.gr.jp	105	f	fd61530fd6db0aa532af38f3eb27ba01df298f4e50cc6c6972739d7302f6c94f	\N	HspMHOesUOX0MqT	32d5c5d7-d2f3-4307-98fe-5b9ad6678dfb	t	Asia/Tokyo	\N	1
444	QPURPISO	$2a$12$kWrUBTJChguJtdpMLg9AdOqIpIpoUON.CE27NjVf7aCtR5bke91MW	andreantoine28@gmail.com	74	f	ea1da0cfd1a129cfc031b37f1e7290cd5778da5f384b82ac070e9b84687eff36	\N	Wb125Sh7dUjdp8V	181b615a-4e5e-446a-a5f2-af307c290d4c	t	Europe/Paris	\N	5
445	noone	$2a$12$2tng79OCZ2j/bjNga.nLW.4TcGKuydYdWOS79Y69i5wWLuSnya0jO	thuongnvbk@gmail.com	237	f	121996f0fd768501e5b6821b7886ae9cec2e0a2fd0c5c9c5005e2141ecc8a8ea	\N	EhDBOkQWOYAxHW9	e6ed8b79-8f25-428b-89c2-ec84452200d7	t	Asia/Ho_Chi_Minh	\N	2
446	BoHu	$2a$12$3I2rAJyKVMjBtcGt0JsxLO.PUr8UYq.3BBonORo5ZtZci4VrcSj6C	it_for_life@yahoo.com	237	f	8719812e620ea80ac20ca8c16e48af284b280313097635901d71b39717a8dfbe	\N	z1tuLf2cz3xXyPU	a1a31daa-05d6-4d7e-ad38-baf369e1623d	t	Asia/Ho_Chi_Minh	\N	1
447	5154c	$2a$12$SwDEWYKCeCYej/7qz62P0OIHXs2ZXofvXZKJyx2Qfji425eOJhhby	janedoe.5154c@gmail.com	112	f	8ba2a88facb9bf28090c329da95c724371324f3deced1085ea411bb2cadbeedc	\N	h6aUKk7m2mZEETA	0e7643b1-f835-4f08-b2e3-a68277c93271	t	Asia/Seoul	\N	5
448	Bender	$2a$12$rK1Nlkz/V1u2vDf5qsugb.La.dFRZSXXLsUfK7VaMa6DZur8Pryxe	1749277@student.swin.edu.au	17	f	bdd479c1b6e37d6383ec55f756bb06f28ab222d7dd30a3d03de57ea77f587302	\N	86kzyuHDtmBbzd9	80a3f0a6-af49-4c6a-8222-5f1dc3356dfe	t	Australia/Melbourne	\N	4
449	hohoho	$2a$12$uWx7OZGz.CDkeCzvSOq0u.BlIQsjWz7JZTbpLJYgJv6kr5km2XBP6	hoangnb.hv@gmail.com	237	f	998e3c959aaf326ab53ab16cf3286b2eb56d64aaad3a2f1fd188b35449410bcd	\N	9lxJz9GomEEZ5xh	5b91bec0-9306-4fad-8ed0-a579a1cab194	f	Asia/Bangkok	\N	2
450	mg	$2a$12$oo2.gRQd4aOmQU/G9syiPu5ZpiyvCLqGJFY.oX7nmlrbSWhx3GJzO	nhc.chung@gmail.com	229	f	dab13a55e1779c2fe3e4770dbc8c9816d03eaf47c423c8c0d48a9578088f1d83	\N	aSt7lBuvwcCSpEU	ded0b81d-4c04-4cb6-9652-d6ff87872dd4	t	Asia/Kuala_Lumpur	\N	1
452	K2K	$2a$12$Dx4RWQXHVs1erMmsRg3jEueja/69OtFfNiBEp6Q7HGddWm2Zuw7yS	doanngocbao@gmail.com	237	f	f47302cbe1999c33ea6b598419cfa91fabf1b6860686068807148608f3b4a285	\N	MYhxuROZHPfTvU7	e9e1f991-71d2-41f8-aa06-bb3538a5d8ea	t	Asia/Bangkok	\N	1
454	mt3m475	$2a$12$ZFvqN.IsmcgzKSPAjjhcT.Ar1WYSvqTWjD3cvpEE/oCIASQtkpffS	sinouongsiro@gmail.com	237	f	2edb6afbb9a3e66461201c9fc9152b663f3d3e054946738947519f7e13d15ef4	\N	sUdPod7v4ad7zu8	9b2dc0b6-7685-485a-bf55-6961e765dc5a	f	Asia/Ho_Chi_Minh	\N	1
455	vnr	$2a$12$On/YRPgxkFveyzEo7.67TOplTmtNs3aUk7PoPSqJkBAszsqWlNOim	vn.rootkit@gmail.com	237	f	2b40a0d18ad8fea1768d50c203d2cf5191473dcf2feab167a92c1b71b80bfa33	\N	zeyiv4UjINVDRjh	a4fed237-a339-4411-aec7-024daacef60d	t	Asia/Ho_Chi_Minh	\N	1
456	popov_t	$2a$12$KPZl.exgTEex9Mu9ubA1tOKNNRw/YoTmY7M1TlPmsUINga.JRjtJq	popov_t@google.ru	14	f	0db53e8f3678a0ee27535e02a559243f23be86be18d477005684e86c2114d70c	\N	M22sECINl9glv80	9049f705-01ba-4d6d-a089-14606e0be864	f	Africa/Nouakchott	\N	9000
457	W0W	$2a$12$RcaNElMQV9/c5r2DGCEHr.k7b2IjAkp7nzIBV7NVkNZ.a0FJsOQiy	karthikaryabhat@gmail.com	96	f	71b3dffa55ff4ab65423a2bd3e6d4023c61b449a87cea1e98f1aafeb0a10fa50	\N	LmKqrVPzk3FXtLq	9360c0fc-3a08-46e9-b959-9ff8fd92e570	t	Asia/Kolkata	\N	2
458	not_w	$2a$12$jlY4MmMmnT/qwRHs8e0uRexGTWR.2c0bN57txdlHrZkVPb1psrjdG	bobrofon@gmail.com	11	f	c3d120afe5519e06fc882184ba4158989541daa3fc86f7e5817ae9d193651a8a	\N	6qWCGuHygVvqFjy	eaebf460-b39f-42b6-8aef-2afcfbb76a8b	t	Africa/Bangui	\N	9000
459	Claus' Thaler	$2a$12$fFTUamalXtpdUlJAwaPTeeuOatZw5NPqbJ8Swf8UfkPFJOBhe7N4m	ctf-ct@pentabarf.de	74	f	c8cf0da14b3a9fa27f41ae9e4708e8f13b630e25cc65d9c2bb46797efa9ea984	\N	3Il8NoCMlooYZFj	25ce53d7-91e5-4a63-98be-3ae468f90969	t	Europe/Paris	\N	2
460	TrungKFC	$2a$12$D0JYbNK/FhO3WKhCdkuXheH0GuydURcU333ZDhJj2TdmnT/J5F/YC	thanhtrung9h@gmail.com	237	f	f89fa9241b49d6b296129341d38a8933b4125f356b13b8bdf1f2e7a602b63f5f	\N	UP3VYxKkYPlTnl7	6de855a8-6e46-4430-aedf-78dea4c3bc94	t	Asia/Ho_Chi_Minh	\N	4
461	anon	$2a$12$hGyJ0oYxq/CiCidXAQlequY.xj4OOQXVC80CjPVszkYwkfUw2NNAC	angel_demon120@yahoo.com	237	f	b83a2ecdc8b9cf5851e5ffc06e6b3194b761ade65cb0671511e7c20a2b592ea3	\N	IOR5zMb9jyJdhNF	b65fa191-9577-4f92-91e0-b035445f7fb3	t	UTC	\N	1
462	nerdfish	$2a$12$2I0nmw2SSQssJu.bfWcmm.NzvCKqY5Za3xp2fiWI/uHJaLnpfCUiy	447313184@qq.com	46	f	78acf6b27204283a77cb3530681d06636ea5c675191dcf1a027f70b87a30a26c	\N	I6bDOeJkUmu16YB	f823eca0-af3f-4e0b-9067-2d3f039c0f25	f	Asia/Singapore	\N	2
463	o0zzlh0o	$2a$12$nV8eB126H8qY77lChYwJw.NH29qPqjoLKWx8xkLD4RYGRf5YHmndu	o0zzlh0o@yahoo.com	237	f	71da615db28bdc4b80025cde864f5efcc2b6c6ad474a8c71ed3131a14e629117	\N	MnvcK8RGPoSBjGf	845f08bd-33c2-42e6-be08-30c0d363f691	t	Asia/Ho_Chi_Minh	\N	5
464	xsojunx	$2a$12$NhnJx/tFL5M8CxSM.oWUaeluJE3V4AJC0r6fKaWlX84lfTuVtIlTS	kenvin.md@gmail.com	237	f	46e9e23fa29d59cfe7d0c087e13f4afce38065072d47a16b3adc0a4e1d77be4e	\N	cFIlNLeGh6U24It	32ecb1ec-a85d-49a9-988f-09f41687c934	t	Asia/Ho_Chi_Minh	\N	1
465	Big Tits Fans	$2a$12$hL8nf9O1t5jP2Rq3xJgYG.XqWAikDFH6wjzWqpjhbcqZTksr.Y.p2	team@bigtitsfans.org	228	f	c1eaee315c1fddc7ba9eeca55387f826161334d3d6b2e0c0a9182f5d47b35d54	\N	DWRz88nrTwpNOFH	e2902390-2170-491b-a9b3-50ae2a6bb392	t	Europe/Kiev	\N	\N
466	govnari	$2a$12$wXNsKMG29UJFnE2Qbf/Iu.SurMIB27e2R8694aCo/TpEklEJgQ8Zi	govnari@mailinator.com	1	f	bc11578e524d9e20e96af8e2869d8731159e7015bd80cf4ebd6f9f4fcf07ac7e	\N	n7859PhOYmavNrt	0bab9624-b633-4a86-9363-4fd0e2e3bfbc	t	UTC	\N	1
467	GinVlad	$2a$12$o89zVjbZyC01W5IdBlsofeHdpNRX2UqaEIhMcnZ4Yfpe5hxPkXlk6	kiki_gdc@hushmail.com	1	f	5e4f49e9282e5486d6718940e69bfb2b7c9175a462807feb1e7c36d054f7361c	\N	MXfK9896ZmlIdIT	565b4780-af0f-4cec-912c-0e8c348e3df3	t	Asia/Ho_Chi_Minh	\N	10
468	SNT	$2a$12$JMwF8vZX2m497P8L982nNu0WjFRlSO6Nz.FM5mfyeZ3u8v3yXSOOu	detheme@gmail.com	124	f	422ec2bd77351ff663cab05c18a7659f25a15390aad6faaf1944e78266c8abc1	\N	cLWwkZPUmUZ292K	b1f51239-b4ba-45d8-bd93-a5676f6a27de	t	Europe/Luxembourg	\N	3
469	mahno	$2a$12$eB5g0NW7t3pvXjNN4tWoXeghSWaigypPzUSYz2be3EGRukGrBD9NO	mahno111@mailinator.com	19	f	92c4b065c9de1abb42193186798e49ef51a2c4b9a997cd0db3461e464b58042a	\N	bLGJiAic99aUyC9	bc1c121a-cae3-40bb-9ba0-6a2420c97d4b	t	Africa/Lagos	\N	1
471	s7v3n	$2a$12$cB.O8CYEennd3YFCesFbJeiH7kLBQfXvSDyQIqJGrh60QB8EK8Q.S	tonthatvinh0201@gmail.com	237	f	6fa4f0e1351a024320ef9ef57074d2827a49457e3d47203ccdeb840677302518	\N	ctW7SSvRQ10S4ty	6dde90f1-1076-478f-b0df-a292aa860587	t	Asia/Vientiane	\N	3
472	GATO	$2a$12$YzUE5h.P5cMqyD7QSf1tTOmhDnxdIJbpVpmJeFLb7cjclc2cY2sHS	vni.anonymous@gmail.com	237	f	f2db567fc47a71cdcc64de421fe62602f85f0068ab91d0351c97e9088aa6be93	\N	YwYY1zsFQmK6DeH	23030ca4-1c23-4f2c-a243-8deb0cd9268b	t	Asia/Ho_Chi_Minh	\N	2
473	Stitch	$2a$12$kcijDzVVp0zqgHn7CLpN7.G99XM3/vAi8UVMCUezuyZmKQVLug5fC	hawjeh@gmail.com	129	f	1e603402991a68d168253c128c708777517e7c55e127e72574bb5b252a3db670	\N	7FsftvWaUH4i5b0	1a78ddf0-b6f7-4ab5-bb5f-b9939b044a31	t	Asia/Kuala_Lumpur	\N	1
474	just4funand2learn	$2a$12$RN5t8Pa9XTzV.MfHppMIluswpynDScb7abJEyqnjEToFPwZCXSqN6	nguyenanhtien2210@gmail.com	237	f	9f038e7e4bd3d6efabb6024f2aa0f0722d14e9c76a584f1fe993d5aec9c8aeed	\N	HOtIEi1RK6BKQmL	2e591eb8-3c90-4b71-8298-a7ff443c9981	t	Asia/Ho_Chi_Minh	\N	1
475	Eugine	$2a$12$hGsTPmogn1CncpMxoXtdqeX844owRi5xiTr0M7Ttm5JGfqUyGb21q	kendoiiihik@gmail.com	17	f	3fffcad755bd7a735aeb1034cc578d86006e00a3a6f01841a53b4b62834bb347	\N	aoYCmxV4KitYfq8	043943a2-4f89-4be8-b1c2-c577caec99d3	t	UTC	\N	1
476	U|\\|5	$2a$12$QUo8edjPlQBQ5rnyiePUwuExXkWX0GBxWGMVdvdmiW11dfaiMRy2W	thongngo@uns.vn	237	f	f5750a5cbb96c773c47182024fd5b99fdd48ee696dbf4047a12c3e72dd8fb709	\N	vBpM47MW2KQpv0M	43ce85b7-b538-48e9-bf1e-043cd2dceb8a	t	Asia/Ho_Chi_Minh	\N	10
477	hachzz	$2a$12$RbCZ84VACooJshzOv77RI.tm/Sri7jHonBBUyh2EGa3DcUEhWtSL2	hach_zz@yahoo.com	237	f	0bf5540edf977aa7a5322a56b9fa7c2ec56fa8f4006113589d1f81903fd4ce3b	\N	8vpeFepII4TbvmL	661bfc71-3e95-4cbc-ad3f-565b1ee8b326	t	Asia/Ho_Chi_Minh	\N	1
478	sayena	$2a$12$cIBiDSD6SUp3rtyMjQT1bOsOSQkBbztEZYpr2wbi1Pc7HjoG5eG92	nabz0r@gmail.com	124	f	0faa64a94d6749b9e4bb337ab5d0bd6f5119cd74303e667973b61242d7775cdb	\N	h8ggKyeNAv0YiVc	1a4ea9f7-8b64-4857-bfa3-d80d34376e26	t	Europe/Luxembourg	\N	2
479	poulpy	$2a$12$/2Ka4MkSVPP0Ur4GFF4ose4XuogJXvxjZHgmSO95qgKleJ78cixmu	jean-yves@burlett.fr	74	f	ed5546532e87b7bab42cc0e1af5dcc122ce8d53a3fb9b6cf06252547b83df718	\N	ZNKS3t6N5IObOY2	f586f6cc-725b-4314-ac77-04cc9fe89dca	t	Europe/Paris	\N	1
480	dummy	$2a$12$YzbEPwJOaepf1qvpSTzA3.5GFXj4KS.pQK2FcYgWTiY1KDdmLkjXu	dindeath+fluxfingers@gmail.com	1	f	9f279dca543051c8001b112197334226bdc75f9f0c60da073401bf06ec0f71f1	\N	Wkn29fNf7lDvUbI	a7e12137-8bb7-4f05-a3dc-d56125b79c2d	t	UTC	\N	1
481	n3ver g1v3uP!!!!!!	$2a$12$lqs7OLnohZ9/uhH732UdgOh19OfWvz9v6mnQjgLyUGk1yKHlvX73u	tokyo.i.t.s0901@gmail.com	105	f	2af29f5ffada9bc8794e07bd72b11a0c5594d8877bb5f67d60c8abae2a066e5c	\N	q0rgVQgA3QNHRJ8	db3dc8cd-1fd0-4e9a-8656-19c84373dab4	t	Asia/Tokyo	\N	1
482	dklp	$2a$12$EAMSfkD.ntVTMymrug0eIeobokicdbF.3iYMr8dBhudMrKbux9EQW	nguyen.van.hien.cdtin@gmail.com	237	f	fed9190c6c784960ffa31c217817d7bc4971bd295ffb99497639cc6ca2a682ec	\N	1EuyzdifqUgp8UF	d5b15cd2-241f-496c-812e-61cb49c4e1ae	t	Asia/Ho_Chi_Minh	\N	2
483	second_float	$2a$12$Pwb.ZdlM71NVYTJo8lMU1.2ffk63e2/bYvz/w2iNds7fqbMFh.eAG	eathwonder@gmail.com	105	f	ee60ec3eafc241cc7dabfa0f65db8f372e7b780030d609c70de988052fae4ca1	\N	ibiNthW40mj0b1e	c5bb559d-d1f5-4e8d-964c-8f12e8d83e8e	t	Asia/Tokyo	\N	1
484	nani	$2a$12$q/FYPNEQeZ0yewpERJMT/OUcY7dj0o2dZtmqfx0fWo4B0wUvjI6se	nani528goodboy@gmail.com	96	f	984e3f1a47c5611960547e7100eed308afc5124476170a8b14a3d7cdd3895537	\N	ByeSIb4dLlylox2	ba0ec783-eaae-42fb-8db9-94af36561bab	t	GMT	\N	1
485	Eagle	$2a$12$C0eeWNALe1ob0oclFwuZ0OrvIvV2ryw3gVP53Rf1T/NqQNiM/RbQ2	madguy92000@gmail.com	74	f	17d2cd9990c5f283c6c8db57910783061e39f2c4f33c443f9737083fe9ef7426	\N	rltaMUKgdobTMV0	c48bdc38-43fe-4722-ba10-2c6455ba1df4	t	Europe/Paris	\N	1
486	Only_Eska	$2a$12$7hRBjZatxucuxXO1hCgoH.Cl2hyFUgjQr.KJ5qKEYwK2DP/VAm3Ke	petrakov.oleg@yandex.ru	178	f	bc82a0bd92b1f75b9aa70d4f47486f6b6cc81442152c51c803e1798b917deee4	\N	4P6LXz7AONC3pny	907e8c1e-fa79-461f-a0c2-d06ffd420fb8	t	Europe/Moscow	\N	1
487	nol1m1t	$2a$12$cg0I3x1CoaPItHvg20shHOvAaVwsr1RsRWgNkI/O5btP6Hy7TVh76	ovjeparvaz333@gmail.com	98	f	2df23ebd637c08e6c2d99a0caa7b8d8d7afe0e7ab188a0b7a2b52151d1011cf5	\N	pmesbHAimHmY9yj	b50960ea-5126-498b-a97b-9f4a271204fb	t	Asia/Tehran	\N	1
488	Silent Patriot	$2a$12$E4Zu3ftf9fNsaD896DGVpeah7XWirnX1cS/sh1dGp7qNYTsmwwqve	chakri.361@gmail.com	96	f	c43cebe4bb6ff1494cd6ea418e64adc7dbb1afc46c60264c0b1d07a4d30a7231	\N	XLsmsILOb2YXnTu	6c71888c-e26a-4b7b-ad4f-ee7145af0b83	f	Asia/Kolkata	\N	4
489	TheNormal	$2a$12$tT2HNVhn9d.Fnfu7Bn4OFuz9s241NpKawaaGzlUi423rK/jUQCNjW	iamctf1337@gmail.com	237	f	b1a558f8bacbd152f8e77f988cf67d76956783288a556f2c9f596481f3afe75c	\N	3WRrxhqJcv5PJAO	d9f1e4a9-afbe-4e76-a7a7-3f42f360f448	t	Asia/Ho_Chi_Minh	\N	5
490	wtfvn	$2a$12$Z3t0pS.7BJQsoqyIvtwmG.kzLkfpj2I5kXUdhVx03Iw6YsrLjKLIm	shie@mailinator.com	237	f	1919c9979d423dc8fb040ff1adc4048ff9ea66b5f7e0351aaa978444a87bac73	\N	27rEO0pp42otXXp	279c581c-9d39-4a4f-85f5-79a3552f32f2	t	Africa/Cairo	\N	1
491	Mwa	$2a$12$.4cllU5qrN9Hyw9T2dPOBexuVuL1y.zq.cY3v/e0pWiSlRzRMEKHW	qm1382437229ddz@mail-temporaire.fr	25	f	cce8c190f350e7514c3723d6c8370bd73017eb776dff9cad174480b51e4a67a4	693750d8d363e3eadd420519f3d79e52988fbe0c6da0a19f4298368599911e5d	uu42U4087CJsVbF	f31b30ef-5652-4e8f-96ed-2cf6d3654d3a	f	Europe/Brussels	\N	1
492	duynp	$2a$12$yWaFXxbTYPETwdRAfPD0.uMaKHRk58HOOO3PBJNqnX0zfrX6HAUAO	duynp_kma@yahoo.com	237	f	94abd192e81c9c1747b7f3308e9902c875092f40f0fd0a4b8ddc9676be4a4620	\N	zvbHwuaVmoUyS7D	779aad74-0396-4903-8a06-c2b3353ad659	t	Asia/Ho_Chi_Minh	\N	\N
493	Grok	$2a$12$XpAQ1M9U14wHl02QikmhuuxZhFMj01ad36sqXJhk4NhsvOqdp6nAS	jndxxh@gmail.com	46	f	067636ddb11cf866cc6c97c6b23fa4ad8e4ee0449f5566e1846825186c26048d	\N	sC2bP1AM7sC7IKr	3600ab79-d951-4ea6-9119-74bab2610285	t	Asia/Shanghai	\N	3
494	Misc	$2a$12$ldkNrmMIDmzcUvytSbQz5uptXFf6V.n0QQJz83yu483P1/s1K/bvu	chris.schleypen@gmail.com	25	f	3f91464eb11df1e2bf0648e38c1833a8d0ff6c36c392cb97d2008558f42562b8	\N	vIB32g0qB0hnxKB	dd1f1810-8f23-4f5c-8f9f-50b80bb3b266	t	Europe/Brussels	\N	1
495	eragon	$2a$12$tY13jzd6RFEuX9kWEH2CcON6Ia/nX4mSUCxSfIA1RsKkToFgTuhe.	sonnh@outlook.com	237	f	f7edbc43fd5d37a1d757a4a9a6f5cfcf97bc15532ec45413e06081281f5461d0	\N	cx4IClVStBOqOO6	5cccc454-cccb-4025-845e-0291e364e4c8	t	Asia/Ho_Chi_Minh	\N	3
496	l4wd	$2a$12$ZarDHYuIL9EorYuQ79JqZu2aOXzqIxcrCykm.rLqeHqgUoFQjRBPK	admin@liwd.cc	1	f	1b7a6d6f471c903c4f8cf1e094fe8241a07233e2376650cfac50019c9fb57d3a	\N	1q8a8k7GtaOAN1E	6e47f05d-f859-45c9-b3e6-93a9718d321d	t	Africa/Abidjan	\N	1
497	c00k1e	$2a$12$t1ea1r3hbpctzV6ryAMVq.YQw7l95vApEitpLD9RVjAlD9Gms1hqK	c00k1e@mailcatch.com	1	f	0e8a6414bfa62b5c050cf2474a938677c24b2b25e95eaaa02666b5e0b4668922	\N	ZN2phJufcbpIWi5	eab39a49-fabf-484e-b6c3-ebecbc0a6500	f	Asia/Shanghai	\N	1
498	HackGyver	$2a$12$IKNABF178ltkZbxk4R02.eFvQj6BE3NyRp498..kLcdUGyedd9VQu	contact@hackgyver.org	74	t	4d513514be1ab554963436f2074c43c99a2e7a86e9215862b18104166edfd64c	\N	G2pIeWpwJnLcWTC	bd8f0f51-2c9b-463f-acdd-599b7eb11327	t	Europe/Paris	\N	8
499	w1z4rds	$2a$12$cc6.JIG4mSWqwNgsW3QvFuD0GNrAumU6rv4JFtRpiDEREaX7ZSr2G	avinash@avinash.com.np	79	f	973a5704fabe2594ccdb36bca31e5d9616610843b45ad3947e5b744128822b89	\N	ZZnXV0c3HZCao2X	c64ee5a1-a458-4c60-a2ee-215dca48843c	t	Europe/Berlin	\N	1
500	Brainiacs	$2a$12$zcxhySMLzPpY7nDIYzogb.bZ.blvFRvgmCZAEUZzIg4oF7p/5Z4o6	saibabu.bsb@gmail.com	96	f	ff1aa660d73e63862680666e858549fa6d995a1d35fe4858c01a6dc6c3fac01f	\N	XYmhx52FhFWneIk	caafa95c-a816-4f78-b255-6cf4a6ce91fa	t	GMT	\N	6
501	xomethinx	$2a$12$HImdZCdKYOGOYMxWq1.wJurIt71swMDRTdeRYQz6ag2w8yQ.MoW4y	synchroack@gmail.com	174	t	4028a9f4a7237260342f3f79765d00ebc3c3c9cdbe6ae6f956dfdfcc32cf6dca	\N	8l0yyZkb2j7Wzwy	f0f02a74-31b6-462e-91e0-2b8c644ab912	t	UTC	\N	1
502	Team BK	$2a$12$Sdv.9fsatxQAk8Uiucu8gu..k4GxPzOLsdDzOmFVTFAU4PAmVk9Ve	arne.swinnen@gmail.com	3	f	c2ded92912723ee73400b9b6fccb25d0dc7a7e40d5066f1b108ea74f730b425d	\N	4z42TOaeoDnsTDw	6b0fc0a6-6890-45fb-a506-9e6851d2191a	t	Europe/Amsterdam	\N	6
503	toto	$2a$12$BYxUV/x9yT7d9l76PUuSceZDnQKTo2jz/OGnWTZc9FCJ2U9dyZHry	temp0rarytoavoidproblems@gmail.com	1	f	c5d29b1675663c3787bab5e4706a0ea99bd21920f1e6f8195dd45f4f0448d9a8	\N	WvlXUaQto9I5lMn	843f396c-c3aa-420c-a7db-d3fe2908a214	t	UTC	\N	2
504	watchout	$2a$12$/btLRWrdf2QI.fiAUr2mc.2BNs.503uzkCCN3Z7XqZ/DfIjIniXvG	gameboyjun2@yahoo.co.jp	105	f	d4c36ee021790ab596afe93cd13ed828bb0d8849f2814c02542d04984804aa94	\N	tecXSww240Vcsiz	e0f68e5b-0e82-4097-bde2-6147e1976824	t	Asia/Tokyo	\N	1
505	Autrion	$2a$12$4KmNdgl4fu8TYKizU5sdReYQOiVcncy3YzqrlR7R8ppFg8gTcumUu	autrion@yahoo.de	79	f	9919d6c8cc5a21c57221a61e90dc0d9a0eb4e950ab3abd83de3ad1b7b66360af	\N	KoSKZR5Cq4lGYPi	25be1b55-694f-4beb-80f9-ba28b7501af5	t	Europe/Zurich	\N	1
506	HPU	$2a$12$NVCA9xfwxNh6Ty5jgOYjPO1gUR4k9wjovOfqYRyyWEELz3W.fCVVC	mr.iltf@gmail.com	237	f	116d6e94d30e45d2782238f12962c6842469154756aa5af36b53599abf65fd97	\N	UgCOgqstsuVW2Vp	a2e00767-5818-4b88-839a-53ce45a658f2	t	Asia/Ho_Chi_Minh	\N	3
507	Ramen & cheese	$2a$12$LhizoZYszilYEGqyMPoc2.9vrkKboiwh3J8voO2yBTBxsuO2xUmA6	hognus@gmail.com	74	f	1d66269362e8cac47e73bf989fd74b6e3685e8900ec8d7876e31c544b91d1398	\N	qzePOHue4P4oyls	9304be12-b07e-4f6a-92b6-b6751e9d25cd	t	Europe/Brussels	\N	2
508	PNS	$2a$12$R22xR3GzQCmaC3UmLuMSResHTWsO6IO7YksfLvVKunRGlVVBBC0ve	phuongnam@phuongnam.org	237	f	03a42bd4f81f5612a7f963f67556fddc91d2239c03518be4fc86b0b41fede4ac	\N	qDckzGByrQcFTT4	986224c7-11ed-4c0c-bab5-d33e05d96d69	t	Pacific/Saipan	\N	1
509	Uddy	$2a$12$Azo11uUxznj6lq94lhWeYu28mQJT3wDFg5uMVfDpZYN97X4jlExkm	uddy@w0rm.me	237	f	643ce5dba3ababe0c1650d419fd813529054fb4efc0c61e5cc0ce5f081940c3d	\N	lcqSIkP1YUOrIlj	473527bf-7257-4c49-b259-584b5f76bd18	t	Asia/Ho_Chi_Minh	\N	1
510	Joona	$2a$12$2XHzqx3dIK0YNNAUKsgkv.FgvWxp1.ZBqKxkTlhLyfBx/1h0j7xkm	joona.airamo@gmail.com	73	f	9ba30c65c4d85f9667cd5eefa461a522cd2695cbac8c3a0e10420205eed1be22	\N	lKWnvTJATJvsIuR	539fcde9-fb62-4a23-8acc-ea0335cd133f	t	Europe/Helsinki	\N	1
511	Li Can	$2a$12$vgOVIRsRPBQ5sRbwmP4IFuHayObd5MFN/SbYZMWu3uSDjueUN9FVO	cameronjn87@gmail.com	17	f	eaa710f09a417d59e732538209a5b0510399af2e71bd9d4bd21eeb6b6268b9f0	\N	PI8d8IGNSWZavGD	02664c3c-2fd4-43ab-a446-16ca31e6fccb	t	Australia/Melbourne	\N	2
512	sighalt	$2a$12$nq0Ucu9qwHMWzjZBnVBbEOIW2hcXmufWXMkyATu4bj3IOeEO6IIdO	admin@sighalt.de	79	f	9f8976ddd01d32827e628657cbdad87927d0fe6214cbfa2b05c450af2533e331	\N	d67Lm2EIf4aPCwM	e971302b-9a49-4369-8622-7849f00eb648	t	Europe/Berlin	\N	2
513	an0n	$2a$12$lnSEIYjw5w7L7McRfWM/5eP7mUl6CWrAGggHHVIpar0thdskCJ3GW	an0nuk@yahoo.co.uk	230	f	ce37b979f66b06da4f6b02844853b75d17cf1279fdee468e33aef607041134be	\N	8ahClBJv9CJFR2h	9d6bfbb1-af4b-4429-81b8-50a0e298cec4	t	Europe/London	\N	1
514	gamers	$2a$12$sqHeO2C.MYlsXNQpFh3FBe/FM3xIeDGnYPcE8tB2Rgw5fm6PM3BHC	gargankit0123456789@gmail.com	96	f	9b08df5cd6c3ace77a7964a27aabe15dc52837c1458dd95cbf6a9780c45f91ca	\N	bCQi8YuQHe732Td	598f76d4-77c8-4f7b-9b7f-f9acb08de784	t	Indian/Antananarivo	\N	1
515	timanou	$2a$12$ZIuIkezOolCrUOwOka/0cO/8vDFt88f3ApJlDWZKMNsZ46J9qqkkK	onemorebtc@gmail.com	74	f	c59d0676a784fd998b24d3787656e766e116925a5fb7dbe97c13a2040a66991d	\N	6Q7rkvJ9s28SNHU	d8c2f974-a153-4da2-a45d-11ebd0993d0b	t	Europe/Paris	\N	2
516	malwareksec	$2a$12$rjTNx2ZBqrzmk/av2LWTk.mp35yWyMZWzL4o5cxq25xuFU4hCm7iC	quanglongle913@gmail.com	237	f	86252e2dbfd462fbca7bf0449db3be3fc5cd66b4ae67becf0ffcf1ea9c51e5b1	\N	kwLlFzTUANMera4	fec5cd73-666d-4d26-be28-bae71719292b	f	Asia/Ho_Chi_Minh	\N	1
517	S_Team	$2a$12$sBWEIR4cSsUN9KXSGz1Xou06XMf6VTP1epmNR4Teno1IDvsHywVxK	sags-info@telindus.lu	124	f	5e658bcf7217cea767a60cc6315b56abcddbc5d2e607389dc65347fe8cec90e3	\N	Z0CppxuLE0Wjtgb	875e84a8-5e00-4124-b28c-045a9ab946be	t	Europe/Paris	\N	4
518	deinemudda	$2a$12$NgUkrfxJeeSt4t8hifLw4uuZxJVs4HN9.RKKOXD9nqrnsOQTKm0im	deinemudda@buspad.org	1	f	7352c6fe3f2a7562f2cbc0983ed1e4e633300ea70a764b5eaf8356d2a32e0394	\N	VI8ASUoenza22cy	be2184a6-e722-48e7-8e58-5dd671ee403d	t	UTC	\N	1
519	logicalway	$2a$12$iK11ARes5x0scv8MUjBgtOEKjvpTpQ9gsTI2LFbh8jfRs.XZrQ2N6	phanthanhduypr@gmail.com	1	f	a5c2529db2f24e531925eac26a89e344cff3e26ff3d2e91684881e4ff12a6108	\N	0wOaIYVbkeNes8R	fb7e7a30-bb3b-4776-a4ec-306173ecb472	t	UTC	\N	\N
520	PwnDoRa	$2a$12$FqiiB8cRdi8B.8YzQbzRc.N7aVU5CmLGUbHgcnxhYMnlRhz/kCDPu	savior_minyen@yahoo.com.tw	1	f	a9bcb8b003fbec4b5fb78605ca2f4cca9fcc7b8b22ff41368065d47f16049ce1	\N	1Uzn2B00UOKN6Dk	f0c37f76-d0a3-4438-83fe-1bf49630bec9	t	Asia/Taipei	\N	7
521	FIXME	$2a$12$I/p8UVF4K5B9OUE1//bcDexKGHMGKhPti5U.PyHO.ixppMacjT/Fa	ctf@fixme.ch	211	f	9bf1e95a9c7656309ad2c3b3f1cf351d8660a9780eff228fa038daa955d03d27	\N	Cj8ctGab0NbFoR6	b9bc2d14-ef0c-4a82-a329-7769281f0e50	t	Europe/Zurich	\N	5
522	natsugiri	$2a$12$EqkeqZ8faja.2gMviO6uIOETyVlJjvvb7o5XQoMddyPWOVAnsfrMe	natsugiri@gmail.com	105	f	03fae5af6ff5a6dcc53a55ca381d3419df16538a634d8d77772e7bb9558cc6e9	\N	MONisVtt4wsd3N8	d3737e55-d328-46db-bf65-b6b3d01b8c9e	t	Asia/Tokyo	\N	1
523	Aether Shell	$2a$12$R1xip10hIo7e2NLBhFnHg.5bQuqHSgCfgf4SLM7gFfyAWoGDDLa7O	aether-shell@googlegroups.com	230	f	77602f2b36664321b68304cbc2a78123a332a91c931ef71d88d236207e880664	a97d33eca3f2aaf1dccd1a8111d42b2f9ef5c3e5730ab87877707af812d1af10	AUx0VvxrJj7thT9	b75dff0c-feb4-4450-bea1-ec8187b2bd82	t	Europe/London	\N	7
524	Me Alone	$2a$12$2qNIHxTThzsgJfEKN8Kai.gddyCruUxbleG6YwFLVQjwjzjZHRqqe	dtx_2503@yahoo.com	237	f	7225bfaffbb32d1173ceaf9bf9eb676ae6b70071fa131ce2b722cbac4f426d52	\N	d4AA3cgVWcVMOyz	14708ade-bf29-4c23-af28-3832ac6f4bf0	t	Asia/Bangkok	\N	1
525	sonnyit	$2a$12$in/ZyiI3ucOvaBNX/y6/9O8pd6qpw5Wae5qmaDO66VXb81QRt/sqS	haiminhtbt@yahoo.com	237	f	88fbf90f3073632598fa2c526f69c8de1fdb70996d5a5be6f6491ab815430adf	\N	pmfwmw3OXJuKMbW	d6818ce3-0cf9-4282-aeff-a23c8ffbc592	t	Asia/Bangkok	\N	1
526	pwnstars	$2a$12$W7LmrRu4hnGqU0lvYc8R0eh9b/xcxCsBbOSUzSu3WRBAAfBB3Oem.	pwnstars@failserver.com	162	f	c944224c4520312b44b1ee298ef4551c70c298a21062951c57a2aaacc72c3bc3	\N	O3qfWOUJ5hfzaCL	48ecccb1-4963-4bdc-972a-7948a1b185af	t	Europe/Oslo	\N	7
527	ITCrowd	$2a$12$wpdd6uS/IdHGBEw8LW8Q9OB0pzkkY.XHHZVzrhkz5aTCLehBhmM42	itcrowd.volsu@gmail.com	178	f	366bfaeaaf1e5d67c26cd99a1d10b2c2392b0295f13fe83342b1f31d325581b2	\N	GWJOyIcjipkEGNa	dd37bbde-e339-4388-90e4-8a002a757e91	t	Europe/Moscow	\N	5
528	e4gle	$2a$12$Xwcqc0ah/xHfB6WjSdLqCezLkGU/YIqhyLGym99Bso7s1a5ZAtoUy	eagle_heike@yahoo.co.jp	105	f	626e141798ba5d4d53000bd83e14a55bd824cbfcdc5d24bfe1f48a0c26cfcba9	\N	ymoUW7Kg7i0Cj7z	85aa1ca3-2806-4049-8ca5-00ed863c0d37	t	Asia/Tokyo	\N	3
529	Gacon	$2a$12$nhDdhp2PCTvSNJcvLtMfBuLiiGhBTziXe1weri7qwOpDq2XCoFTz.	pantez@gmail.com	237	f	e667cbc891723d05304fbe456cce2e5736fa7c019fa8554142c723087a2aafc2	\N	aJ7eoVLnoWPOzpS	e5471f3e-9d56-455b-960f-0c4eec818d42	t	Asia/Ho_Chi_Minh	\N	1
530	PizzaEaters	$2a$12$D3ikaFtDPu2kTYUqJjUR/uX4rHcMAHIxvUid4ToBZGOZKRXOXU/8u	pizzaeatersteam@gmail.com	33	f	13622ec9004b36600703be6d99ffc276ee4597365015fd79ab7c5b427ffe74d8	\N	due1pbNW9NwptW7	25e59202-7fd8-473c-9b85-328af7f773a4	t	America/Sao_Paulo	\N	4
531	Famosa	$2a$12$K.E0ISRGbSd.hXeOVbv3Mezds6.ePNG.ZX2NUYjjL7UEtbvOrn2.y	kellyknaken2@gmail.com	74	f	94f4ab89f46ae39c6bca0e0d077e3f138cfc04fcbdff1659f2a2853b2f26ae74	\N	sQdJWLqpqMcFsHK	88ac3e53-6df9-4089-8b52-27b88fb76078	t	Europe/Paris	\N	8
532	Venkat119	$2a$12$GmGDMthXZqYn3aahfzr..elaC2IB2i76xEbs6kl5CJsYg/Mr9R4K.	venkatsanaka@gmail.com	96	f	8ec443f96025b48450b3b40307d0478af240b1e881181fd236becc3b196a9cdd	\N	SVyjzIjr8IyPUk3	9f7a3b81-7817-4f9a-8481-f87d005f5989	t	Asia/Kolkata	\N	1
533	Napster	$2a$12$.IeiyHeisLWHj.rnPU2zEe08prj3/ewjihVdEIQGOtvpe.31cTIYe	napster.70@gmail.com	98	f	8c8888ecb1f63564fa491b720720e65427946920d3d52e63987b4eb76d05116f	\N	jC0qchWIivikVOV	4cb8c9bb-0fc3-4167-b3c9-db62ca42ed1e	t	Asia/Tehran	\N	1
534	BugNotFound	$2a$12$NkcqqQObtyw3CthUNv1xeOn5jQdaDBXZM2PZ4lgU66xBw3ngwYkiO	danilonc@bugnotfound.com	33	f	212ae44e8e3526ae0a277c241f2e1ea1fa97b97bceba9fe797a12d48825b9026	\N	xMPaPMfGLi0d2EC	b3d45ac3-0ca5-4bf7-accc-372eed207b8f	t	America/Sao_Paulo	\N	1
535	BinaryBandits	$2a$12$Z8gJhPJXiQU/lEccNuxOHegwxuEwFZp7pFio8iw9pFk4eC/.m99FO	mike.evans@pentura.com	1	f	e426d6561c56a813100c7761f18eeee5160eb55ed92b06decc743eb452a0d47f	\N	aArj9IdYeSWQIZ1	ef2a72c1-4d77-4af2-9822-f40457417294	t	GMT	\N	4
536	BrainStorm	$2a$12$025Y1AbupjdICcL73nUbMu./7XPTxX6q.G1xjf/xx8t3hDh3aTV6q	michaelna42@gmail.com	178	f	7ee3f3490c24816f5455784bb446c28e0002bf3da0897b6b6c75e1823e128cf5	\N	p3cu3cf6Yk9EEc0	a04747d3-91e8-4441-8012-0c0b478dd6b0	t	Europe/Moscow	\N	5
537	ESICyLab	$2a$12$1ccrU9Z/6PnJzoNQH/LDuu91ahxG7fq.U3Tgo6NW91Emc26Fr7gYG	genetix.ssh@gmail.com	35	f	beae8c037d360a4564275fe1e8961347d39ac92b888f96896f1fc7cd1597ccab	\N	Q2BGUjefDkO5mei	00c52bf8-8e06-4c28-bb52-e3781e59d8a0	t	Europe/Sofia	\N	1
538	blablo	$2a$12$PaO30T7LOm6BdPhwhCzxsOurngmzycZa.OW/xkOg82y6KIIsQVh.S	blablobli@yopmail.com	70	f	6d541f8bb777836ce2fcf85f2393f9f26821748908d7ff72068d625806bed3c4	\N	dTIo3zzxIE3InZp	9d8c7a75-dca1-4b9d-8197-cd9c4993277e	t	Africa/Djibouti	\N	1
539	teamtodesschnitzel	$2a$12$umy8K5gwOeNxCbik72TOiOqO4M69VrQmKdDellTe4Qb4/hY1MSsnO	teamtodesschnitzel@discardmail.de	1	f	314c684880878659fb79b69416ee6de998fe8527b740a9d9f271847f7888a427	\N	u5zDdCArTcwj71D	e6e2c59c-63be-4ca7-b467-27f5bbd3cb5c	t	Europe/Amsterdam	\N	2
540	Team Reboot	$2a$12$9j7ZBkVQ14itBRZHkI9nGejguEH.l1LfV5hrSrHs7rZ02d5uh.YrC	rebootctfteam@gmail.com	79	f	f054a762aca1d5363e36c93ee52d357c3ea5292fd0f7ee6c2e4572f50134295f	\N	Utx3ebW3ZqvgLGg	e61f7a53-4bb9-434d-a7b5-d861e07ab764	t	Europe/Berlin	\N	5
541	DAFTHACK	$2a$12$8GrfhSPyl3iez8F4T8dAZ.imncrVaTd9Nit/yCjJYFt1uNbIhifO2	beau@dafthack.com	231	f	3542c760fbaacb984cfd1b00c91639a5aed5fb5ae2632edd682f6c6b8c8596b3	\N	dKsGwVJ81XetqJJ	094eca52-1a42-458f-b2ae-aae96343550f	t	America/New_York	\N	1
542	AKI12	$2a$12$/bqn2s48JBuMiFZbDmSyoe4e25bGzW9nopenproz6kpceDJePBQGa	kaisai1122@gmail.com	237	f	7ece1cfdd3d07c757770886bcb8611bb0b93b8cd54a23fba4a497c96af6ca44c	\N	CdWpe0P3eaSh2UT	b6686e4b-e1b7-49c6-82dd-22f205ca5480	t	Asia/Ho_Chi_Minh	\N	\N
543	magvN16i	$2a$12$IxO7nlLbY8td7QHHWLM5COtrp8j4C4kPGKIRSOTgjqL6nUPukqTkO	magvN16i@devnullmail.com	1	f	0135dddad5fd826276f2f6bbe48ba964eb48986bbb1d88892a1f27ae88ec110d	\N	zxbqA3oZhD7ndyI	703d1ee0-e0fd-48d6-922e-04a7d9994171	t	America/New_York	\N	1
544	noob	$2a$12$l3.41tCYiKmoIP4GwMEFV.Dk2f7rqKZPQGQYPFoJ0RUvrbJey5kcy	y.shahinzadeh@gmail.com	98	f	1d35a480ba5fc10f3e878c19e3480e48d5403e4529f61d18937f97716067cf80	\N	tfr5gBvZtsifbbB	fc66efd4-a06b-4e3c-bb92-292bac53cef7	t	Asia/Tehran	\N	3
545	givemethescoreboard	$2a$12$tQJ0gvxmYnA6BM0niKB0Y.ZXTMmhhPXu69uLajMjgupk0h0tgAFUa	cs-gmf@gmx.de	20	f	ec53a134fa944e642aacf654c39ca419cd3243f307b4531a34e2315aafe0865d	\N	yfRA809hKAWoSjz	fa9e9501-6b97-4500-8cee-43bfc64cb373	t	Africa/Dakar	\N	1
546	Josis	$2a$12$7EyDRyP9EYRnHRfMWaTvVehdeMcMdCIMVRbwILSx0yk6a1lIq9Nxe	jschaack@web.de	1	f	7d154d789613684a87fd7d8cc832a1736082994283daf8f16681178754bb7a69	\N	VPmIcJ9kzp6SOc7	f947a9d5-f4c2-41c0-92f4-4c49daf410c1	t	Europe/Brussels	\N	2
547	c0rebug	$2a$12$xBRm8iUh7aOTaA4Gs5YUOu.5UZgwV1qc6ZtrhWe2Vh0FRmC2oHlh6	dauntless@dauntless.be	1	f	0ff8a7606ee1c5cb585b047e459ad655857f105643fd3fb1dc14910120748373	\N	kp6mtLo7EmOfUFn	e74222ff-4935-40e5-a3eb-ee1bf28f8613	t	UTC	\N	2
548	TheStorm	$2a$12$QdxaEG4P.P1l1X6WqG4lvemi6SnGdGtqf9KU46A5DTdZbl8JcNO36	khahome@gmail.com	237	f	911d234dd0b7e124e5f0bb3fe261c9d7645139310a14b0c3d003b34e0364edf2	\N	vMLYExco6JexSFY	fc219f9a-8323-44c9-b64b-6cc97f3f8484	t	Asia/Ho_Chi_Minh	\N	3
549	Blue-Whale	$2a$12$vDaCsgRZqH3GVwu.hKe9ZOBT.O0tYKrlNYB1ybh4px1DDFi6T1v5e	fanrong1992@gmail.com	46	f	b9e52915def7aa602b78867d47fe78b15338ed7d7cbec9611d71778bf3722bc9	cb1cce371114431be10a16ebeac3ff00a63c667668696a3304d804fe4655d2bc	SzeJ19gDVskgaHJ	5578d7f0-6fc7-4814-924a-4e5432c677ad	t	Asia/Chongqing	\N	8
550	spb	$2a$12$UvGqj1gIgE5sZFOfNI/CdOY1c.NhaZEFV7lW105eLMPFydetWL5Ky	2010spb@gmail.com	24	f	963baa8a77903e1d11427f91eae4d66fe3bf85b2750268242cdf36722bcffc66	\N	TWcgpLgLIHPjbwH	3f702af7-2911-4c42-9071-c4e618c45284	t	Europe/Minsk	\N	1
551	HEMAN	$2a$12$rOPxROn1SLDdUbZS1YSjLu2GD2cPuBEiW9EXpijZa9/FK0oYnjZg6	mehta.himanshu21@gmail.com	96	f	14ff47da6baa4e2cd7102eaa02fd44be72af266a6e3e3bd3416a984e0bd22c99	\N	Lgqwu0YMKNBnq6F	2330316a-56da-43a4-be81-b996fb9d24a7	t	Asia/Kolkata	\N	1
552	hackeriet	$2a$12$qhgMXJU4nbNajraozn0q.OacG6ImrSjecosVDGp9jTl9/o.d0yxB2	juicebox@hackeriet.no	162	f	a873d539c040afa79751f81a019d43c9985f1d51a47793881b0e9905e958dde3	\N	lFLGbXKlarQz8B2	e09b8ba2-9400-40c6-9041-5199f4032a2e	t	Europe/Oslo	\N	2
553	FlagRunner	$2a$12$uhID9U4DFeRwaf.geLCvROs21CdYg2Vt58DqVxbiY6s.j3Z7uaLZu	lif01@rocketmail.com	74	f	3c2130463771cbd55a8b26147404050b6ff56bfeff6bfe9dac477cfcba115810	\N	bSqclo3o2noTUFo	6ecd008c-707c-40a4-a24f-c2f64dd8c01f	f	Europe/Paris	\N	1
554	4horsemen	$2a$12$BH323NE3T9fcnIfbwvkSYOXDojKANL9E8Is0wNjeIulrbqWc2M1ye	nikvst@gmail.com	178	f	5e4e0e1630cdf38802d99c2bf6bb2b0571c68035bcffae9baf03a64c8a67d018	\N	CSOfe9Cs0h6tPtv	f64e524b-5d59-40c9-a60b-ee5a73998ea7	t	Asia/Vladivostok	\N	3
555	Honey Badgers	$2a$12$sCstmz/2lujZk9chLc5l/u2ujcbkrcsBuDjqZqTrEx4Hjd1fDk9QS	jdavis@sigovs.com	231	f	3350afac668c28341a30ecad8d4e18f287d89b0aedd183360b3de81d8781c90c	\N	l78CO29goJzs1zP	548310bf-b269-417d-981e-cd5de9296df0	t	America/New_York	\N	6
556	Liana	$2a$12$JCAMcUsGxw0TFbEx3mv.tOA/fC3mPeagFsra1WVPKKlrWwIMRZrIW	medeja.bloody@gmail.com	178	f	28dcacfd0fbad55d93492bf899c8ccadea1e9ad9ff13667dbbf34af4236fbfae	\N	FjJf4ip2Ih9DfBN	9b8ff08f-daa5-46e7-aa4d-8d019394359e	t	Europe/Moscow	\N	1
557	Totolehero	$2a$12$/wvDuFxB6SmzveWTBw04ruxGVlBtRyVQkWj7jUCj4VZsb5/LLLNhO	enslair@gmail.com	13	f	ba2d1c523d66c2a968dab0f2b317e1b650c79577193d1c8ad6a687b2722e30fb	\N	fsgtVWrzxknrJC1	0ffe55d8-2e2b-4184-af33-5de77f322a28	t	Europe/Vienna	\N	1
558	DQT	$2a$12$UtBjHkRa6urG3.2Y/45e1.23knTWFEX9a/IMAJ0bzhXc0qgFEwhx.	12520527@gm.uit.edu.vn	237	f	789daaa6103bf1e239a0206bf1840f238c9c8d4df16733927ad521093cbe94c5	\N	1FSu4Z1rzMY3hkj	23219151-6eab-47d8-9441-cabfd41a7828	t	Asia/Ho_Chi_Minh	\N	1
559	Bunnies are cute	$2a$12$Tk/7E98kLY2MuTELXubZjO8vX8LZKE95CNCtN7pz21vgK.yY1SYW6	easily.ctf@gmail.com	151	f	c93061d7c1b8c36f18be3bb7a91e3f674a1e57e1c0ed7bbc44c4ff9b3bdc1966	\N	SuXwKu49YYt0wpx	ffb4a521-b4b5-4c15-bddf-8144dace36b6	t	Europe/Amsterdam	\N	1
560	chaos	$2a$12$WbCuQR8BS20MKmm.5906KumGoqhmgRENOA90K0hfKqXZvIhmKX45e	shack_duke@hotmail.com	96	f	4d51a6602e6cfa8548babf6fc9c2b88043646371f495109f10b828a58ac616ce	\N	DIqf9Qk78XJafbP	e7966326-bedd-4ab5-bd17-26292b1a317a	t	Asia/Kolkata	\N	1
561	CTFZ	$2a$12$LnYa9YTQ1mZLBF/H79CQ/elLA.gCz3GWB59ywr3iHb3NYZo9e1xQu	ctfzombie@gmail.com	230	f	f7fc84a812b8bee0d64acecfb61fe221b936a3f714c2fcef4ea82b2cff54377a	\N	ntOCl43lcfnGfqC	a0cf5826-c8a5-4c0a-ba56-742033e0e8f0	t	Europe/London	\N	1
562	Ocelot	$2a$12$8A8IzF9w1AAeGqMTJtZa8O2xfRcJ0TRFdL7qKEwl6Nb9yhOLfMT66	ocelot@mt2014.com	231	f	91308069f6f7abe459554fe9fc67e90f072f95256dee0d326156cbdb9ee4746d	\N	BiSc3IbMfgmp4x8	d135ca6e-f6dc-4725-9bf4-b52b9af6b604	t	America/New_York	\N	3
563	Piou	$2a$12$ij64JUc51gbMpXVrtvpdOeTAymomc2jwAWUqfy1dr3lwCJpbjFp6K	nksontini@csc.com	124	f	99213af4917da63dd2101760b451cf6f0aec2f43807053ef02b8703ff8d4131f	\N	19iAVS8w5xb6Vcl	f9fae938-892c-4042-ae2f-728da53c7c36	t	Europe/Luxembourg	\N	2
564	CHrs	$2a$12$55.83cFBR/sFktJ79MPqPOzdntbLuWsigHJqkyehv1g6HqA7kKr5K	christelvandenoever@gmail.com	151	f	f3fcfe9b1803bc3b8f75b839e9e2e1b15843b6b88bb1b678706e19d17e324b65	\N	QovSpSYLfAuc3Bs	ea299cd6-9588-4f78-aff9-82a1c3ed89c9	t	Europe/Amsterdam	\N	1
565	Pinguinux	$2a$12$Ck.5WjdCutiNjMGDTAdwl.mooTO.cTLEAtUlEa4a.vtztr4lrGjiS	nlc@pinguinux.cl	45	f	118d78e25cd538d666db1955679d8001cce3efbf58d39191be6aee04e1e02698	\N	2dw8VpZ38UDQOmu	93bec79b-f644-440e-b233-50ea5bb77d00	t	America/Santiago	\N	3
566	KIRA_VSEGDA_PRAVA	$2a$12$JQKGKzgD8g6/.QIjMvesL.3U3EuIeIc3aKnTM5GUbU83jVU7h06fO	Love.Love.Love.Magic@yandex.ru	231	f	8a239c1f8962dbbbae4d525c0195c0b514512d618caf86b53fac5697a3035e68	\N	dnPsOVjMmdWSXz7	eb85ec88-08f5-405e-b2a5-754a38204402	t	US/Alaska	\N	3
567	csg	$2a$12$2bwyjY70mXF9QTNdkAp9gOM.FbzIVPmfLC.sl.yoI1vdzrHYdrEba	utdcsg@gmail.com	231	f	20aa53a25500367d29b7706d111df6e18ddf2cb9b97a9566f768f3275869e330	\N	Rlao6L1omLWgV40	a0c172b3-5dd0-4f3a-ad4e-2cee6ea6c7f1	t	US/Central	\N	15
569	Team Fortress	$2a$12$GGipeLKfQFyznslop95bJOgarcpHLvs0DUUwT1uybByw0iPF/zs4i	i.found.my.underpants@hotmail.com	129	f	56fca754a5c298562216f3d63e1b49c851556e034cb6f79a18ce85f93101a01b	\N	854YczL3d0FJKY2	0f62f34e-bc4e-415a-a6b7-d4bbbfa5cf38	t	Asia/Kuala_Lumpur	\N	1
570	ra	$2a$12$rDI8W/Xo6Sc.P7fuwt73W.wd8tchuol4cSfDMpTNJw4UBTE5KtXHi	razvan.s88@gmail.com	103	f	5b13e4e96d264f0331ab05721d50b0b112d1343b177d01ad5800cd943747f7a6	\N	X00fHBIOZwLIItF	819a2251-4160-4d36-8ed6-fb69f15931a5	t	Europe/Rome	\N	1
571	you're the team	$2a$12$tjdXi//i03F391OqB/Gy3eE0tpE5koWWoFMutMNK/ul4D/CWQsvTq	you_are_the_mail@gmail.com	74	f	5522a64323ea6f2cea95d9d1e4871ba03a255873197fb2334e74a31fbef036ae	\N	Ue1Px0wslVHyLxK	b09d87fc-0585-47b4-98af-2e9fd474bf3b	f	Europe/Paris	\N	1
572	RPISEC	$2a$12$2NrS0MVkU.sUofoJkQ2LYOk/0yqT/zNAYcG5zNa21pyyHdeqiimBS	rpisec1@gmail.com	231	f	a752b8b2729f71b5a24ad74ddb79787ad72eceed06dcb581f6b63abc63dcec09	\N	Hz7C2eQzeB16IRa	ec26b5a0-f5c9-40bf-9ab1-d96555bf14c9	t	US/Eastern	\N	8
573	bhackspace	$2a$12$jAxkK5XvT/sF4QdM7TESyO7/Hoiyr0L5jGu8FKTVSfOaFRp67rMXa	contact@bhackspace.be	25	f	727bed0d7fe00895952d26aae7dc7b63ea0421c50e502b70c1872214b1ddfbf8	\N	BNo0uKpSL0ON9rI	f0ef9ba4-3264-4096-974d-7f8b1f8830ff	t	Europe/Brussels	\N	1
574	h34dump	$2a$12$XaAqHtmWu1npeP5xGDMqTeBSllIom07XVyaC/FQ57M1F3qevH0oLe	team@h34dump.com	178	f	6c3724a73f0c2c9d8726dcf67f151248374aba6ca76e2c7293d0290da08d53d7	\N	rHTWeP6lLyKP2m2	1ba014ba-9a28-4849-9547-00eab035ba53	t	Europe/Moscow	\N	5
575	chimo	$2a$12$cAUQ.f4itBtxy6pDUkr4w.xB/RwrhGWqOmOzM9A0S2fHm/3kjpq56	tongtoan.85@gmail.com	237	f	e2f38ee73b17e714d2ffdc6b248daa600b89f9733f3d48d1894433b7100f6dea	\N	xGlT5oyYlh3i6Nw	f4165aec-a3fe-4354-b7d8-f83e17ca2ea5	t	Asia/Ho_Chi_Minh	\N	1
576	NullIO	$2a$12$wiKRP2DhIWj4XiFvrNo2Wu2sNK9huqdBh/BHcQyJOEuU5NnSRg272	nullthreat@gmail.com	231	f	5ba17bf02ff352137ffed2a1755001b537f1961571de7cf7b7cb037d9710db6e	fa1d4ab154a86e3e8478d3a7e687cf87162afdeed47d26b1c071025811f563c8	2iVhfdcQ0KgdrGe	19651894-1527-481a-868b-f4bed306961e	t	America/Los_Angeles	\N	2
577	bootr3c	$2a$12$hvlnuqkAlVsG4SRlcSOKVuA0s042BVBchm1z8hYXlyiV021i06MjO	jyolegend@gmail.com	96	f	bca0739b5c8742900903592f1e751e67c6870532d21b0eafd2489767dac9bd96	c84cacfaf75f527bdb4058da91e41e0056b87663aaba5b80a251d9435e7e98ec	g9LCHczu4KKsGDZ	81ba0397-de93-4db1-befc-6844061a4e11	t	Asia/Kolkata	\N	5
578	Exodus	$2a$12$nKJTmthbsfitwjhveDmCNuGwJVYsLDj6FMRByJoBfYc5e3C0FZPy.	exodus.cpp@mail.ru	178	f	1aea61efbfa74dcd4c504b6f5a1e7234cda1df057436254efa49118b035a38ac	\N	JNFUj2AB5DUiArn	936700e4-9a47-432c-9d92-918afeae9b1b	f	America/Araguaina	\N	1
579	b00tr3c	$2a$12$BfsnjXk36AdRH60lCBQmuercuCuymcuEf5.fS6kbVveHWOS0QtEbq	incredable1600@gmail.com	96	f	ac535b208cd3bd077048c84aaaf0c167892de0f4e25c143b74ab1335c6a191f7	\N	GPLwgVTy2zAEifT	af586eed-1bd2-4592-b832-dad1ceaaecd9	f	Asia/Kolkata	\N	5
580	EquipeALaCon	$2a$12$ebIfG.mPXkbbUyFS9MYCauxpGKVxhDOjb3viBiagpJ0P3OO9.dtRG	nicolas.kovacs@gmail.com	74	f	828bb149f406ae8d61713bdcb86ffd54460219fd8a14362b1aa9ffa104d72aa5	\N	h5EDC5IIi0dXUtl	5449efba-e06b-47c2-abdc-eb723cc1d8bb	t	Europe/Paris	\N	1
581	OneManNewbTeam	$2a$12$AzOZIoCPL1.StG2CNY628eto/qQlXxyeOJGypi/vz0B3ggIqUz7UC	huynenjl@gmail.com	1	f	bdc18841eccb7e4939c69e2c4e117e58fa61b663b5fa9ac916519d88dcc10206	\N	LOAMBq6akrocxR8	fd2a9e94-9b7c-4138-9985-7fed97e739c5	f	UTC	\N	1
582	Scribe	$2a$12$U.VrYHJMkR8wTSblQ7A07ORMXZHE79X3dh2mcRhjJQCeR45d/vwYu	gjFest@gmail.com	178	f	17b3bb9ef57e138bcc593726c68f61fb2d2fc857a57fc3a312d0029f89ce1e5e	\N	xWv3ptL4Y02oVfE	38f8ef31-f57f-4b0f-bda4-e46963a8a82b	t	UTC	\N	1
583	HackerDom	$2a$12$u82avhTnr2liUptdt1gcEekvkAPfbtnhhqKtAra7X1xzYGf0QaItq	avkhozov@gmail.com	178	f	7a9a2f99ca9465db26de1bb4ab5864fb3ecef0636abfec774da5e7bc47b306be	\N	tzxTeFrrO087Wvh	43e5b363-2cca-4b07-a93b-83485f2e3e23	t	Asia/Yekaterinburg	\N	10
584	mainstreet	$2a$12$UFqfWb2yN9124.RijjKEou3XJEskZ4qq02FEUGl.LCCETX6S.0i..	mmainstreet@gmx.de	79	f	b68ac4295ccfcdd8e6a29d1d3b1e4d8aab15c1be137075fd10b3eea7937312e4	\N	haIdCxu4300WeyB	5cc2decf-b6d2-4be8-95ff-d3ea6b2b846d	t	Europe/Berlin	\N	1
585	El if I know	$2a$12$RW4DjZcrh8uyqD70IOfFROOIIWZ.5YjmauK/Xu9t7a7f73MFw1wFi	rebeccaweaver14@gmail.com	231	f	307f71b62d577b3adb6f880e0b94ff3076cb252a8d079f67e3165e198a390b4e	\N	4Mjgcr9ffwRsN2U	763a04d1-0baf-4b8c-8529-39f0d0a58c8c	t	US/Eastern	\N	3
586	Mzk	$2a$12$tW3e.GPp0Rnp5CgensoC1ei0.BFNsYqwf9GMv4r3zO4VX/MmkVo/q	yahoo.co.jp134@gmail.com	105	f	fb5b6700e48a6eccf49b035976b51b6e19d7c052fa8493e74ab612e803feb4ae	\N	5kHaPXZkfwHnrBW	253118d6-ef2c-4f52-a84d-a1d68cf25aec	t	Asia/Tokyo	\N	1
587	Log1st1x	$2a$12$VNQU94UUaJUKEMF2iDXaWuYNL8mJum6YVWarI/tiM9szoEiYA.L.a	aghe@gmx.de	79	f	675edf7f3384def3a7e583e21f8b5b1fc866a69cf01eb373b1fd64a7e9e17c6b	17c18547da74dc5f2adfec990399156fbd39e7a333005fda3a5845c5eeafe244	tuHsYdGRd1FJzlP	71150e23-d36b-4ed7-a9c4-52a774a6c18d	t	Europe/Berlin	\N	1
588	superubuntu	$2a$12$2KquDJUHNNfJXISWc7WdDOs2X2E9h25pCvapqnyXBuFdduxb7jwSm	soarcbr76@naver.com	112	f	3b5fff69541cf1722b197b00afb0a01a0fa0d7a6c4ebd471d81bcd5cbe4d556e	\N	H6Qd38f8FccD4ES	771aeeb4-5f36-4495-a602-709a90f32070	t	Asia/Seoul	\N	1
589	Kernel Sanders	$2a$12$InClEAiHvWuuMe7Cs4xKxu4TdlIPx6.Y5FI3BXW/O983timdtgQ/.	matt.nash@ufl.edu	231	f	db0b408cd293daba839fa338c9ab6d897302fdd7d05613a014f9ce57ebea61f6	\N	tzuSrbcmEngOnFe	9027953d-beb9-465c-a2b9-9e70ca7f7b2b	t	America/New_York	\N	6
590	GayBearTerritory	$2a$12$aSVrSx/C0TFoq/mL.0ft7ecqTWwav89CzudLo8myQPlW6v2ew7AFm	scott@vkgfx.com	231	f	e1a700e03a0a04f4aea887561dbbd6d86eb27efa48708876d993e37aff8ac696	\N	F3jtNF0qGCvcb8x	bbe34fdc-bb8f-4ccb-aa85-89d812e006c3	t	US/Eastern	\N	3
591	C0MM4ND4	$2a$12$.ecbRilbQbJZWXRx46XL5e.Lbs8TgVaEVfvolmOl6y6GNsTCukga6	tumee0113@gmail.com	141	f	dc63f696df52b1e8b8493ff7db39080f6458a93c9941bfc9ea28cb4df96c6455	\N	0fyWuHxP3vU4DTx	ab672fc8-79a1-48d8-aa5a-cdf6ff080440	t	Asia/Ulaanbaatar	\N	6
592	GreenT	$2a$12$KGJnX9tk8l.Yo7f0WOI4TucpFzbfdh90pSY4JwtP8YODMPnen1WTS	trufanowa@gmail.com	1	f	7d792dff8fd9e53cd195091d57b6efe497d6e30922bfdc3b7785aed38341d2a2	\N	Ctu3gqX16mlODZw	8568afa3-3ad3-4826-91ca-705f1572cf26	t	UTC	\N	1
593	Team TEST	$2a$12$ZS229g7oX.kByHvIEHqoY.sNQ5UMYq7zRZkZgiNoKqcwCOrQSvZ5e	x@mailinator.com	40	f	faeb38c494161d8dc47c50d7e8d342943f904b5c3b5b71d9db6acf7bac63018a	\N	5lXQApZR8wSMD75	7c7a4b1b-89ab-4cb4-8d4c-460a0f45a8e2	t	America/Montreal	\N	2
594	Shadow Cats	$2a$12$uhJ0ODx1BtadaF6Y1p/8VOtY/YrIW7eOk/sHMGazrcqTYLQtkBsBG	ahhh.db@gmail.com	231	f	483d72ffe9165f3d351f831b7b1bbd70fc89f85c359738dbc70783904aa09ee3	\N	O3bKvbYa6URe0fv	ba1155b2-0acf-4d49-9aaf-b368f8b4ec38	t	America/Tijuana	\N	3
595	ttpi	$2a$12$SJKNRiS0QoyXZBmqOqQ0KuN6XjrMScIbUObYI3kMgiSjge5Me/Eyu	alexkarp.ru@gmail.com	178	f	9648398b4fbd847e94e028e85dfd4d790507713188fd057029cd420123a5b095	\N	EmJGwCq7PYaWmFD	510b0342-b2e3-4019-a35a-279d7f311a53	t	Europe/Moscow	\N	1
596	anarh1st47	$2a$12$8CgeEoOnxALFwt0ERYm.wee2xe6nvHlQ5fKVnrQcDUQXvZgWp2LOO	mail@ya.ru	178	f	9ec10af834b3008d2a12ae8657dd882342208e7a286acd42fde2ca7336e52614	\N	ocv3tMBaiEkdbgW	e687c748-71ac-45fd-8bbd-7cd53a98ef97	t	Europe/Moscow	\N	1
597	Coon Team	$2a$12$lBMikvPPzPpIAR50FFayMuDr5Rvu/2uW3578XagRxsiL3xDbvNOwi	the-varenik@yandex.ru	178	f	790febe63c0265feb2167115509241632d5e7d29c3c4319ce0bcda4f57682be8	\N	3QaACsLv4i1Aoem	2b55e0a1-655b-4966-8743-880cfb9df913	t	Asia/Pyongyang	\N	4
598	Hello Kitty	$2a$12$nNx87OmM3YFVPAiUVMLI8.T9BoskSJ2vxiHI.Z1Ifw8eMhkonPZs.	comoac@hotmail.com	215	f	5dfbb51751c5c049c3a17460238e740d8a3920fff769027ad7b90aecfd81aeb7	\N	r1koxCL9i2ZQR0o	c8ce854e-46ae-4c8e-8c44-5a5ff7a0ed5b	t	Asia/Bangkok	\N	4
599	arnim	$2a$12$HGIDLnuaIa7tpIzcfw7zNetttPJgzeP4JGH9Eht/XorGxpufTKnZa	arnim@rupp.de	79	f	9bcbf8b724a3242ca96e07dd9a971768fcf655ac6b12f1aa925c290ee5b89fbc	\N	FtbVUJt8rI7DU2l	c4b35a33-a8f2-4a76-92fd-cb1d955aff15	t	Europe/Berlin	\N	1
600	Ð¥Ð°Ñ†ÐºÐµÑ€ ÐšÐ²ÐµÑÑ‚	$2a$12$pAerxfg8e/b8qkKdE.TuJuDcPYf9zqY8APRlOWjMFjqNnYym8Ud9e	alexey199753@gmail.com	228	f	8147566561b7756f9d6137d7d605e75ef869999040ef2f478614ee03e11865c8	\N	ukOrhRr9b0rRPaO	5f77ae12-2344-424b-b80f-504eff0492ad	t	Europe/Moscow	\N	5
601	Tracer Tea	$2a$12$uH6EnwHNuwJfnu3l0qkV4O/ZhrbosWVObYxycH0Br9D/v8CMw.sGm	morphiend@gmail.com	1	f	bb2842145b3653b78df57b75e6c4b32522fc16978c5535264e0fe48db25da4d3	\N	SCTYHcnxpW4oTCV	ebcbe33e-d9c4-49d6-983a-5e7d99b0b6e1	t	US/Eastern	\N	5
602	one	$2a$12$vyqkwRPngfOjLajMaSI7IumPpDbq1N5XRpB3TJ2aH1JVv/EUSO0C6	jigsaw0658@gmail.com	137	f	1c42de15fd6cd4f9f2752ea7a5c439bb9ea0de8236c6ca5858179ff79169abcd	\N	otSqtSqfGsqp1th	0ff058c3-8a56-43e1-b456-fb2c282fe99a	t	GMT	\N	1
603	Mnmrr8 Noobs	$2a$12$9Xd5ohgO85uJ10HI6lVkPujpQAVDVJB5qJwL.TKkkMsw2ZRuMZwXq	Mnmrr8@gmx.de	79	f	1382d094c34925bffeeb4cfafcf8c39241b94a63a062f7de3cfeab419c61f54e	\N	5fe6WGzGHwFiANE	b32146c3-e733-494f-9890-304ada9dcca3	t	Europe/Zurich	\N	2
604	SwagSec	$2a$12$OmKdHhJG.Ge2L8dzVOrJz.hWuuARjFRC6q5DFBLi6ayElalLTo9na	brandon.gnash@gmail.com	231	f	f65d90f601dba8f0bf69428c60e7b1a52ffd59fa39e2f245a21d9dfdf03f13c9	\N	YG4AjOAdilluldw	615143f3-2563-4ab0-babb-ca238c88c01e	t	America/New_York	\N	1
605	dada	$2a$12$Oo6Y9HCklwRNte38rqhagO0nsPLLanWmjegNhSgw1C11eo2RYxakK	h124224@gmail.com	1	f	8e74a50bbf4d2901a2a6bb87dbb0d4db7672e468b43f332254efc86e5e873191	\N	oIMdxY6l5Uqn738	db99b5d7-7e0a-428e-87ba-d16ad148e239	t	Asia/Taipei	\N	1
606	Rea1337yKings	$2a$12$vF3n3Rb.ATTfqYHXcj4pKOFpmZd7SAr7qaUeMBaTu648vw5MtTxgu	dark-puzzle@live.fr	1	f	cea809fa81ec574151761628edc427d05192222e53648cbee3aa3da5f45d8322	\N	yTw5y1cocXyptwB	3fbbfd17-6ebf-498e-a579-87048367a57f	t	Africa/Casablanca	\N	6
607	%);}(2J>o/	$2a$12$WCd/bOHoO45b6rjC695.C.SNwFd.OjCf4eUPl8jUnhEpwY8o174q.	theangryangel@gmail.com	230	f	4fe6dfcaf25f1d80958ffb71317d0ca65040d06a7202f0b835b1842a44fb5348	\N	H8y6ZhLnKSgkdHj	d4cdb5e9-578c-45cf-988e-098d78f87c3a	t	Europe/London	\N	1
608	Cyber Defense Action Leage	$2a$12$/pPHYX00j37lHu9S9OWFfuKwpA4w8QGtB21./FlAXyxLLP.dLu3GG	wamsachel@gmail.com	231	f	a1442482e1dd8d390c5e76be8305a5981626e8abdfd44836aa3ea1e0a70713fb	\N	gDPCYYs6CdTgZn1	2b486ae0-e371-4102-957f-ff052f2ed9f6	t	US/Mountain	\N	8
609	MBCARLSON.ORG	$2a$12$iEVmCEmIYE0BEdiN/D78MuCFNbRg68t3D/1DgjPaw8vqg7J7WpbAe	me@mbcarlson.org	231	f	9e4348adce0bd634a88d2b7745a320f5a54421a43d476f38383992acb17340d8	\N	lZwPsfzBiBQfsY7	eb9c24ad-9a26-44f7-9cdc-e78d14cafb90	t	US/Pacific	\N	1
610	benni	$2a$12$YO3sOG176EyM1iJiW0q3i.fwMj6OrJ25aUfu83s.z70dhv1KCvwpW	nnabiollahi@gmail.com	25	f	26494133c8e19df9d7c9525756d4d8644d8e3afd8b445963de369249e10ee273	\N	IdjUxJTFbvmeMVu	65c03ce4-5015-4e40-a6c8-c09798fdacc8	t	Europe/Brussels	\N	1
611	noShellCode	$2a$12$yzqkOAVtAOhowYHhGXaevOl/7IzY.GiFEuJD/nNdlz/jcuyF/ETGi	CaptureAllTheFlags@mailismagic.com	40	f	16009ab6b710806b2227ca3c2f3674c32fb3e211745ccb4d242178183c6c2d0a	\N	BxzQwUDLbTbfZ6T	99dab611-f7ac-4595-ab2e-9e892a1a381c	t	Canada/Eastern	\N	5
612	OnlyMe	$2a$12$Qm49cPg02BGfXf0ZnLn9Ye7rNQ/leEdKpFWxj//MblqKKbsn9CKOi	robots199@me.com	231	f	1c199b9f74d103f5e1bcdc731b444df504f9d6125580ae4fafef17b5a1d09fb1	\N	WbKbIsN1yIOqQCE	58659bbd-4dce-4518-9b8f-4f3ba230063b	t	US/Eastern	\N	1
613	Minelord	$2a$12$IqMSsvXw9NN4RhH0JEwxreipLRGdNKqaK0XKZ.FhbJrjjgw2uZMB2	thijn@minelord.com	151	f	9586d861f2acb3d561be72f6130f02ad46cd876227fc47d98d46057065cdceb5	\N	DNoGkgCNucB3qGP	8ad7ba43-c4a9-4326-b732-ae0548391426	t	Europe/Amsterdam	\N	1
614	whatevergoes	$2a$12$3c1581Z3R1KVsc9oS1xyaef9P6wl/D7/wcqAM0p4FnTJDWvMMSgj2	whatevergoes@mailinator.com	62	f	4b8c0ac1b23c783f18c2aa6e5a0e31c6338c5228a8277d30959c5ac38e72ce2c	\N	Cj5FYfWaNZgMUi4	75a0c233-7dfc-4e5f-a429-2707d9bac6c9	t	Africa/Abidjan	\N	2
615	blablabliobsflsdfi	$2a$12$qnJHFcX4FS090aWxx5NzTeBGweLAJLUbX4c3LV264mczh97Yu0uNi	suce@yopmail.com	3	f	69257c95aaea30f31e9994c64ac92456092c25934b0e1406ced4f2739e5fb5fa	\N	asQThWiKSnRpikx	cf93f702-ba37-453b-9baa-dcdb7fd024af	t	UTC	\N	1337
616	lektrik	$2a$12$/.yzzo.4jVNRw.OW4NZBieFLENpweVt1Mh0Uk.3HPgAZOy.EleDYe	suryaprivet@gmail.com	1	f	1c021d7e4ddd733cffa28d18cbc9258c3b20beae233f45e1f5087a87668851ec	\N	7XqNFh8C1NrTtwx	56ef1b7a-64ce-4cb6-8174-220ba638699e	t	Asia/Kolkata	\N	1
617	totoro	$2a$12$kYqoCH7j/rX2D1.1BVy3QeyX8E35InYWbqxM/U/X67ASMHpeJgJMK	jpmenil@gmail.com	74	f	bb85a083df4d2f8c5839f6b69e39486fd8e3d300c741e49393a08e576e1c1fce	\N	xyYiO3A2Rl48kVl	55e327d8-8d8b-4d31-a957-d87aab58c324	t	Europe/Paris	\N	1
618	spicysalsa	$2a$12$K9FJBZ/kwZJnzzN1WJ6KO.A3jUXjbjuHk/1D0il84Yp5twFO5ixHi	rgraham1821@gmail.com	231	f	e2cf71a59992d1acd2b3847c5c088ad1306ac9c1060f91ff2928392644d860fc	\N	XrALEGnRCwXF5SF	fd82b2d1-3087-48b5-a5c1-4bc49801aa81	t	America/New_York	\N	1
619	CyberNinjas	$2a$12$sviq0QrBXSf5NokESfJ7W.FOuqSdqHqNgd9A/N.HQRdF1i327WYBa	pollack.renee@gmail.com	231	f	301af79b6048e6688430d0a613a3ce7ba6bf4513299b83fd649e7ddaa1c42508	\N	I14D0RxyfInhVNU	fa146ee3-b8d4-47ac-bc99-d81e1288a268	t	US/Eastern	\N	6
620	Team Linuz	$2a$12$yMtZRIBvDQodABAjfcZ9Ou3mEMY9nzCp9SqKS5Frd00uIyHgYz3NO	dennismald@gmail.com	231	f	8b0aeb128699094abc53a4939c1c5f506cdaaff8dd84261bd123ab828a74ff3c	\N	Fv2g6JTesx94Lqh	37778aec-0b1f-470b-a9a6-299ddd31d5ba	t	US/Central	\N	1
621	NoTeAm	$2a$12$h4ZpPhIWNs5JRD3UAOEHe.CgJc7rpuXSKMy7vgC5JcNDF384tlcsu	bidonzwei@gmail.com	74	f	fa178c010f622c624277bfb05c44cba1f5d0f2174e1deffecda980ee12e88d57	\N	bnvkZMkr49iD8CV	b8cf8e37-8064-480a-b49d-960e0b754761	t	Europe/Paris	\N	1
622	pht	$2a$12$6nt98PP3gla5f1TYO3nRjuxbvQ97v9r41Rd3YwrbJLfdV9FIV/k3K	piruletous@gmail.com	204	f	0dc478bddb0293a5b266536aa9e4c77876e54231cc7f510de571010c06581126	\N	prMh8jgAZwykAXr	6128afc4-d329-45a1-82f0-cb16e4779e9c	t	Europe/Madrid	\N	4
623	Little pony	$2a$12$gch1Su1Y68XyBPt/RmN.kuwzMfvOfo2gIepx0TtWZ1F1xy4HIODPO	littlepony@yopmail.com	74	f	e6e9d259b8d1d5f4db7eac6b6917d808726e0341b6c1730eeda5af784947dcbe	\N	iQgALOIcyWU2lSU	7b37cf92-a384-410f-9f8c-25579520aeec	t	Europe/Paris	\N	1
624	UMBCCD	$2a$12$FWMbhV6RDuQNWeitfM1yEOGxDGDqeMQqnKHh9Sg2Qlp8k9OzdWYbW	okubik1@umbc.edu	1	f	470fa58352fdd6019ae079593fab95d0e6306bde8d1fcd36e7369494290a3548	\N	ZxX1MA5gsJDBF33	29494b48-f4c2-45f4-b7d2-da3fe5195080	t	America/New_York	\N	10
625	r/a/dio	$2a$12$u9E/9esEYiIkUznU.V3sreZoxe4e7tO9vWIf84MElNsI2QWaTnIuO	tripflag@gmail.com	217	f	45010cb1665717f2779bf0e7d9e5ea12845c78727530fd46287b377cda69426a	\N	eMwJVFlSADyBwkq	7f4b3f3d-8dbd-4e4e-8a76-183ab30c753d	t	Europe/Oslo	\N	42
626	drogenbob	$2a$12$aQZI/lKXKL5yNr60kv2t2OSSgStkS.dUEeiTVwYi2EPY94LsyJAi2	hu@humerichmus.de	79	f	b1cba4dbba828dc05954642e218c3019102a41fac3fd129560ca72e16080945d	\N	KEYvdz1Zrab0dBe	b3b5a322-abcf-422d-a992-bd2cdd5ea0ca	t	Europe/Amsterdam	\N	1
627	tigerpuma	$2a$12$JSrf2heEaTAW6LO6M.8yPe9ir/RYdu1uFnHydjQp/wW5et8haP646	blackbearbkpro@gmail.com	237	f	b144d8e9cf6e0d98fa85a72353e83e359e3b3ab21d17337c80af23ca50d2f58f	\N	hAjPuEU9y05MpoH	b6b60c5b-87f0-4acf-abf2-24fd1c35b81e	t	Asia/Ho_Chi_Minh	\N	\N
628	cs591	$2a$12$nS79wqgmPk2jthl5BhkNuOpcQXgUqcsQgyAPuiXzboKFLaK6EHnYC	npudtha@uccs.edu	231	f	4cba546e72bdae4b433053b669a5478ecb474721b72eb65865d248c4fefcafae	\N	WP4e27s2H0Q0zFL	d9c7503c-daa9-40ab-956c-179531d26603	t	America/Denver	\N	4
629	pr0n	$2a$12$5hn3yiCuzR5SGYB5D1y9kurWDxX1oWY5fC6SQYXZGcK6RPio5lY.a	b750182@drdrb.com	79	f	f5f2b9ff5a61bac538b3e7d9d525cc3450c096db8957dd2b4e3508b25740f70f	\N	vRpmqsSNEbU5EJO	93457d2e-ae9c-44cf-b2e7-2135ab9a9b5d	t	Europe/Berlin	\N	3
630	StS	$2a$12$DpGqz1VXM6mwviMloCGhFumLhCAh3JNVS3cAS.MPXHgz65LssQm96	0xzoidberg@googlemail.com	230	f	4010bed70b1cfbf4e902238b61040675fdf174aa1cf64d3d3b55e73993e011bf	\N	zX6eZezYf4IIkGb	d5229165-4b93-4b6a-86c8-38d42d1797c1	t	GMT	\N	1
631	Didact	$2a$12$7ewsk/E7YEZTPRhbotHor.L6OW3CmjY8pxJAoVebXuKxJGPwQHV9C	draufgang3r@gmail.com	105	f	20f56252598d9f93f9eeec84b719d6ca6be26e7b59f62fe9ee8cb5313666b4fd	\N	wDuuWmKqNsVFmaZ	c89d1279-035c-46e7-87d6-cca932c47879	t	GMT	\N	1
632	Twerkingpwnies	$2a$12$ARzjwRBCa4STVxnfR/mxpO6xc2L3kcZJBncG9QUA7fCVqQivG/266	adamanonymous79@gmail.com	231	f	b56f0540951896d4f2920b8833eaea02d7f2fe1ac7a2625d5f92c895875b9ead	\N	sNf7ome1fMsLGvb	13bbdf17-3482-4364-9fed-b7fa4f0df0ab	t	Canada/Eastern	\N	6
633	CA	$2a$12$8hokJgdaaI4t1H4BUE8M7eMxHH4H9QCTQL4y4H3A5xEauPLdOayNi	jchan5@utk.edu	231	f	22edb96eb1f11cf8fb133784b4461379223c1748f8381ad34659c819cd14e15f	\N	cOcwLsAYAhvR3aV	fef3ff70-33e6-466d-b4dc-7c1f4e216cc4	t	US/Alaska	\N	1
634	wHGw	$2a$12$9oV/djfRZTf0el4vIfM5rOGzciK6Ce6I4yZC6.Q/flw7f4vxe023a	cctff@bastelsuse.org	1	f	c8324852f32904a1fb057dc79ceab37f998442e06cc9ae976c7ecc167cee5167	\N	ZHAVMkXNtP3rQEv	10a8065a-c7f2-4e77-87f5-af56c639c0cd	f	Europe/Berlin	\N	2
635	wHG	$2a$12$Msr.4Zch5bmxC1GC2MI.sO5lEj7rSFcNxGWMYx/SYS2VFtBkes5uO	ctff@bastelsuse.org	1	f	5846b5f154c4089295ed9664dc2f949c257c727c81beae3c8ba6152a3bb567c6	\N	3UqFIunqiNVhscw	84bb2ecd-7b87-41d5-8409-df8d0abc3f49	t	Europe/Berlin	\N	2
636	SIS2k13	$2a$12$u3nrnvBrqBpj.4DvtDsE4ef0w7EDyYwPLjmyUllshoq0TJhKArVCK	053f0186@opayq.com	74	f	30aee1df6cf9b606236ebd570d320cf5d65ca3e56cbd0711c4926f6dddc79a2d	\N	5IyH1gZdvP9XBM0	60d18ec7-2dbb-41f3-8d6b-49189def4dc4	t	Europe/Paris	\N	10
637	TeamMSP	$2a$12$96UmdmeWiYjLnVfMoVTgKubslm.OGpaaw9h3TqUs0Am7u1jbmGzLq	mspctf@gmail.com	40	f	45338b1cd188be3e6ffbe845c9ebaa4be299620708d20ddd2bffa16f1fa5ba88	\N	OKErMFTf9FktNG8	fe841b71-cbd2-4f06-9906-2eeb37f56b78	t	America/Montreal	\N	2
638	coyote	$2a$12$qyPwtHhDzL5g0bhpApvGtOlAYMwrkXykN80GjXKBmXNQau9yWN7pO	pierce.thrust@gmail.com	178	f	6ae131c1c722f85ddce60f183b6fea77ec1b001a76364d67c6550de98bc6809e	\N	ABW4ztPRj4trV9T	80732d03-ce21-4018-925e-88daa875327e	t	Europe/Moscow	\N	1
639	didldidi	$2a$12$MuPCgWNpSGzpFa6i3c36Meyz8328rqmFH.a0Y1Nw2zlElR6mHc5i.	ctf@didldidi.com	231	f	64e3a64adf97440ee2387b2e12b118dec88128606f53db0bd344afdffe9d7efb	\N	rN3ryha4u2DGTmx	25f11dab-2e73-4e87-bb41-a82476004bd4	t	US/Arizona	\N	4
640	Pingme	$2a$12$rb//W0nWjf.9Khu3PhTJR.rSvb6qRyYPW0Cb732BQ64RIR4b9XQo.	john-deguzman@hotmail.com	40	f	9e43901b626277d9fc63e40189cbb39ceb8aa816d68d82e6bfca3ceadda01ae7	\N	sZ2dh6nm0BjPZ4e	e2801085-3ba4-42f8-b647-4700b6038fb3	t	Canada/Eastern	\N	4
641	SCDT	$2a$12$C7SMTfvSvRXYYrtWCSNyEOt9xmo1fIISgDtc/B.XbJqLWIv42jHJ2	tylerromeo@gmail.com	231	f	cc0236accd5addce70ce9f740f718c741b771556485b27ff0b5713778e743e36	\N	PTqH9TUGV0lUa4y	c6707475-edc7-43e7-b9c6-72a85306dc3c	t	America/New_York	\N	5
642	hecky	$2a$12$WCzcCF8x0syOHCaATN70o.ZBxHOgBgSOyeO5fNycxCUkKOtgYF0Fu	hecky@neobits.org	137	f	31f1d786dbd2aa84fd56c9110d20bd37ea457dcc8356f425399e72cf357e1f1e	\N	Dn5FZqi023uTT9I	77b93968-c715-4d98-8b5f-a58fe94f90cb	t	America/Mexico_City	\N	2
643	cracovie	$2a$12$tzP/PGGMdlHybkD8WWqJLukuY8Wn4o5Wn2y5INkGKQ2zJO9Xlf5ca	cracovie@speed.1s.fr	1	f	3009e8e32160b56e13e534623cc55b2d5bfd5e7c9db46f6fa5f48d337b648f1f	\N	0oauTCQTR1yK1Ca	174ed878-2042-42fc-9b7e-1dbf52d6366e	t	Europe/Paris	\N	1
644	TShack2013	$2a$12$ingkCXg1byv3NGnWAk2O2uthDRkx3JxCNvovA9ofBe2FmrxN.n8D.	iamthehacker@yahoo.fr	211	f	42ffdc224e00fe3126f3f7f0a92368c7b5b90bb400b34dc68ef84b634a09bd4d	\N	eSmHLwXsDTtriiC	d4ea4351-36de-4d63-b81c-fe3288207d5b	f	Europe/Zurich	\N	2
645	rick_and_rolled	$2a$12$PIfQlO1M9R6p4uvWkDQuguqFw3.ubMJxMcJy/b0hW.vE/RYjFMmFS	dwayneyuen@gmail.com	231	f	0ef122598c55dc369a9cec1b771aaca6cb7c0cc917b41acde3f62398877f5274	\N	wytL8imOwNkd5QA	c4d56563-21f4-4d36-9930-d5cef6a84361	t	US/Pacific	\N	3
646	TeamNameOne	$2a$12$zPR0JK.uyWm/Px.XtLzvqOEjbtBpVHAM8b3wFXII56I6keqPDM2gm	ag3983@nyu.edu	231	f	98e2200855b39f0d6c39f85d475537b2a131d88ae02cd383b02f9405dd11418b	\N	PMf73wBBieKmPA9	adee06c2-b913-4378-bf5a-4aa86b685ea4	t	America/New_York	\N	1
647	iamthehacker	$2a$12$dXq02/0Qydxh16My8mevkOwUvIKSjL0kr401ClLEXloOSsvKZ/TGO	ongagnastphane@yahoo.fr	211	f	68118332e70361fbcf25974c1497cf06b9cdd6462d3f557e00209cddde026064	\N	SOLyTABhw62LgCx	f9796712-a1a0-4fea-b8a0-6e25bb3368f3	t	Europe/Zurich	\N	1
648	juanpalomo	$2a$12$AoYGJ3WgRaPk1Aqd8P8lQONYpUjKLfww1BlN.XWbplviVAboyA5bO	tuxotron@cyberhades.com	1	f	550dbcce91ee7479a6534c5e7f8b8f42fd8ba54243c9f3ca9ea76394d1dab71c	\N	B0RJVutclbgcFPR	3f56347d-ad8f-4c0a-85d5-9d6e3f309b67	t	UTC	\N	1
649	Bursihido	$2a$12$CjJR1YKcjjP2XocdNUszFecQa0T1w6K2n.3PhL05Yi1sbT622c22q	bursihido@gmail.com	96	f	8d04e786c031b5c067a9324e2b3bd85b50007315c2532ad63657e34f4e055fc6	\N	JfpNd1JEbooJL0c	9ede9a2d-76f1-4f82-91bc-5ea93a425359	t	Asia/Kolkata	\N	1
650	eecu	$2a$12$PyEDeZ4I1bvnvfNio4riHetNUQTg8J4LwMdTqufpbVzJVBwbzq7Hq	mys921027@naver.com	1	f	80bbe4babbf372f5cd47c608402d7f4bfc423bd0e53e4fa8fb237d0292e1e7b9	\N	zx9UyQ3onfeRh5t	f3d3b1d5-b3ad-471b-98e5-4c4cc795219d	t	UTC	\N	1
651	A||B	$2a$12$Zm90tie4qZowSRag9q7zkOiIgyhs3bSdo2t01nP3ixSHveDZ57TVS	m.batmunkh@yahoo.com	141	f	d7aedb649d54c36cad8ea3e6d69435c73667e069d04fd712da29678aa7c98a23	\N	SkY9NYm1hbAOFPt	6a79cc3b-5f69-4ae8-b348-b9b917d4ffc3	t	Asia/Ulaanbaatar	\N	2
652	Ian	$2a$12$bhFRgK72C8wXmSg9QUHF4.NbHBKWvMjrWaROapomN.Hx3NrWN9ONm	isheff1@umbc.edu	231	f	7a97f77eefd94d0ee333b5cdd43a4fc8516592ccb7df2489e16340c3697c0645	\N	SKBMkhhFqIhgeMG	daef8163-750a-4a4c-8ad3-467732720d38	t	America/New_York	\N	1
653	N3phri73	$2a$12$g7wdIgrY8RUokJZXczBWu.OYLigfPUQfDYCbwvMxo4JAKIknSmKbG	dfac007@gmail.com	231	f	4f4a4f70890ff4df0aa57f58edbd2f6bd4ef7df1e74ecd2d5454c0ccaad63d8d	\N	NTI0auVxd3Ouazz	a968e826-2972-40aa-a560-c3e50679905e	t	US/Pacific	\N	1
654	SomeTeam	$2a$12$gpuou1aXds2sODi8hJC5y.I8Keq.tEenOVGGIfMJTg2peeh0iqsgW	someteam@web.de	1	f	bfcd1dea63e1f9ff16c118595ce005f97a90f983f68155b6c8ab5cf24cd9b634	\N	7QJlLMbyZA2P0jF	8604a7b9-1cae-4616-8201-c1633c8370e8	t	Europe/Rome	\N	1
655	BlackWave	$2a$12$U/TKrBNjq.ln1fG2uNtyJ.mc4lcF4u/Vyp6p10hgb6bPRdnDGmyMq	attafani@yahoo.com	231	f	ebbdc50bf2908d0ea5f5f05dd1efc77695ab35d337dd0438b203c5d5f87c0c43	\N	WZlqBNRiJmq2O4h	400adf54-2ab9-49ce-868a-cdc275e5f850	t	US/Mountain	\N	1
656	JmpOnOferflow	$2a$12$C7zBUkBoPN4Z97tre3lgmOeYd8dAPWgAFn.Ch6ABPknE8auBYINnu	wjlandryiii@gmail.com	231	f	eb9c04aec0d4cdf9e58dad277af5a2bcdcb1f385e4ecf6326a4588373ef7baeb	\N	dJXq6feaEQLAOzf	41a2b3c7-38e3-4e78-beec-4c63724f37ec	t	US/Pacific	\N	1
657	brd	$2a$12$p8juQdCfpGGqTDXrMWDp9eMEFgwXSN1DBngx4KB0zvJtoHRg7oJmS	backrowdrunks@gmail.com	1	f	4aca1f5b594c21ed5166b3cafd6f1ebe912f7438825ff6a9a91a3ec5bc189354	\N	Bd7pfd6zg1vVchT	5b5642df-1768-4401-9357-7b81ab1624fd	t	America/New_York	\N	1
658	LeaveRet	$2a$12$a2fPbvFtlDov2aA2KZxIbuhoIVl1jNjbfK7yai1VK9wfwd.P90Is2	rubiya805@gmail.com	111	f	b96deeb37757b72e05d7fa84ef5baec8682a39f2859fb9936496cc3da302293b	\N	uqg1jcKXUNk8jqj	b7abd650-989c-4c50-aab2-b707fcd21049	t	Asia/Seoul	\N	10
659	Thesat	$2a$12$ByRFueTWiWCWf0RIJ1lQx.24LBbmpJablmNbn5HkBY9Wx2KYs4Sjy	prasitsb@hotmail.com	231	f	970c6d5d16d7a55f16dc949f3f9191fec3f23370af2f6ffeac7a2987eadc072e	\N	vmBB6vKlosSWCCH	1ab5671d-8ba4-41b3-b666-b31491aa4ee1	t	America/New_York	\N	1
660	invy	$2a$12$N9aykx26Ca0ESAnqLxE7mujNDZ.7xYMkSWE.U4P1Ru774hCaH6sh6	wartex8@gmail.com	231	f	6a53772bb84853d6d0e432deed7a0a3ef177d55ac9338a1b1b9be49f00357525	\N	BxH8NLGMnhXaBK1	95691cb6-554f-4756-8303-e3076924e0e5	t	America/New_York	\N	1
661	wunky	$2a$12$NPlk9cEDVQ5DeClCcP/I/uTCsLya4jzFz6YCulXJJ/4ZUNu6S2TVS	funkymaster42@yahoo.com	231	f	e86ed93c71b90d2fe622fcc2652064fd4c63ea3427883b13c75c9ef1ff09c31d	\N	Q1GBnZZDMHAjI5d	decfec8a-fb45-4737-aaa5-46178b933f53	t	US/Eastern	\N	1
662	dijkstra	$2a$12$SQA3jLSVEn3laJ9KuCI6/OvSfxWKYKhTaT8VLClzErbCStPQBCZOS	bubthebuilder101@gmail.com	231	f	08d354552f529a0542bb8f363fb261e06a6f06819bd6169d894b2024fe4c33ce	\N	S3Vs9RwjD1y2mSp	5d03223f-b2ee-43f5-bbd5-f1add3094794	t	America/Chicago	\N	1
663	quack	$2a$12$d8sz5Q2FUzSqry0p.DGwQeIm124YfCZ69tp8wSZBKVU4wdGMjuqNu	jeskelds@uoregon.edu	231	f	bc4c29f8b321d8a9322e9a2e7c46cbfc6536e2116d386630961393eccae77b46	\N	ZDMXuNuOK4GRYFh	d50ba9c0-3968-4520-b24a-b154e3a10d0b	t	America/Los_Angeles	\N	1
664	The Q Man Group	$2a$12$Wb/1GM.Z3uhGg3ctpRYpTuc6IM2srz.sneFRpEYfFGNqsdPp6GbyS	cbcramps@gmail.com	231	f	d674fd89f45d9f8293bf8a18904935e0b975acaa55b7bb21cc9d0273d5524588	\N	qnj3u32tE8MRu1R	e651155d-f7e4-4e4f-8dab-5b872f697628	t	US/Pacific	\N	2
665	comradwired	$2a$12$TxCK6lRCPjuCm9c8FaViSeiNVpvb42hyYMp1HawLQCgHb15OWLzOi	felix.s@gmail.com	154	f	bc60228e23d21cec96fe69e0395cc408e0db3e5302651fd1a657faaf3120fbf2	\N	lgxVWAk9jWf7HE9	22b0b6a6-749a-4dd5-9556-09d77b2fb481	t	Pacific/Auckland	\N	2
666	CatInTheShell	$2a$12$b2uRdm96cDC6IYv0.nDwnOOATewH3tlPaVR8gQtyPZvXjEpM9c8RS	pich4ya@googlemail.com	215	f	850235c022f1de59b30e4893b63f3216db4901892f6d7db160581a2b9ff59021	\N	DPYtawXk3xmZvg3	4029545b-e278-4945-b7b3-c5e29945442e	t	Asia/Bangkok	\N	1
667	digby	$2a$12$kw0eWVHpOWjfLx9oiQvk.eELLIjdZaHsuK393bUI5OVoeRejl51MW	berton.julian@gmail.com	17	f	8d98797d9dfe887471c5b87607e5539397220aac672062a039b99558dfd7fa06	\N	0MB2ZMfsZyc7fhS	91461bc4-a10d-4e66-aedd-319b0637ecfc	t	Australia/Melbourne	\N	1
668	MÄ±É¹ÇÊoÉ¹ÊžÇs	$2a$12$.GKQg/C2qRAeL9je5JM7GeUkDVd52kXiCc9zX48lYc.5mDgfvpuby	fool.of.the.seas@gmail.com	105	f	13f8ce8ab40db20872a6e3c8d5c5ede651d45439798e47d0523ed1fe99faacaa	\N	TOGsfKuMPxD2xU2	b450e985-f329-4a68-aa16-8ecaced67149	t	Asia/Tokyo	\N	1
669	Team 404	$2a$12$4VJcwkZD7H7gtGoEZWp3UO5lgDZpiEWhpuB1cbgl1qcm49OQU/npa	pjumde@adobe.com	231	f	d75d24736d35e1b2a2a540c3c7cbf31edb01fef6240cb7a121ee50bf22ed6fff	\N	fYo8xYJCrkbk61U	f2169b29-9ca1-4282-9df5-b86ff8a8eeff	t	US/Eastern	\N	3
670	INFOGRAM	$2a$12$.wRAemimvGqTnrV7Aae8vOlqxJve39VcYmH3c0VaDy3/TpzaOY0f2	info.horita@gmail.com	105	f	3c9057bdfebc0df81a4485c46756bcc9409865e3578cd385fb0ce27c0c8d0b8c	\N	GGzFFOQsLIeN43f	0cd631b9-04a1-438a-a453-6087333e8e04	t	Asia/Tokyo	\N	3
671	doublepush	$2a$12$4uM33EQM.6LnLtqVQ0bh4eejpJ.5f6Tt1RX7jeT8FD9ekG4.rMhrW	shoichiuntransfer@gmail.com	105	f	3f3c6477d371900683e0fa05a1006e26f11516ea64d931faeb74ec31ee6ac3a6	\N	EYWhAyBNGALSiIP	26b1db92-6dd8-40cc-8778-4f8884642364	t	Asia/Tokyo	\N	1
672	WH@T_WH@T	$2a$12$nBJliexy8fECgXYiWTmq.eMt.i5dMlutz7slIyRTLLg4KCnNivtQ2	ACOSTIFIED@GMAIL.COM	1	f	7660ceff10941a5c2517b13cbff5e17701b18276ff3c3a79141baa0109b16ff3	\N	XvdmXQK7rFN4XWD	1c556524-2fc8-445e-a05f-d68baa66d1f7	t	UTC	\N	3
673	12345	$2a$12$M6qzPMPkd53AWjJqkdk8Oek7SSGZH1uTm6lzIW4ILi7Cpv7/EaUX2	12345@trash-mail.com	79	f	78961375639f27ea59435208e398b63e3fcead50a139bfcb2ee44b2655cfe64d	\N	c8QlRCxdUkBCuHE	95b3474e-3932-4330-8e1c-14b67113c51a	t	Europe/Amsterdam	\N	1
674	123456	$2a$12$ahHhbjT7NNQECJguj9nXLe7IY3PsaJTIZe1W0GgyFCK8S4gbyXNwe	123456@safetypost.de	79	f	c65b689b12f54fa6986592ce6b47aa3fc87978ccec249da8f88e262c8871a477	\N	2RYk7KTmkwSrvk0	ff4ccf09-390c-4522-bd93-b3978bcc56f9	f	Europe/Amsterdam	\N	1
675	Andrewthemandrew	$2a$12$uEYCKcfMiEN35IhcF4RS1.xZao/u4jwC4b6GLzWN.ZW9cnkuUDC5O	aschwa32@gmail.com	231	f	414cb7e8a402784267c98db91c5c3b328427572bc4fc8b2f3d33326b447ca2c6	\N	6cs8mbpMH7qJDK9	248be96e-73f9-4675-91ce-6478e070f5ae	t	US/Pacific	\N	1
676	KID	$2a$12$IHkwVZvb2XlrvOCSKyk6XOGsvvVk756oOCuhNN6gXcRk5uIOLgcEC	tuananhcntt2@gmail.com	237	f	5c10f0cf57f7dd734d783d2807277db3c5075acec53aa5673edc6452e3797cac	\N	2pr0UkqhaZUpPf4	656db5d9-d7f3-4cd9-955b-723f722bd5f0	t	Asia/Ho_Chi_Minh	\N	1
677	V++	$2a$12$3MndyVShRnLG61KuHST0Y.1ZHuNRCqK/beCLRwG6GvxC73d/MMHle	alfa@virtuax.be	25	f	68a7b0423cc8e4bb1b4c0b854be93453597cd835f34adc636fbca8ded705deaa	\N	tUqrVOI74HLjNY9	07d03a2a-9633-4233-bfe7-1277f446e364	t	Europe/Brussels	\N	1
678	All_Alone	$2a$12$Xtrs3qOEUMnQBikYCoSSZ./umjwndhDfUV6RJ/448KMmqSWW2DpHa	jamal972@hotmail.com	74	f	77a57ec52d6821adbc45f4b57af8da75debe0d7fda700230b88b9854e8b75223	\N	ES1w5hEVja6TLyW	82c54777-aade-4576-a053-0f49d6659c6f	t	Europe/Paris	\N	1
679	b769803	$2a$12$2Hm1Xp0uMLdRnYlk/YE2OuDUx72oWC.KoUGiDabtKidIp0UvhG49y	b769803@drdrb.com	96	f	a509ef0d29b4160f3f0bd64078950f2503b3bdd658bc9cf722641a72d140a2da	\N	bV7cFDknAgnBuF2	51fea097-ee9a-4e20-9119-d706f13a57e1	t	Asia/Aden	\N	1
680	ran	$2a$12$q9bOZonLb7GkJgHkPhJo0OKTeF.MZJVa60C.NIlUCLYZnHyqfZJei	piscesran@gmail.com	112	f	6dc3a38cb6e462474c14fa7a0036853b957638d358e8c8f212838c113b84a1c0	\N	kBgDkRUvWJ8OzDN	a63ebeeb-1f33-429c-84f9-45c06dd75614	t	Asia/Seoul	\N	1
681	yoyteam	$2a$12$PoeLIPGkF9QWeMd5l41lM.XPYtCmu0YeMpQXxR.oGb/TDbG/BN.da	yoy345@yopmail.com	74	f	67f14a80680c37e60e62cf0493cbe7e77035abd465b713dee184d3f2063be1c9	\N	EoLF3SrDl8uW6E7	5392c5fe-255e-4019-a5c4-478c00412fec	t	Europe/Amsterdam	\N	1
682	Skiddles	$2a$12$OAkIYFgT.hV.1FURb63XmeXYf84C53E4/oRSzPhzV4OkYZXRG8u0K	rnigam@fortinet.com	74	f	6623099a73107a5d95df99232d13fc2ef9ae9806ebe74d85c61072e6d87fd4bb	734a46a98d5810aba4f10c44b47675a3bb3bcdc00ce3e485bce018ef7d0dd43d	9AzVelwSQAEiB9l	b6fd4f6c-fb1e-43d7-9a33-cb8012ecf04b	f	Europe/Paris	\N	1
683	asd	$2a$12$D6dTt8I9mICcuF7.DrPzQuwB3dCG.DsVwxPn1GhcGVzq57dBwWV8K	as@gmail.com	11	f	4c5b89517cbe25f87d2194d8fbf66e4175ec5145bba79f4866513afd00d2308f	\N	1e05bzg5qD1CMyB	e8880356-4e97-4a1b-bc0f-4c297a2c2234	f	Africa/Bujumbura	\N	1
684	mage	$2a$12$iOyytoPohl.QKmaufZl01O4kW4B46iFJlPCxYXDusfpJ.xmlosuPy	gp.regist@gmail.com	105	f	af633abbfc99f60b3cf4460bc1af045e9591d4f7291e4efb05f792ff09644922	\N	sEvLD74PYCOM0cO	179088d2-3be2-49fc-9b39-753890ce5327	t	Asia/Tokyo	\N	1
685	SaKityan	$2a$12$sk4DgQF.BoyocHeKjbe1te5jFwvqxwOfCxi3CHwVOpm1Ii23I7hDS	iwiakira@gmail.com	105	f	3c4280ca134a6f88436f8f7bea96336e2b0b6c9be1964a4ac8a3a68329d815e8	\N	yshZSBOTZScmJki	ae283f67-5e29-4836-bfb5-f6728e2fa1e4	t	Asia/Thimphu	\N	4
686	3x3	$2a$12$nK.NwhAtwOfnULwfteujZuKef4eFTaptuZway4qhadcS2Y.F51Atm	legendtanoybose@gmail.com	96	f	a16182ba45b2890141b9cee4b87bf4764a822004984a7081757c81f5deb49c3c	\N	qXuSq1gmjW79tYJ	429427d1-8270-4226-a276-5ed25083b79a	t	Indian/Maldives	\N	1
687	TM_Team	$2a$12$a7vfrt0BTeWdPEZY.6VPZeFMuFCOn2BQM5yNxLiPb7IeuBmRY5uxi	neutrino216@gmail.com	124	f	0e37dfcf9cba78437bfa565ea9f9e65288c783cff59a39c278260e15be67a27a	\N	k7QN3YYp8dMuLHb	415919b0-d551-49b8-b632-471e06951acc	t	Europe/Paris	\N	1
688	BPINFOR-51	$2a$12$cX8b12AxtcXUgidEZaRxFurRnYx9ddMv7phAng04X54NULzEtifsa	bpinfor51@netcourrier.com	124	f	6cff37576db4eb7fda9fb08002184f0ab9b9bfb6f477d3185cfc16d73e028fa1	dc29d98923e6377cbb30e7df357baa6a4d45d28ea76490c6261ce99fb573d120	09QpwSABE6J8xS3	d0eb66a2-b42a-4e91-b513-143e2711f5ae	t	Europe/Luxembourg	\N	20
689	Egida	$2a$12$dNAPexangdTpxEaHs.A4CeUPSpL7.uH9dvI5A1e7gX75PdEkVXDLO	buffer136@o2.pl	173	f	37cb99c91e19ce0eb5159ac189a63f9e6e75de96e2f95d78c76a2a0a7d05b084	\N	8BffTE5i0sGBB3K	4430255b-af1a-4638-8632-2395fd779cfb	t	Europe/Warsaw	\N	2
690	sdjfhaskdj	$2a$12$7intqfE62/C.JpY6i/vep..ab2CFGU0UmTlgPx8/18uuBIOnGmmdm	jahdjfhsda@dhsfjhsdj.com	19	f	d62280f270e264c4a21cd4e1db8de21e1922ed49036ea78fde930e5a95557392	\N	Iv7AMXZXYIJGN2W	765f0c23-3e6e-48f8-abeb-b61f0985b9c9	f	Africa/Bissau	\N	2
691	makenbank	$2a$12$56yyXHhgRrdP27Wd7w/Vuu9VqWVfe0PfDK26BtOiYfTgirsKqyD6a	nutsy@impulse.net.au	17	f	c0ee497519c1234c623ad017997392dbbd6a2fabe09d4b70bce6f743ed1f6172	\N	SBZo2eyLw47bMqJ	ef765e59-68c6-42ec-9043-663cd2aff747	t	Australia/Brisbane	\N	1
692	solo1	$2a$12$Eg1ND9OscqM99CQGr4a6g.tiQoeSKKmmPmpWczR.zE9Gm5R1cpfu.	jaideepjha@gmail.com	96	f	d49ea9e18edeb8b15e7b3c2d0aa18a3fc18df6e4504f2d29736170f782b0f8d7	\N	7THFpCIbSPbnWbn	64711639-cb64-493c-b776-17bc69e4a75e	t	Asia/Kolkata	\N	1
693	GDDQTHJ	$2a$12$PFQfh5O1WoGp35l/bo8wr.QGW41HlDw7SIuiMszAuqnMa6x75yJWm	GDDQTHJ@sohu.com	46	f	989e1179e0103c80ed190b8797acfc35142ff84021f281a8f6b489028e1dba06	\N	2baJZVU7m5uM3je	96d016d6-f58d-4987-9479-d88ea6253c37	f	Asia/Chongqing	\N	5
694	jikimi	$2a$12$64oqf9yVDML2rQW1fbO7IelJtdCYUjMbR6uErZG0uj44cDB4se9xW	lech9343@gmail.com	112	f	0c199d88d3b5d3427ccf00e8d05c2adde2f15d092eb16fffe34e4404b3390a41	edc088db8928da335a09f2f3e76150b5df736443f9fda3c737e13cfa06d97b65	LtBqLB0Eb9vX0wP	fd0a7565-16ef-4dcd-b227-887cd741856a	f	Asia/Seoul	\N	8
695	GDDQTHJ2	$2a$12$YQnKmNu6ibue32CnhwRziOwfDxlp1MDRHcwgrHEHpt1vtVIoDCgZG	GDDQTHJ@gmail.com	1	f	b55436591353c6463cbc47b93c61b9c323539ce4f3dc40be49cfbb518a0ea830	\N	1byEdiKHDCAP8Eg	6f013655-cd4b-49fb-aae9-9ffaabfc9872	t	Africa/Casablanca	\N	20
696	IntroSec2013	$2a$12$UPwXmxBtSsbFy4i5BrL4bepb62vuUrIcLX61C8Vaf2rRDCmstCAh2	garycorn90@gmail.com	124	f	ef476d40537b1c6d6859fb54de5718b046e21274a9e7194b149069ae8d2e1007	\N	ZDlkp15SCg5UrQG	42332f89-a2be-40af-8e6b-8e19c3dbe0a4	t	UTC	\N	25
697	Nhom 2 _ USH	$2a$12$aPslsonNDm4iwf8gZYeDV.j4n.5rd7U1CJASoHCWa9jsVuj05eM12	ljnuxgeek@gmail.com	237	f	267afc2c969cbeb443c53117596061c5fb5e236bff4bae33b473b354dccc2e58	\N	0mEI6BgrIHjQudr	61fe90ce-6aca-4b6b-9edd-1e90aab45a99	t	Asia/Ho_Chi_Minh	\N	4
698	fernando	$2a$12$b3BQFNem3YF/9FMgB5S3MuoRPlxYt1dzMPkoQCzxlZWRjKOYuHpC6	fernandohpvn@gmail.com	40	f	750e400060229cccc81d8c6d19ff5c3a186939a33e16108f394a451f0e327334	\N	F74K1xkaHoKuIfg	0e340358-9c6b-4128-bf31-a35da89f326f	t	Asia/Ho_Chi_Minh	\N	1
699	deneme	$2a$12$O0JEvPDYfMqOBoidzVXJ2Oy87iBiO6h/jM1kC5xPQrnMtxroubDEG	gocerler_1@hotmail.com	1	f	27491706a52310727a0416e8efb9ed4a846ade89413c80956ebcd9bf24b95001	\N	ExaCpMdBy9eFZL4	f89a6f1a-1380-4754-9f86-30542f1be067	t	America/Adak	\N	1
700	WeChall	$2a$12$H45y0SRweSi2UKHLIRK1kOchpxENIAGbbYnsB07wfSgjMrZyGQT3S	damienreilly@gmail.com	231	f	d8cdbefbc521c6a936e5cc98910a54500e09b7fa6e6b3ef527c55579585739c6	\N	0Pm0Z2znasPEtRS	ae6dc17b-ddbe-4828-ad42-c6a9a7d8b5ff	t	US/Arizona	\N	6
701	nonick	$2a$12$k8gg.2ZMqWu9Ta27PX/2yOJO6zlQ2SUH5MoXkGju6Jz.4LoQcVZ5C	b778116@drdrb.com	1	f	74aa56ece6f2cd0f7ef72b3e61783fe030037cd1973fa2680e1d29b6ace1bc83	eef61821c3120864fe3871cab5030f5a6d3416f37a3e0f6a7520be0aa3bbe21d	97VnzFyXhQInUsg	33446584-39dd-4b5e-95fd-da92910de19a	t	Africa/Abidjan	\N	1
702	RockerTeam	$2a$12$.hGL.JRcDNjK5yd7FvQXpOXkEBjtGqh6tpf0e0B4rk4qBrwmgK/Jm	abhaythehero@gmail.com	96	f	c59988db3bd260082b67a4eaad191d789a8ae55195724b47b2c4635944b6464b	\N	nWYmogj7W0y1lm7	040f4842-0bbf-4ed9-b4de-3d9ba6a39f1c	t	UTC	\N	1
703	Jerrrey's Team	$2a$12$qJLOS5jeEd7kuROPCEwO2Olh.GaUSuNPKlcfXkAvZ8CTH6PSb1.sq	pencil@yeah.net	46	f	45360632cd2f4f2b932e9b267bc5f8c6e17b0187b32bf6859220a5d460705766	\N	7uBUHBnOuFsx8DW	c8eae202-becb-4d5d-a18d-2277538d6474	t	Asia/Chongqing	\N	1
704	tata	$2a$12$xrKtacGVSzuUgu4TZBXBreZ4Nby2kGhS2Nq4JqOyS2swWD4pCdvGy	tata@tata.com	1	f	22554ac9e37690f908d1c4252cf4b527aeb5ec6df1d582c631f50eeaffb46358	\N	CoVvifi9VZCanb7	135662ff-71a5-401f-92ec-2580ce104262	f	UTC	\N	1
705	kimchibuster	$2a$12$XRh7gnrWrmTUo7FVwi9qT.skSYtVnHYiiGTFyV6xv0RLQjV.2qGtW	msh@mshac.kr	112	f	77f7b95dc801c0ff37379048a657302950488ae64c6e9674a40228ad1345ffe5	\N	ONcfOmjLpmq8g3i	d8686d64-eea3-4b38-86e1-2c216715170c	t	Asia/Seoul	\N	1
706	Hopeless	$2a$12$s9FA/og7IcQmO6nE/Q4pee1WIbFGDsH.llHFQmNjyyu9mM6CmLJRy	torgeir.natvig@gmail.com	162	f	c7779f0fcf6f614350478c131a6a81f7c97f31d4f5968697c01a13b6ca2a13eb	\N	RD99xBI92T5B3aV	a38c2b74-d1d7-4d38-931e-747dd6c57439	t	Europe/Oslo	\N	1
707	zmsf	$2a$12$R3n11hD2Zxt6y1suXksywOZtPeBm5dc//ONeJxF9gZ2CINBy.R34O	me@mohammadsamir.com	64	f	a06a5881d5d3cf025d124b3ea6cbb9dea39258f5a0fbd1510abe9168f3d9e9d5	\N	YRssWfxJ9GKrHJB	218b9e66-bdfd-4e7c-802e-8951a5db86a4	t	Africa/Cairo	\N	2
708	gcc_lovers	$2a$12$B1hxOON5zmZex58lveFi8OVAqJuXhtK2cgbXcAmKh2RWi9cSWip9a	gcc.lover@yahoo.com	1	f	c5dff26a06baab93367035b7b39402ba5f9a0ad49f5cc4606042024cb14d6654	\N	wCcWkeWOMhq4ufs	b50ac5f2-9de0-4dba-807d-3ac0268ab398	t	Africa/Abidjan	\N	1
709	275o	$2a$12$rQwn8yU5Aj9Ha5DyGmNpFO/102nk9/xzwcy7ybJoXBYnyvmLw.kBu	abrahamliao@gmail.com	231	f	e3721e09759cc3762bb5e2ea41a62cea81cd2a6287201596a4619a490c048888	\N	wMwqx1iIQz1f80N	ada0dbb3-54d4-4870-914f-14a08d9170c6	t	US/Pacific	\N	1
710	m1k3	$2a$12$mO.CwLCZvsv7I9r/ezImseGW9LSMoJy1.K7RHaH.yaPFeHWcqRd4u	mikecodesthings@gmail.com	231	f	783e68548e9110106dc7d857204b302620897c9ae6578a4457768a58f903097a	\N	08HRtqPvKTRPuPK	06c20ed5-96cc-4ca6-87d1-76f1a4672a76	t	America/New_York	\N	1
711	iPenetrate	$2a$12$ZYTykM4RVwG3U2tLd39GfOF9E70DExciI89k/Wvv.BhE2yMApXIU2	alho.jesse@gmail.com	73	f	d2ece8faf33163112bcf689e9b49394077047a6d7a2068de5f161f93b5446dc7	\N	NLSGmaxD1rQtNqL	368330fa-7b4c-47cd-aa77-cc4b4212d7ab	t	Europe/Helsinki	\N	3
712	ksec1	$2a$12$U.aJEEXG4dIb7qKKCCQAm.7pC3p1ZEZyW09CyVTCCj9dUhspkP0nq	binhminhxanh2702@gmail.com	237	f	3855019738d3237dd2928e3db6d7c4b846a7eba71148c3c99d99d745f0a3f60d	\N	hauBFo7t7tytmfE	003a891f-d4fd-4ed1-a206-62bfff4f4d27	t	Asia/Ho_Chi_Minh	\N	10
713	reTEK	$2a$12$M1GrGk6oEETYeYDEvWRlHuvLK2iNMneM7EW3ZBz7H.flZZvLLnwtG	retek_hun@group.google.com	94	f	160ba9f5ff34ba31c17eba78b955169a0ff3dfda38c1a5134309aac64515df6c	\N	dI0PuXxc2sDA75j	5e76c002-e742-40c1-b16c-8c4500b7bb97	f	Europe/Budapest	\N	2
714	Stoneage	$2a$12$a9fI39jX82h61ujz9KGw6OCwsUSNI3qSoSCSCC94W7uV/u7vKVr62	roland.korea@gmail.com	112	f	0d145faab95971474c8220944f6bbcfdd1780f4047b82ec6b04b53f306512c91	\N	TOy8HMl6hLdYTxE	18db06f7-ef2d-4816-bbb1-5056808b24b8	t	Asia/Seoul	\N	4
715	sonic	$2a$12$KJqECB/BCBA3KaZEeGugvuxZp9XxHa3zYnTK6M93KuXL1Y8XVwAcW	korea.hellsonic@gmail.com	112	f	1820b49e08779eb25367a5e637c039d74ab75e0ccb281e712f8e4cd1350671f8	\N	QDa3zK3MvouMLwb	38eb224a-c173-4375-89e1-bb72bb5eea52	f	Asia/Seoul	\N	4
716	testteam	$2a$12$HGV2i3SvUwNH7.xqQXY5vOmWgD2zuw8RJxnlNOcGp3dcmcpP867Fi	vanhoefm@gmail.com	1	f	327a61d53d3e16e7d85038dbd9aec9ebacd7c18ca17d8792e839c06c7c3bad1b	\N	GJ2ZXLahsLBs0OX	558fe8ea-fc6e-465f-a503-596180151a5f	f	UTC	\N	1
717	hcs	$2a$12$o2FtM2.ojNwL9GGuEbSn2uALl3TkGYHmve2kse9V7cShIPosXw/eK	henning.schroeder@udo.edu	79	f	e182a04315cb56dfe1a28198b47bdef12426d5ecb8731372ac5d01e8c9f7fee6	\N	kl2GlYto0F51qzt	3f19619b-0bf9-438a-920d-afe4edab5f7e	t	Europe/Berlin	\N	1
718	Z3r0	$2a$12$g8384HvvSzwtmyfZGTo.leFuzfS956DJan.UTOaVM9SM.tbghs8EC	mahfoudimohamed@gmail.com	144	f	4465b90c05243107716f0289d2fbd53f714af3546648939ec1af1007d5f2a90f	\N	3kQJXwnHtTnZx4z	851e9a2a-ab9f-4b43-aecb-9c693c10616f	t	Africa/Casablanca	\N	2
719	alonezz	$2a$12$mXEM3Cu4UaM8FcWaE3AKnOpIjRwnQMT8NjVrH7SmRxbnydVTQ46C.	toilahomnay@zing.vn	116	f	fe7fc6968de1187a43c2fa9c0a79b691a72927cdf0e908e82e0cc710881dc609	\N	wGXUdczfxlNQFjo	6eec9629-2ad7-4fb2-95a6-69d02a9fd051	t	Africa/Dakar	\N	1
721	testtest	$2a$12$H9Ya2Rkj5fyso2CtC39QjexClzPTVB0AM8URTmK0I7Q4sYa/obMA2	testtest@mailinator.com	79	f	7a75efe2d7ec9d102b4b2b1b912619dd1dadced6145c3d98865d03d1412bf259	\N	JdlPqtQMnjUWRE9	7ecb830b-56fa-44fd-99fb-b6449a3f1987	f	Europe/Berlin	\N	1
722	testtest2	$2a$12$b0fPlrWEkVXvdIFR4hPUF.wFCwm9QP2NbL.BOU1gVC6ZnDepiWS9a	testtest2@mailinator.com	79	f	2c384440685c03662681d389d5738a03bb008f421046cb081d9f40f47feed966	\N	UFowmc6MVvA9EHm	14434a06-d7de-401b-88e0-b0a1957344d4	f	Europe/Berlin	\N	1
723	testtest3	$2a$12$ovGvLKOQnaZHBE63qGAz0OnxJkOWWUhsD5whcU6a2V2Z9aXsbeEjm	testtest2@hush.ai	79	f	1c32623cc7a440e8d847a371fe4a82644d8d3bab9f70382033ca1fb3893ea18d	\N	8hnXDOoYYvTsiHS	7da93dd9-a376-4230-8775-7727f8368b86	t	Europe/Berlin	\N	1
724	Bobby	$2a$12$RqNFxB6NfNZtGFGtJpih/u/2JlAu.Dkam9zO0jK4K23jqk9SQahtG	ccclu@yopmail.com	74	f	b1594f84e949588606df934f72baeab0646ebd24b7f7f55cf3b1990736cbc8bb	\N	WCrhxufEB2xLTtp	1e37d4dd-e17b-420f-b2ef-64b24dc5fd30	t	Europe/Monaco	\N	1
725	nixnixnixnix	$2a$12$36am4QKIKKDJo.QlY2jkM.Lkgsh8Gwv9qv.IeFg1tHlJLpuFJfslm	vanilla@byom.de	79	f	16abdfae21437ec7be5072ffdf97f8c32ea38ed3869642cffcd3ee979af3dbba	\N	mjtsRk8dXTYLGy0	af6400d1-1de2-4962-bb4d-e121c5469ace	t	Europe/Paris	\N	1
726	plsno D:	$2a$12$KFgPg8Nc1xg07D3UtFYem..zLQ1Q9zhyurUz3Neb49hXJ.aasZn1O	tim@timscripts.com	231	f	73e3dd6efbf24cbf03b8cff009234c73555f6858512ef77fcfcb982b99b7c845	\N	Ai1kl1gSY5soOLQ	29d036bc-e0b0-41af-85c7-b3693fa377c9	t	US/Eastern	\N	1
727	candies	$2a$12$k/0qb./FqnNykmyoxg3/7usMx4rWMh2rF0J3K8/OqMVu7U3elVIdO	saltcandy123+hack.lu@gmail.com	105	f	87b8a1437468244d56fef11b0fd16325ef58455df2210b3159ff2cfcc0ad6861	3b81084b9f65d2a5265b85dcd7c7a67258b67d853230be7962dab1b25bd833b4	pC5RfxwhdXw3LZz	74680c8e-b263-4c70-992e-4f7c73fc5bd3	t	Asia/Tokyo	\N	1
728	N00b	$2a$12$qQ48CwYb88kAmOGVL2bHz.NQbXNbNm7v81O8alvK.HnGZ7wJh77PS	glc3@hotmail.fr	74	f	c6ffb6d00a896b7221c3525af1df0814dce9e93aacf628fbf34efe7c633b8ff4	\N	0LMTsyPSbrcho6A	2b1aca1e-0f11-43fa-8752-ed09a6c86ace	t	Europe/Luxembourg	\N	2
729	mznlab	$2a$12$vBlB/UsSI3JxbxtuyW.Mh.7lrZqsQz3DaQJQRQaGK11nXKJ8Uyzwm	mznlab@gmail.com	33	f	4a948039294af62e2740e0a47b32ec18728199986ddf13dde8e40a3e6e0d60bd	\N	ACbuMNaoTMBxtaG	11fc0176-25c7-4a96-86fb-b5e678c8c9dc	t	GMT	\N	1
730	kkk	$2a$12$VHtCk3PzF.3l6PYhrePn1.txj9.pB9DhhYWxaPWPzrVx3M/VjWuAO	vudinhthu@gmail.com	1	f	5157945aecea218bdc51197f8f76d78c5f4fdafae6ddae88db05b994993ecd23	\N	vfSzpErygRdfQYT	ab730096-c7d4-442d-b899-0b5dbcddc84f	t	Africa/Casablanca	\N	4
731	qwerty	$2a$12$8E993hvAnfZYC5U6p9MnF.MIgx21P2rM3HhpuBwASxYSM1TpZY9bW	aleqss@mail.ru	178	f	713fdd62df853dc9278883b04d671bb606ec8d6492cc62592014d9465fbfc714	\N	BoG8vaDjPSPIUb5	7d669b6c-f9cd-4b62-a3ae-3d4181ba8d49	t	Europe/Moscow	\N	1
732	PoisonedBytes	$2a$12$H1JaStmTAHjwlcrXOBDL9Ox4rrrK5dw61iSh3x.lb37bJT03Y.cwy	poisonedbytes@gmail.com	222	f	bcf329aec911bbaf73fec0906bcc0d0c3cf69dd99daeefe66484b0f0423cc470	\N	7oaEq7Y3zFXvm5F	98b01726-5dcd-47b8-8539-11c3debdc407	t	Africa/Tunis	\N	2
733	d0hwn3d	$2a$12$12BN3KfWhPWpD8WRNtOavuFsAeaSvDlgslp8L/Ln5kUlpA2J0XS0W	m4f10.s0h@gmail.com	40	f	95720989a888cc79d78ecba852b90e527b5503144755d63ae1a72d322e26fe39	\N	ZCT8v8rZO88ZjZH	fb23819a-b2e7-4526-8f72-8843b4326af3	t	America/Montreal	\N	1
734	NoNaMe22	$2a$12$j3a7IuE6DhhiK7HYipaoP.mrFrfsRe58lZJLXXtkemfplrlS7BlQG	phamhoang12@gmail.com	237	f	716d5dca80c4e398ced139597bcc27dcfa591da570bf217ddb2c410aa1195d87	\N	WWr4WUIulI261jJ	3eaddddc-9b30-42ec-9698-78f99e729c39	t	Asia/Ho_Chi_Minh	\N	5
735	st.pentester	$2a$12$/1/HTArT/eLKnhhjFq31jefjhZ/9l4FZ2BBuR.4WCjX0lIAIAiCmi	pradeeepst@gmail.com	17	f	e179f4e7c4d4f33191889bbdba1c97d28177d6639aad08ff15fc2eaf3c5d3cbe	\N	hnO1KWqULHwSgNa	84e76092-2fdc-43d7-bf74-2366be0a4157	t	Australia/Sydney	\N	1
736	Sigma Hashers	$2a$12$Edvr7maJCo5ztqLnmbMpUO55v.FIQBi8BOQyPZh7PqMHpBPWRPV6a	sigmahasher@gmail.com	96	f	529bc5eff497f001878fd03f67884fc5f968bf9126f2e2309458d27a1e257848	\N	Ate4HCeZHKJOC4f	6ec5257c-a23a-4a7a-99c9-1609baa06b86	t	Asia/Kolkata	\N	1
737	randomhax	$2a$12$R7AM8tCEsZhIHCRq7wi1a.YUKHBUTDWztTb1OAszkpLyWHwH7o.2y	kelvin.white77@gmail.com	1	f	48871b8ecbfdb415e556999bf23fcc507a9155bb8dbf3c224731344a63affb6f	\N	W9fp7oxSL5rIzRv	f72be2a6-6d90-4690-9138-fbf8e9a832f5	t	America/New_York	\N	1
738	iDjul	$2a$12$5ChohV.ZUgIrGRpMSdGYZ.bEBC5ma0wPMKJm2FucD4o38m7PlzPOy	julien.gongora@gmail.com	74	f	059efe1fffc68d97b15f62804212b4a7fdea37299fd3651f1c6879a8761d8fca	\N	1aVy0Vj7Ko5DfUh	e319a3bc-9964-4063-8e51-c7f538145248	t	Europe/Brussels	\N	1
739	pla4k	$2a$12$lszEjWcKlh0tSy4f4nB3AO5fX9G2GCElFK5FEfapt8GvpMXzyMNWG	kill.proo@gmail.com	129	f	74f5a08b9b3b3735c8e6abb2dbd5a318b9403e9f35a9a4010d6bd4dfba2902cf	\N	ugq94Qh5fI3xRJ1	4b9e5ad9-fe3d-4fa3-ae9d-8c17c420ba9f	t	Asia/Makassar	\N	5
740	ZORGOS	$2a$12$ltg0icetT.ITOC3m90pwOOtEC.m0Irxi5QGFmgq5s/hrJhUJARZbu	aminee.the.man@hotmail.com	144	f	5b2062ede0f8dc8b5a55e9f30b7ef0cb6a891f20a303ce10a0633d48d87f4a58	\N	Ptas5f2ylisveiI	8bdf798f-acb8-43e7-a718-e15953a8f377	t	Africa/Casablanca	\N	1
741	zeeman	$2a$12$w05AL6um3ouC.9tysdPRaeObD.lwKTmQFL9.4U4an79j17Fyip4Am	itsnotmine@gmail.com	14	f	eaff505ea5deb3f9c6aafd3bca133c2372823daa52cf04de9c692a295e8de14d	f62f06b422e7a750ad4c8b54fd25c389beff3ffebd6535924a7cc22adfd6b1a7	xQqQBbQ9mLUnUvw	e78844c2-1121-426a-8c3d-0860cba016e5	t	Africa/Blantyre	\N	1
742	rwx	$2a$12$JIZJkEKOgSCpOW0f.8xXVO6DtYN5/psV3vB8LzxKtzYmbBd7OyvVW	no.free.name.at@gmail.com	178	f	c197e8bf7c23c05ad29023a649208b76bed1f448e6af8f7346af3da6c3340c29	\N	4SRfVBTpVsrVYUI	d0b84d96-a7e9-4852-a5f7-5ac4a83a08c1	f	GMT	\N	2
743	THE fre0x41qshow [GER]	$2a$12$jBpBGN55.fkFcdbu9JQJKuxOcxYu1wwllDv.I/i6hD1vHlBaHR0QG	fre0x41qshow@gmail.com	79	f	97770643575fc40aaeae761484b36d1a30fedbbe5b7d4f0f55d6847e5a0e00b4	\N	seE3au2zS8aRm62	899281cd-0cef-47d5-902c-a683c7cae5a4	t	Europe/Berlin	\N	1
744	V33R	$2a$12$c9IdtGlfndGf/P4CtBHqGuf2fT4jz9Jp66k2s.jcFW3f9vtof6HLi	v33r.ctf@gmail.com	96	f	0d01329b959c744df7e306d2bd57cb3e2469648a3a2394fc82626a8a66520dd3	\N	i70M1UKVBlJb4qc	bdba0348-d5f0-4cbf-85f8-a45a5fb53756	t	Asia/Kolkata	\N	1
745	sme	$2a$12$KoXtIIUqxX2W.KMaIJ4mj.4U.HANomDk6LHb3PGEGvnM.kRUP0Mhy	s.meriah@gmail.com	74	f	32d11ccaa532a76cb108d62b7cd0d86ab421440aa2b75b4a0ad541fa566cea6f	\N	Ih1RUsytvAjEXVt	87d1afb9-e8da-4c91-aebb-f569467b7733	t	Europe/Paris	\N	1
746	Acronym	$2a$12$atBK49aiaSTtfsOLk7mnyudCz47Y.1H1908CFa2sYzVZSeX8.rhQO	root@acronym.pw	231	f	c0200721f556d1e077c2987b4f0ce06e92c8c1e4f950740f7abadb1a8ab6af53	\N	0IbEboM95EoQNpA	08d1dcd7-b3bf-46e4-b490-becd2180185b	t	US/Eastern	\N	1
747	ccbb	$2a$12$cxq.qVNRPo/50hgQcOGnk.fANAi9iLB.kgrg5M73vH1/GBrjjFW5S	caonguyen4m@gmail.com	237	f	abdb073b20b0f38415a164b3a469c6efb7cf4fcc2373a204d34f40fd893cd06c	\N	gAC8nCZkNpNoFNL	4f6d6ceb-30b3-4801-93c7-7381f95c664b	t	Asia/Ho_Chi_Minh	\N	\N
748	slowpoison	$2a$12$iX2EfKcp5DDBA.N52F1oQOB0TZqcGIRreehmsQVmZhDTGpKahXrMS	yuppie4ever@gmail.com	231	f	8631c07805588dec26f138631770ee1ca2bad4c3d6683a2b37b09ce2a32d3363	\N	ED9Dgx1XHbt32iY	573b59d5-1e33-4f2e-b68a-6c8b11cffc1f	t	US/Pacific	\N	1
749	croot	$2a$12$KA/3/SKyBcuSbV.RCDIrdeEhn0PdF/yyQzkg/.6sGd6ZEtG84YeZ.	corlean@safe-mail.net	1	f	7a28abd39185e61f64f04b4f42f757be76e30694a152878f5902d7220ef175c0	\N	OHpguytMAAbDaHg	c55d90cb-e43d-494e-82ce-9387644f8dc0	t	Europe/Zurich	\N	1
750	Flying GatotKaca	$2a$12$5E6z434cymcPVtzHYOwRTumNs3q1ar5Xx0xl5OqcGSLT.Z0D9TDg.	bluehaxor@yahoo.com	97	f	4f30feea8c88f2fa52a95255f0d831dd8c83571a7e44cbd33747e1330b1c283f	\N	r6xpykd1P7Kd0Rb	b6c564f6-1d6a-4729-91f3-9c4b16e48cfd	f	Asia/Jakarta	\N	1
751	a3d	$2a$12$Ha9ZVzi8XK1akf87hoCv6uZrkQQF0nOE31ORQ0MVhq2amDAbxlSIe	atlantic777@lugons.org	193	f	e681716925cea3737f4198128d71d140be02984e8e85470e8e523eb3645ecf49	\N	Q0wOR7yLTzCWC9g	89e97b26-b4a4-4d9d-87cd-0f91954f3c59	t	Europe/Belgrade	\N	5
752	Li Ching	$2a$12$3yoIa7Cz4EV9qTYwHN5Qhex18TYKfkVXfcL6skplq77Gag1u9.iMy	a713n@gmx.com	1	f	e03d2bd7264310219f4a68cea95db54a18d2b51e60a2a7104a55e45ff3b9117a	\N	QAmBS7YqHdaTgSC	1ab471a7-736c-430c-a7cb-800c835e07b9	t	Europe/Rome	\N	1
753	s1l3ntjudge	$2a$12$X.48POqcmxVHXyfavOCWPOlysXzwUi58YRe4e2nuBipI7612hwGQO	th3s1lentjudge@gmail.com	231	f	c6ca6fb8292c4c8c8f9b782503c24c3afe3bc8da15d3da4861c31e378e57cc42	\N	8LjklRk0fVgB8eV	0fcd41fa-b76a-40cd-88c7-8ae57d6cc505	t	America/New_York	\N	1
754	BeatsAndHacking2	$2a$12$ZSANFTgHYpWKBbpD62XnV.ImeieypDkRcvAUfbVGntE3Q.d8mP5Du	basurainet@gmail.com	204	f	ef8e1f2aad4dd7eeb4f5aaace267c15677cf80338929da4114b1e8f13663d744	\N	TF2vN5adpYXmFs4	93d9f9f1-5bcc-4b31-bef7-41c44fe45bab	t	US/Pacific	\N	4
755	Jake&Palz	$2a$12$cTsNDrNIzgUhoazv7hUFpeG4q0ruPwz5STw4Rl9EwEKTZHpIwbol2	jakeherman3@gmail.com	231	f	ba34f88dab2a12c884612e370a069d17a7dd8b46c2d385ab0fe0c6b3ec440940	\N	v8aZTsmH6l6jrOy	5d0d3f45-8886-4972-bf6d-39a50fe369ae	t	America/New_York	\N	3
756	Wild Netcats	$2a$12$/DXwZ6EghfEcmvZbpL/IHOkF3nzOvQcZtKDIkdeqk3od59pXREtN6	sunyitncsclub@gmail.com	231	f	d5b9e12bed11b4550cc0f4fa141bca376232f8f08e12f1c5f884a299cf6b1c5b	\N	7VMdBWiDRfHiCQL	057d6877-795b-4664-8e04-56484c63cf86	t	America/New_York	\N	15
757	justme	$2a$12$rBEaXNPXoa.RMDISgTpFEu/Mqo3HD58mlOUyuP5whxKY2S7ArhMru	roy.luongo@gmail.com	231	f	ff02be9fb21dc593384848247605a247eb14d422a9cf0d1b0e9734c073f4165f	\N	TOOUbwgCdHRbNNQ	abfe3928-b444-4b26-988e-28056138f25e	t	America/Los_Angeles	\N	1
758	noobguy	$2a$12$5LDGmCxnhhgCrZkf3R4Kgeo1SER40EXVjP0wYBw1p6HWt4X8c.jna	ruchir.patwa90@gmail.com	231	f	bcad0f42ec41f1c6a17ae229cdabbf9557805b8e2412155874d0170fa016261d	\N	Z98Wp9W2RXR2f8x	8ce57100-abdc-4a83-959d-e5548473a680	t	America/Los_Angeles	\N	1
759	Ana	$2a$12$0tNNKoxqMRmrPBKfKj9/3.CS.6F19PoP.ZswI8A2PBVbCIKr2Th.C	200irene@gmail.com	231	f	89ca653690ab2ddd6c63ef67dec9a4651269bc1ad7db2189245dfef158cae2f3	\N	JmoV0Px6fOtZxKw	61e0714a-6c01-41e3-ae55-57f52b843701	t	US/Alaska	\N	1
760	AnhHungRom	$2a$12$MYKgTgS3Cp2Y.jRDPuko4u.36PE1BTyfoNfMXwo34nDFYaYE17cDi	quyetbh@yahoo.com	237	f	9bcf8c7ef84823061e94e3921766396212d11efdec79b5040c82e5f253ad2264	\N	U6DO65uLiqnP2Yp	9599bafe-d322-402d-a384-d30b8c7fd7ae	t	Asia/Ho_Chi_Minh	\N	10
761	Ne0nd0g	$2a$12$HXg55ZnZ26KdMIA9fXazYOf2vBy.YOD/MAUOUjpk3pMcOHHwHzwMS	Russel.VanTuyl@gmail.com	231	f	1a75c5d667e1b61aa894629e8540fe5737cdfea2f3a6827a00ca2a38be19a0d7	\N	s8zH0xWV8VvmNGW	801ab6d6-38d1-4e6f-b418-af5de46b8394	t	America/Chicago	\N	1
762	piglatin	$2a$12$dOZygesaTx5dd55ZV1Ic2.WiuXdMBUHn02AhKQEQEwA4K6Kbw4hS2	blizzard8lack@gmail.com	1	f	b833964cc2450471bbe23e9f2d30c437d9d563aad12b3179c45ce89029d73489	\N	QZdAgua9WIYJnGZ	ea096f80-f7c1-4772-8749-4a3637e9e403	t	Africa/Abidjan	\N	1
763	i wish i had friends	$2a$12$JlXCXXAPEKp5XNeRdcOBKO1x0Ve9hx/xbu5qGZ3VuebGyYnka9I9e	fire0088@gmail.com	231	f	9216fdc943737cfe3830a82556a5e811251bea2dc76de586ba73faa6e38bbccf	\N	QuhxTtCJ8NyCieJ	2b684229-b5e4-4cd8-b561-a603d7bf6dcb	t	America/New_York	\N	1
764	RAW	$2a$12$3yVwC3PWLkZvH.Jn1Aql4.0vpeZiddJhZPCducQaEkqZ7x9052TAu	shinto143@gmail.com	96	f	9c2eb4f66bd8c176c43049c564a3bfc7c28bc320ef5c12535f9b217b2dfce58c	\N	P6de7V2smx2FuPu	90c77f2d-977b-49b7-a3a6-0f5a48672699	t	Asia/Kolkata	\N	6
765	wilson	$2a$12$GppaN92alhfaS6lnM.pDG.JobC5rngf9NBO9.wOpt8RLrhM8OXBEC	net0pssec@gmail.com	96	f	49216c505df8b3ea279eb8f3ea8119982566aab49ee1aa76174b0ab3096d31e7	\N	Yttyz0KtP19gyqX	30e3814d-0181-4c08-850e-06f7905409b2	f	Indian/Cocos	\N	1
766	RR	$2a$12$EChWr/vzEoWJL18R8XidIOHpLhwHeVTYpwKrjVj4zN9WW9tD9Q9L6	rui.joaquim@uni.lu	124	f	589649d06d2fbf3f24dc4be330e54ea808daf7172b42fa4c9a7c8a3f9e44d9f8	\N	OERtTFCfA9dyvFO	6d63c48a-145a-445d-89d6-eee284ef0eeb	t	Europe/Luxembourg	\N	1
767	amir.a.r	$2a$12$dSeYLhZ7VYERThRIvBY47u0j8NCvGIbyGBxBorkYJ2uFZZvUSAS/W	amir.alipour.r@gmail.com	98	f	6aab5d01e48793f9b64d7e0db597bb95175abd419b729582284a16e16d9b608f	\N	KOZ0ad8WakL36ZJ	e7f10929-0cf8-4d02-8308-90c84f328c1b	t	Asia/Tehran	\N	1
768	Dolby	$2a$12$MWiAb4CY1seXjhCbWtJo2.FH6opnysdiFLwCF7BRqvm94nclvI2la	dolbeau.baptiste@gmail.com	74	f	3515266f34a6813fc4bc1de9088044ae7a851a257d1215fb87ef260a9f375c1b	\N	EuOBrwi1mphZr3J	4b327368-7c42-4108-b9f9-c852d1a4e9be	t	Europe/Paris	\N	1
769	Semi	$2a$12$mcWPg8Rfi14ceSukOqF6uuuDmW/lbZli/DQQ/rKb0bgRU/kBNO/W2	kaikaikai1219@gmail.com	1	f	eb045431abe256ad47d88ed751b039d8fc9f8bb7b24ee82f51a56d0c5b9759ec	\N	FHxyCNJW0dc764C	96a18f7f-953d-4ef6-9d36-8d04c14eb358	t	UTC	\N	5
770	ton	$2a$12$IFTHXo4BF240NCwKr09RjepywF2HZksYWhO7uHoMPUq8trnIbIgBi	ton@madison-gurkha.com	151	f	6a925f356e852fd3b743dcf47c78a2b59d2d2c65ed55e5a4fb30e3265dff3a08	\N	oGyh1mIU2y5H60D	069cf248-f1cc-4601-976c-cf55be423db0	f	UTC	\N	1
\.


--
-- Data for Name: team_flag; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY team_flag (team_id, flag) FROM stdin;
\.


--
-- Name: team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: javex
--

SELECT pg_catalog.setval('team_id_seq', 1, false);


--
-- Data for Name: team_ip; Type: TABLE DATA; Schema: public; Owner: javex
--

COPY team_ip (team_id, ip) FROM stdin;
2	130.89.161.127
2	130.89.161.177
2	188.200.98.4
2	194.154.214.210
2	194.86.25.98
2	195.169.99.138
2	195.169.99.212
2	213.73.155.200
2	77.173.184.154
2	80.101.80.236
2	80.57.137.4
2	83.162.103.141
2	84.107.136.6
2	84.245.0.186
2	84.245.46.151
2	88.159.80.144
3	109.89.16.3
3	178.254.72.9
3	31.22.122.2
4	181.64.199.185
4	181.64.199.246
4	190.117.170.102
5	130.83.229.216
5	141.12.67.1
5	176.9.40.77
6	113.181.22.26
6	123.24.26.24
6	14.160.64.50
6	184.95.55.22
6	42.113.90.20
7	109.163.233.195
7	171.25.193.235
7	173.254.216.66
7	193.107.85.62
7	199.254.238.44
7	212.63.218.1
7	217.115.10.133
7	31.172.30.1
7	37.130.227.133
7	5.56.185.2
7	62.159.96.82
7	77.187.175.143
7	77.187.220.62
7	77.247.181.163
7	77.247.181.165
7	78.108.63.46
7	84.158.19.1
7	91.213.8.236
7	91.43.248.7
7	94.23.253.163
7	95.130.9.89
7	95.208.107.35
7	96.47.226.20
7	96.47.226.21
8	1.202.222.147
8	101.5.102.96
8	101.5.137.238
8	101.5.139.150
8	101.5.141.189
8	101.5.141.41
8	101.5.146.218
8	101.5.159.106
8	101.5.218.244
8	106.187.94.185
8	111.194.202.228
8	114.247.110.8
8	114.247.172.194
8	114.255.40.39
8	115.236.63.2
8	118.114.242.227
8	118.194.241.3
8	118.195.65.0
8	121.14.98.46
8	124.127.108.135
8	125.39.9.133
8	128.237.196.232
8	128.237.207.242
8	137.189.204.189
8	162.105.146.245
8	166.111.131.62
8	166.111.132.164
8	166.111.132.83
8	166.111.58.204
8	173.213.113.111
8	178.208.255.123
8	180.180.122.214
8	183.16.110.154
8	183.16.124.48
8	186.238.51.149
8	190.111.122.2
8	190.128.170.18
8	192.154.108.126
8	192.99.0.172
8	202.112.51.211
8	202.152.6.10
8	202.95.192.46
8	211.142.236.135
8	218.75.123.186
8	222.131.155.183
8	222.18.158.213
8	27.211.146.58
8	41.78.26.154
8	42.120.74.203
8	46.249.66.50
8	5.199.166.250
8	54.245.33.122
8	59.66.122.209
8	59.66.24.38
8	59.66.24.84
8	60.190.129.52
8	65.49.68.69
8	65.49.68.82
8	8.35.201.100
8	8.35.201.101
8	8.35.201.102
8	8.35.201.103
8	8.35.201.112
8	8.35.201.113
8	8.35.201.114
8	8.35.201.115
8	8.35.201.116
8	8.35.201.117
8	8.35.201.118
8	8.35.201.119
8	8.35.201.48
8	8.35.201.49
8	8.35.201.50
8	8.35.201.51
8	8.35.201.52
8	8.35.201.53
8	8.35.201.54
8	8.35.201.55
8	8.35.201.96
8	8.35.201.97
8	8.35.201.98
8	8.35.201.99
8	96.44.173.118
10	106.187.47.17
10	109.163.233.195
10	109.173.29.229
10	109.74.151.149
10	110.93.23.170
10	128.117.43.92
10	128.2.142.104
10	128.208.2.233
10	128.52.128.105
10	128.6.224.107
10	141.138.141.208
10	144.76.16.66
10	162.213.1.6
10	162.213.223.139
10	162.218.95.121
10	162.221.184.64
10	162.243.23.22
10	162.243.62.94
10	166.70.207.2
10	171.25.193.131
10	171.25.193.20
10	171.25.193.21
10	171.25.193.235
10	172.245.44.177
10	173.208.196.250
10	173.230.138.96
10	173.242.121.199
10	173.254.216.66
10	173.254.216.67
10	173.254.216.68
10	173.254.216.69
10	173.255.210.205
10	173.255.248.29
10	173.48.45.20
10	174.136.98.202
10	176.31.143.182
10	176.31.184.126
10	176.61.137.221
10	176.9.122.78
10	176.9.140.103
10	176.9.203.132
10	178.17.170.19
10	178.175.131.194
10	178.18.17.111
10	178.18.17.174
10	178.18.83.215
10	178.32.172.126
10	178.32.210.159
10	178.32.252.34
10	178.33.169.35
10	178.33.169.46
10	178.63.169.84
10	178.63.97.34
10	18.187.1.68
10	18.238.1.85
10	180.149.96.169
10	180.149.96.170
10	184.105.182.85
10	184.105.220.24
10	184.66.3.178
10	185.2.31.195
10	188.186.123.149
10	189.209.113.88
10	192.228.104.221
10	192.241.220.137
10	192.241.226.234
10	192.241.230.170
10	192.241.86.124
10	192.252.217.33
10	192.3.116.166
10	192.43.244.42
10	192.81.249.23
10	193.107.85.61
10	193.107.85.62
10	193.110.157.151
10	193.138.216.101
10	194.104.126.126
10	194.132.32.42
10	195.168.11.108
10	195.176.254.140
10	195.180.11.247
10	195.191.16.63
10	195.228.45.176
10	195.37.190.67
10	195.46.185.37
10	198.175.125.102
10	198.23.164.6
10	198.245.51.188
10	198.50.177.195
10	198.50.236.217
10	198.50.251.27
10	198.96.155.3
10	199.15.112.86
10	199.19.110.166
10	199.241.186.150
10	199.254.238.44
10	199.48.147.35
10	199.48.147.36
10	199.48.147.37
10	199.48.147.38
10	199.48.147.39
10	199.48.147.40
10	199.48.147.41
10	199.48.147.42
10	2.60.230.104
10	204.11.50.131
10	204.12.235.20
10	204.124.83.130
10	204.124.83.134
10	204.8.156.142
10	205.164.14.235
10	209.15.212.177
10	209.15.212.49
10	209.17.191.117
10	209.222.8.196
10	209.234.102.238
10	212.114.47.52
10	212.186.51.184
10	212.232.24.57
10	212.63.218.1
10	212.63.218.2
10	212.83.151.15
10	212.83.151.18
10	212.83.151.26
10	212.96.58.189
10	213.108.105.253
10	213.138.110.88
10	213.163.72.224
10	213.165.71.31
10	213.180.70.24
10	213.186.7.232
10	213.239.214.175
10	213.61.149.100
10	216.119.149.174
10	216.218.134.12
10	217.109.144.123
10	217.115.10.131
10	217.115.10.132
10	217.115.10.133
10	217.115.10.134
10	217.13.197.5
10	217.16.182.20
10	220.117.150.36
10	23.29.121.166
10	23.88.99.18
10	23.92.30.134
10	27.124.124.122
10	31.172.30.1
10	31.172.30.2
10	31.172.30.3
10	31.172.30.4
10	31.185.27.1
10	31.41.45.235
10	37.0.123.207
10	37.130.227.133
10	37.139.24.230
10	37.153.194.171
10	37.218.245.204
10	37.221.160.203
10	37.221.161.234
10	37.221.161.235
10	37.251.95.134
10	37.58.94.42
10	37.59.162.218
10	37.59.163.222
10	37.59.40.61
10	37.59.7.177
10	37.99.79.13
10	38.70.17.69
10	4.31.64.70
10	46.160.45.37
10	46.165.221.166
10	46.167.245.50
10	46.249.33.122
10	46.249.58.148
10	46.38.63.7
10	5.100.249.68
10	5.104.106.97
10	5.135.152.208
10	5.199.130.188
10	5.199.142.195
10	5.254.96.81
10	5.255.80.27
10	5.34.241.111
10	5.35.249.38
10	5.79.81.200
10	50.133.183.237
10	62.197.40.155
10	62.212.67.209
10	62.220.135.129
10	62.75.217.22
10	64.113.32.29
10	64.188.47.163
10	64.31.47.117
10	65.183.151.13
10	65.49.60.164
10	66.109.24.204
10	66.146.193.31
10	69.147.252.44
10	70.184.237.31
10	72.52.91.19
10	72.52.91.30
10	74.200.252.52
10	77.109.138.42
10	77.109.139.26
10	77.109.139.87
10	77.244.254.227
10	77.244.254.228
10	77.244.254.229
10	77.244.254.230
10	77.247.181.163
10	77.247.181.164
10	77.247.181.165
10	77.37.146.56
10	78.108.63.44
10	78.108.63.46
10	78.248.26.211
10	78.41.200.38
10	78.46.66.112
10	78.63.212.14
10	79.134.234.200
10	79.134.235.5
10	79.172.193.32
10	8.28.87.108
10	80.255.3.74
10	80.70.5.14
10	81.169.153.101
10	81.193.153.236
10	81.210.220.9
10	81.7.13.4
10	81.80.228.20
10	82.113.63.206
10	82.135.112.218
10	82.154.134.32
10	82.196.122.129
10	82.196.13.177
10	83.133.106.73
10	83.169.40.140
10	83.177.96.71
10	84.122.75.253
10	84.25.78.229
10	84.32.116.93
10	85.10.211.53
10	85.166.189.172
10	85.17.177.73
10	85.17.24.95
10	85.214.52.156
10	85.214.73.63
10	85.25.208.201
10	85.25.46.235
10	85.31.186.106
10	85.68.19.161
10	85.68.43.16
10	85.93.218.204
10	87.118.91.140
10	87.236.194.158
10	87.98.250.222
10	88.150.203.215
10	88.190.14.21
10	88.191.158.147
10	88.191.159.232
10	88.191.190.7
10	88.198.120.155
10	88.198.14.171
10	89.108.86.11
10	89.163.171.250
10	89.187.142.208
10	89.187.142.96
10	89.22.98.56
10	89.221.249.161
10	89.239.213.168
10	89.79.83.166
10	91.121.156.156
10	91.121.232.224
10	91.121.232.225
10	91.121.232.226
10	91.121.248.217
10	91.121.248.220
10	91.121.248.221
10	91.138.20.50
10	91.138.253.244
10	91.194.60.126
10	91.207.183.244
10	91.213.8.235
10	91.213.8.236
10	91.213.8.43
10	91.213.8.84
10	91.219.237.161
10	91.219.237.229
10	91.219.238.107
10	91.233.116.68
10	93.115.82.179
10	93.115.87.34
10	93.155.211.93
10	93.167.245.178
10	93.182.220.185
10	93.184.66.227
10	93.189.40.230
10	93.72.98.246
10	94.103.175.85
10	94.126.178.1
10	94.242.197.84
10	94.242.204.74
10	94.242.251.112
10	95.128.43.164
10	95.130.10.70
10	95.130.11.247
10	95.130.9.89
10	95.131.252.1
10	95.140.34.188
10	95.170.88.81
10	95.211.6.197
10	95.211.60.34
10	95.222.204.113
10	96.39.179.44
10	96.44.189.100
10	96.44.189.101
10	96.44.189.102
10	96.47.226.20
10	96.47.226.21
10	96.47.226.22
10	98.112.235.34
11	70.191.121.149
12	163.5.121.75
13	152.66.157.124
13	152.66.179.34
13	152.66.180.107
13	152.66.183.137
13	152.66.249.31
13	193.136.166.249
13	194.210.220.248
13	194.210.221.58
13	194.210.221.81
13	198.7.58.83
13	212.96.33.81
13	80.98.119.174
13	85.244.40.172
13	85.244.44.236
13	86.59.204.199
13	86.59.237.170
13	89.133.14.133
13	89.133.37.152
13	89.135.105.1
13	99.198.108.116
14	110.78.173.79
14	118.98.237.206
14	119.30.39.1
14	120.28.8.194
14	122.255.58.121
14	124.248.211.170
14	125.162.149.223
14	140.130.81.4
14	143.93.249.2
14	143.93.51.209
14	175.139.246.45
14	178.219.12.210
14	178.6.172.44
14	180.152.100.217
14	182.160.110.221
14	185.4.253.106
14	186.129.250.136
14	186.46.160.189
14	186.65.96.30
14	187.120.208.211
14	190.0.33.18
14	190.1.137.102
14	190.124.165.194
14	190.128.233.78
14	190.167.214.134
14	190.181.27.24
14	190.205.250.65
14	190.232.225.186
14	190.82.101.74
14	194.141.252.102
14	194.19.245.45
14	195.39.167.45
14	195.49.20.2
14	196.28.228.253
14	197.160.56.108
14	197.243.40.108
14	201.144.87.194
14	201.216.169.214
14	202.79.52.53
14	203.189.136.199
14	206.251.61.236
14	207.232.27.12
14	210.56.29.60
14	212.12.160.48
14	212.98.161.106
14	213.131.41.98
14	213.244.81.17
14	217.19.216.87
14	27.101.113.245
14	31.209.99.187
14	41.134.21.185
14	41.188.38.161
14	41.191.204.87
14	41.193.36.226
14	41.208.150.114
14	41.215.33.66
14	41.225.3.117
14	41.59.17.36
14	41.67.16.36
14	41.78.79.50
14	46.144.137.170
14	5.98.86.141
14	58.96.150.82
14	62.162.6.11
14	62.173.37.203
14	62.173.43.73
14	62.37.237.16
14	78.111.55.164
14	78.134.255.42
14	78.28.145.2
14	79.175.187.2
14	80.241.44.98
14	80.242.34.242
14	80.90.161.130
14	80.90.57.63
14	81.166.183.108
14	82.137.247.134
14	82.208.161.130
14	85.125.107.18
14	87.229.80.217
14	88.150.211.212
14	88.68.208.77
14	91.103.91.45
14	91.203.140.46
14	91.230.254.2
14	91.67.204.4
14	93.191.121.135
14	93.212.2.163
14	93.212.50.92
14	93.212.56.164
14	94.200.108.10
14	94.242.211.161
14	95.159.105.2
15	128.187.80.2
15	128.187.97.18
15	128.187.97.20
15	128.187.97.24
15	206.29.182.253
17	103.6.85.94
17	128.111.41.195
17	128.111.41.196
17	128.111.41.198
17	128.111.41.204
17	128.111.41.206
17	128.111.41.213
17	128.111.41.216
17	128.111.41.221
17	128.111.46.239
17	128.111.48.6
17	129.10.110.48
17	129.10.112.47
17	129.10.8.74
17	137.135.170.182
17	155.33.174.103
17	159.253.145.150
17	167.220.26.107
17	169.231.100.68
17	169.231.103.96
17	169.231.116.128
17	169.231.118.153
17	169.231.118.176
17	169.231.118.200
17	169.231.118.215
17	169.231.119.167
17	169.231.122.125
17	169.231.30.77
17	169.231.81.142
17	169.231.85.72
17	169.231.87.57
17	169.231.87.97
17	169.231.88.32
17	169.231.9.128
17	169.231.92.104
17	173.193.202.116
17	173.255.219.77
17	173.48.207.144
17	184.189.229.233
17	186.215.255.210
17	207.154.97.26
17	65.215.1.12
17	65.96.126.230
17	68.6.126.228
17	68.6.34.3
17	68.6.66.131
17	68.6.73.224
17	68.6.83.57
17	68.63.187.247
17	72.194.213.172
17	72.194.221.173
17	72.200.76.209
17	74.111.235.163
17	75.144.181.206
17	78.111.55.164
17	98.171.163.128
17	98.171.163.162
17	98.171.164.59
17	98.188.150.207
18	1.234.65.110
18	105.158.96.60
18	109.185.116.199
18	109.207.61.14
18	109.92.21.179
18	110.50.80.30
18	115.124.72.62
18	115.248.217.178
18	116.12.83.10
18	117.36.231.239
18	119.30.39.1
18	133.242.206.94
18	175.136.192.5
18	180.183.234.206
18	180.94.69.68
18	182.50.64.67
18	185.12.46.151
18	186.190.238.65
18	186.4.224.12
18	186.88.167.47
18	188.95.32.186
18	189.22.138.168
18	190.124.165.194
18	190.248.132.54
18	190.38.28.219
18	190.99.75.3
18	195.222.36.86
18	196.201.20.134
18	200.46.24.114
18	200.7.33.250
18	202.170.83.212
18	202.71.101.187
18	212.126.122.130
18	213.244.81.17
18	217.108.149.65
18	217.15.224.47
18	217.19.216.87
18	41.141.107.203
18	41.191.204.87
18	41.215.33.66
18	41.250.73.108
18	41.59.254.18
18	41.67.2.2
18	46.193.65.78
18	62.141.113.50
18	62.201.207.14
18	72.29.4.111
18	77.242.22.254
18	77.48.185.122
18	78.130.136.18
18	78.217.42.7
18	80.242.34.242
18	80.90.161.133
18	82.128.124.174
18	82.226.61.252
18	82.67.114.213
18	83.235.177.207
18	84.40.111.206
18	85.170.115.129
18	86.217.217.63
18	88.172.224.55
18	89.82.213.218
18	90.20.111.200
18	92.156.181.119
18	93.125.83.79
19	46.236.97.101
21	106.51.174.196
21	106.51.37.0
21	115.241.73.218
21	115.241.86.126
21	115.242.199.194
21	117.193.164.237
21	117.193.175.106
21	117.193.181.255
21	117.217.184.252
21	122.172.227.2
21	14.140.125.213
21	14.97.195.117
21	167.220.225.228
22	134.155.209.115
22	134.155.24.136
22	134.155.24.246
22	134.155.244.182
22	134.155.249.127
22	134.155.95.10
22	134.3.209.104
22	141.72.128.124
22	141.72.156.105
22	2.245.141.179
22	2.245.174.160
22	2.245.179.181
22	2.245.184.185
22	205.217.228.116
22	37.24.149.33
22	79.255.123.170
22	82.113.106.34
22	82.113.121.47
22	84.163.176.223
22	87.149.144.236
22	87.149.146.20
22	89.204.135.250
22	89.204.138.182
22	89.204.139.101
22	89.204.139.186
22	95.208.30.17
22	95.88.31.234
23	130.225.98.240
23	188.181.86.174
23	192.38.109.188
23	195.215.168.216
23	2.111.29.58
23	80.62.117.238
23	93.163.32.182
23	95.166.128.231
24	140.32.16.3
24	50.76.142.206
26	178.195.120.69
30	46.182.51.110
31	109.205.248.234
31	176.209.56.10
31	188.244.188.0
31	188.244.188.1
31	188.244.188.2
31	37.140.174.140
31	46.161.41.211
31	46.46.142.163
31	80.250.160.17
31	95.143.216.212
32	141.85.0.105
32	141.85.225.204
32	172.56.8.205
32	192.88.166.1
32	78.96.109.76
32	80.112.168.188
32	86.121.79.173
32	92.86.141.4
33	109.191.224.5
33	109.191.233.172
33	109.233.56.76
33	188.134.41.26
33	188.64.170.221
33	188.64.171.181
33	194.154.214.210
33	197.220.195.174
33	46.38.63.108
33	50.57.140.135
33	84.49.40.100
33	91.221.66.52
33	95.140.90.116
34	91.219.24.97
34	91.77.172.31
34	95.31.12.128
35	118.68.38.63
36	155.207.217.197
36	155.207.217.58
36	2.85.58.192
37	129.241.129.146
37	193.190.138.250
37	193.198.16.211
37	84.193.76.32
37	87.104.147.19
37	87.2.107.249
37	91.97.13.35
37	91.97.49.210
37	91.97.66.165
37	91.97.96.158
37	95.237.111.46
39	109.175.6.188
39	128.72.71.82
39	180.211.134.66
39	180.94.69.68
39	190.151.144.42
39	201.211.97.230
39	202.52.12.26
39	203.83.6.5
39	217.78.187.34
39	46.242.19.121
39	46.29.154.3
39	77.246.106.117
39	77.37.145.196
39	79.165.163.1
39	80.250.160.107
39	80.250.160.31
39	80.250.160.33
39	82.114.95.238
39	85.143.112.33
39	85.143.112.35
39	87.229.26.141
39	91.194.227.241
39	91.223.176.174
39	91.223.176.5
40	109.165.109.105
40	109.165.124.103
40	193.189.127.179
40	195.208.224.76
40	31.23.148.182
40	31.23.247.184
40	31.23.66.184
40	46.61.63.237
40	87.244.137.96
40	88.198.55.109
40	93.178.104.26
40	94.77.183.86
41	142.137.223.171
41	142.195.251.128
41	173.176.167.193
41	173.198.254.212
41	184.160.52.106
41	24.114.90.50
41	24.37.129.50
41	69.165.194.76
41	70.83.228.60
41	94.23.195.73
41	96.127.201.83
42	193.138.216.101
42	194.151.122.202
42	194.151.122.205
42	213.125.82.186
42	37.221.161.234
42	77.173.207.154
42	82.171.246.172
42	82.173.36.31
42	83.84.149.4
42	84.106.113.155
42	86.85.29.172
45	134.169.216.103
45	134.169.216.122
45	134.169.216.134
45	134.169.216.142
45	134.169.216.154
45	134.169.216.61
45	134.169.216.63
45	134.61.139.43
45	134.61.156.84
45	134.61.96.208
45	144.76.7.118
45	149.201.35.149
45	149.201.35.55
45	158.255.213.194
45	176.199.174.67
45	178.203.154.49
45	213.54.3.193
45	213.54.85.137
45	37.24.144.224
45	37.24.144.251
45	37.24.86.131
45	37.4.181.20
45	46.246.126.22
45	46.246.42.218
45	46.246.93.23
45	77.11.49.241
45	78.35.193.168
45	89.0.27.157
45	89.0.28.17
45	89.0.30.193
45	89.0.30.201
45	89.0.52.64
45	92.63.173.116
45	92.63.173.118
45	93.129.19.128
45	93.223.194.109
45	93.223.204.229
45	93.223.207.210
45	95.91.244.255
45	95.91.245.59
48	141.18.132.168
48	141.18.143.84
48	141.18.24.95
48	178.219.12.210
48	194.88.183.219
48	72.29.101.11
48	77.3.130.151
48	78.42.6.240
48	93.132.159.168
50	193.175.199.211
50	78.94.161.134
50	94.220.181.137
51	110.74.197.145
51	114.42.114.141
51	119.92.60.115
51	125.214.163.2
51	182.160.120.154
51	182.50.64.67
51	182.50.66.67
51	185.4.253.104
51	186.47.84.139
51	186.5.113.226
51	190.122.186.214
51	190.153.50.70
51	190.167.214.134
51	190.248.94.78
51	190.95.206.202
51	194.19.245.45
51	196.216.74.10
51	196.28.228.253
51	196.45.51.39
51	197.243.40.108
51	201.216.169.214
51	201.240.155.5
51	202.162.208.2
51	202.53.167.163
51	202.79.52.53
51	202.95.192.46
51	203.189.136.17
51	207.232.27.12
51	208.122.242.158
51	212.98.161.106
51	213.131.41.98
51	213.244.81.17
51	31.209.99.187
51	41.188.38.161
51	41.191.204.87
51	41.202.77.195
51	41.208.150.114
51	41.208.68.52
51	41.215.33.66
51	41.222.196.37
51	41.59.17.36
51	41.74.44.35
51	41.78.76.214
51	46.143.233.76
51	58.27.53.51
51	62.162.6.11
51	62.75.251.166
51	66.35.68.145
51	77.48.185.122
51	78.111.55.164
51	78.28.145.2
51	80.136.25.195
51	80.136.25.51
51	80.136.57.91
51	80.136.62.94
51	80.241.44.98
51	80.80.173.84
51	80.90.27.60
51	87.119.221.141
51	88.153.76.75
51	88.153.89.55
51	89.21.60.70
51	91.197.220.230
51	91.214.200.45
51	91.220.124.37
51	93.214.142.229
51	93.214.184.85
51	94.221.124.213
51	97.106.162.120
52	220.233.29.151
53	112.140.184.245
53	114.42.114.141
53	117.239.33.79
53	119.30.39.1
53	119.81.54.58
53	119.92.60.115
53	121.52.146.117
53	122.255.58.121
53	123.30.75.115
53	124.119.50.254
53	133.242.159.39
53	176.123.246.178
53	178.217.9.18
53	178.48.2.237
53	180.149.96.169
53	180.149.96.170
53	180.183.225.147
53	182.50.64.67
53	186.101.114.138
53	186.190.238.65
53	188.191.224.187
53	188.246.75.21
53	188.32.146.199
53	190.121.163.14
53	190.122.186.214
53	190.124.165.194
53	190.150.101.109
53	190.181.27.24
53	190.207.156.165
53	190.36.164.58
53	190.40.54.245
53	190.42.160.241
53	195.19.36.140
53	196.201.20.134
53	196.202.252.21
53	197.136.42.3
53	197.220.195.174
53	197.253.9.10
53	2.133.93.74
53	2.50.7.65
53	200.37.53.116
53	200.46.24.114
53	200.7.33.250
53	200.75.51.149
53	200.88.113.147
53	202.75.156.66
53	203.124.46.250
53	203.176.119.2
53	204.11.50.131
53	206.251.61.236
53	207.232.7.168
53	212.138.92.17
53	212.232.24.57
53	212.249.11.115
53	212.76.9.216
53	213.244.81.17
53	217.116.195.20
53	220.117.150.36
53	221.125.52.178
53	31.44.93.2
53	37.110.87.192
53	37.130.227.133
53	37.57.183.13
53	41.191.204.87
53	41.202.206.53
53	41.208.150.116
53	41.67.6.254
53	41.72.140.140
53	41.79.61.26
53	49.0.1.101
53	5.199.166.250
53	5.226.86.83
53	54.253.23.146
53	58.27.31.113
53	62.201.220.78
53	69.50.64.153
53	72.29.4.111
53	72.64.146.136
53	77.244.254.228
53	77.244.254.229
53	77.244.254.230
53	78.111.55.164
53	78.134.255.42
53	78.157.31.171
53	79.165.21.169
53	80.242.34.242
53	80.92.100.69
53	84.20.82.82
53	86.111.144.194
53	86.120.196.242
53	88.255.147.83
53	91.220.124.37
53	91.228.53.28
53	91.77.144.201
53	95.131.234.2
54	129.65.24.11
54	166.137.186.220
54	206.169.118.236
54	24.23.222.96
54	64.81.53.82
54	66.214.65.152
54	75.128.15.124
54	98.234.240.87
55	4.30.136.90
55	50.132.27.79
55	50.197.81.9
55	71.227.158.204
55	74.125.59.1
56	109.124.192.100
56	109.124.192.36
56	109.124.195.115
56	109.124.199.11
56	109.124.206.205
56	109.124.213.26
56	109.169.129.53
56	109.169.241.207
56	109.224.6.170
56	125.39.66.153
56	178.45.34.138
56	178.45.67.30
56	186.46.160.189
56	190.129.85.211
56	195.222.36.86
56	2.95.203.180
56	200.88.113.147
56	217.196.59.226
56	41.208.68.52
56	41.222.196.37
56	46.0.194.29
56	46.0.212.7
56	46.209.70.74
56	5.164.146.215
56	62.173.43.73
56	78.130.136.18
56	89.236.221.105
56	89.26.71.134
56	91.222.128.24
56	95.128.162.77
56	95.128.163.140
56	95.67.175.253
57	212.107.139.79
57	213.112.236.220
57	31.211.216.84
57	83.254.131.239
59	109.191.36.189
59	109.194.65.175
59	113.28.244.195
59	125.214.163.2
59	133.242.137.148
59	185.12.230.66
59	185.4.253.106
59	186.65.96.30
59	188.165.3.15
59	190.124.165.194
59	194.19.245.45
59	201.216.169.214
59	203.83.6.5
59	207.232.7.168
59	213.131.41.98
59	27.251.216.124
59	31.207.183.168
59	37.113.181.250
59	37.140.13.171
59	37.140.19.151
59	37.140.66.7
59	37.140.69.229
59	41.210.55.157
59	41.211.108.167
59	41.215.33.66
59	5.199.166.250
59	58.143.131.79
59	62.175.140.154
59	62.201.207.14
59	69.50.64.153
59	72.252.114.147
59	77.222.101.104
59	77.222.101.146
59	77.222.103.185
59	78.134.251.152
59	78.29.14.112
59	80.193.214.226
59	80.241.44.98
59	91.199.10.5
59	91.221.195.201
59	95.182.73.98
59	95.38.32.66
61	109.206.133.239
61	178.140.192.166
61	178.237.206.66
61	212.152.53.116
61	212.152.53.238
61	217.172.29.56
61	79.134.78.76
61	80.250.160.33
61	81.200.28.87
61	85.143.112.33
61	85.143.112.35
61	85.143.112.40
61	95.143.216.20
62	188.200.98.3
62	188.200.98.4
62	195.241.20.198
62	213.156.0.168
62	62.140.132.39
62	80.56.147.179
62	81.204.61.9
62	83.128.148.72
62	83.128.166.211
62	83.128.26.22
62	83.86.184.233
63	213.111.120.98
63	217.126.222.55
63	74.125.57.36
63	77.47.132.41
63	77.47.175.101
63	77.47.175.14
63	79.156.117.18
63	81.9.217.45
63	82.144.193.252
63	83.165.193.198
63	83.165.93.190
63	83.77.164.117
63	93.72.123.186
63	93.74.28.37
63	94.244.135.218
63	95.16.171.38
64	109.189.202.153
64	109.203.26.77
64	119.160.176.21
64	128.39.140.61
64	128.39.141.32
64	128.39.142.101
64	128.39.142.103
64	128.39.142.114
64	128.39.142.116
64	128.39.142.119
64	128.39.142.120
64	128.39.142.123
64	128.39.142.125
64	128.39.142.129
64	128.39.142.133
64	128.39.142.140
64	128.39.142.146
64	128.39.142.147
64	128.39.142.149
64	128.39.142.162
64	128.39.142.165
64	128.39.142.179
64	128.39.142.180
64	128.39.142.181
64	128.39.142.183
64	128.39.142.184
64	128.39.142.198
64	128.39.142.210
64	128.39.142.212
64	128.39.142.223
64	128.39.142.34
64	128.39.142.42
64	128.39.142.54
64	128.39.142.58
64	128.39.142.62
64	128.39.142.78
64	128.39.142.81
64	128.39.142.91
64	128.39.142.96
64	128.39.142.98
64	128.39.168.120
64	128.39.168.124
64	128.39.168.175
64	128.39.168.180
64	128.39.168.211
64	128.39.168.51
64	128.39.168.7
64	128.39.169.100
64	128.39.169.118
64	128.39.169.141
64	128.39.169.151
64	128.39.169.163
64	128.39.169.194
64	128.39.42.116
64	128.39.42.134
64	128.39.42.161
64	128.39.42.205
64	128.39.43.101
64	128.39.43.155
64	128.39.43.200
64	128.39.43.230
64	128.39.80.11
64	128.39.80.34
64	128.39.80.74
64	128.39.81.0
64	128.39.81.136
64	128.39.81.171
64	128.39.81.180
64	128.39.81.187
64	128.39.81.229
64	128.39.81.247
64	128.39.81.5
64	128.39.81.65
64	128.39.81.7
64	128.39.81.75
64	128.39.81.77
64	128.39.82.132
64	128.39.82.138
64	128.39.82.58
64	128.39.82.64
64	128.39.83.151
64	128.39.83.168
64	128.39.83.212
64	128.39.83.242
64	128.39.83.89
64	129.241.135.120
64	129.241.223.1
64	134.147.35.32
64	146.185.18.114
64	158.39.244.14
64	180.94.137.147
64	185.3.135.10
64	185.3.135.2
64	186.47.228.232
64	188.93.190.17
64	190.122.186.214
64	195.254.219.2
64	197.214.76.142
64	2.150.22.255
64	217.170.196.119
64	217.170.196.70
64	31.45.85.132
64	31.45.87.87
64	31.45.90.131
64	41.202.77.195
64	41.222.196.37
64	46.15.249.34
64	46.28.51.60
64	46.9.215.5
64	5.63.144.228
64	62.101.255.135
64	62.16.185.128
64	77.106.185.36
64	77.106.188.40
64	77.40.159.35
64	80.203.18.225
64	80.213.235.88
64	82.147.39.131
64	91.149.19.182
64	91.206.34.1
64	94.102.41.55
64	94.242.243.163
64	94.242.243.164
64	94.242.243.176
64	95.34.253.12
65	1.72.6.126
65	1.72.6.171
65	1.72.6.191
65	1.72.6.209
65	103.247.16.2
65	109.175.6.188
65	109.185.116.199
65	109.207.61.14
65	109.224.6.170
65	109.92.21.179
65	110.77.208.40
65	112.140.184.245
65	114.183.84.164
65	115.135.94.221
65	116.112.66.102
65	118.19.38.42
65	118.69.202.111
65	124.248.211.170
65	126.2.243.28
65	126.253.100.185
65	126.253.74.54
65	151.237.220.10
65	168.226.35.19
65	175.196.65.153
65	178.169.169.50
65	178.48.2.237
65	180.148.142.131
65	180.211.143.100
65	180.94.69.69
65	182.249.89.70
65	185.4.253.104
65	186.0.202.150
65	186.120.97.26
65	186.167.32.115
65	186.46.160.189
65	186.64.127.218
65	188.95.32.186
65	190.0.46.66
65	190.122.186.214
65	190.150.101.109
65	190.167.214.134
65	190.181.27.24
65	190.184.221.23
65	190.92.64.210
65	190.99.75.3
65	195.222.36.86
65	196.201.20.134
65	196.202.252.21
65	196.28.228.253
65	196.45.51.39
65	197.160.116.70
65	197.210.252.44
65	197.214.76.142
65	197.220.195.174
65	197.253.6.69
65	199.204.45.90
65	2.188.16.105
65	2.50.7.65
65	200.37.53.116
65	200.7.33.250
65	200.85.39.10
65	200.88.113.147
65	201.149.84.67
65	202.170.83.212
65	202.95.192.46
65	203.124.46.250
65	203.176.119.2
65	203.83.6.5
65	203.97.29.15
65	206.251.61.236
65	207.232.7.168
65	212.138.92.17
65	212.249.11.115
65	213.131.41.98
65	213.135.234.6
65	213.244.81.17
65	218.45.244.195
65	218.45.244.196
65	222.180.173.1
65	222.226.252.114
65	24.92.151.85
65	31.209.99.187
65	41.134.181.250
65	41.188.38.161
65	41.191.204.87
65	41.202.206.53
65	41.202.77.195
65	41.208.150.114
65	41.222.196.37
65	41.225.3.117
65	41.230.30.24
65	41.59.254.18
65	41.67.16.36
65	41.72.105.38
65	41.74.44.35
65	41.78.26.154
65	41.79.65.109
65	5.152.206.177
65	5.199.166.250
65	54.229.138.114
65	66.23.230.230
65	69.50.64.153
65	72.252.114.147
65	77.242.22.254
65	77.48.185.122
65	78.111.55.164
65	78.130.136.18
65	78.134.255.42
65	78.141.119.227
65	78.141.120.184
65	78.28.145.2
65	80.193.214.226
65	80.90.161.130
65	80.90.27.60
65	82.114.95.238
65	82.79.66.19
65	83.235.177.207
65	86.120.196.242
65	88.146.243.118
65	88.255.147.83
65	88.85.108.16
65	89.179.244.102
65	89.236.221.105
65	89.26.71.134
65	89.28.120.190
65	91.220.124.37
65	92.245.172.38
65	94.158.148.166
65	94.46.217.169
65	94.75.214.15
67	109.163.233.195
67	93.187.180.164
67	93.187.182.40
69	199.241.213.184
69	66.177.107.120
70	109.201.135.220
70	109.201.152.239
70	109.201.152.246
70	109.201.154.151
70	178.250.146.82
70	213.75.32.22
70	46.145.20.190
70	77.172.226.47
70	80.113.171.194
70	84.104.88.227
70	84.241.193.93
70	84.84.196.77
70	84.85.174.225
70	88.159.237.196
73	1.209.17.21
73	119.194.217.55
73	14.33.225.154
73	182.218.29.109
73	203.189.136.199
73	211.247.9.51
73	211.45.57.232
73	23.29.121.166
74	1.179.147.2
74	1.234.65.110
74	103.16.79.195
74	103.247.16.2
74	106.3.209.211
74	109.185.116.199
74	109.197.92.60
74	109.207.61.14
74	110.74.210.218
74	110.77.208.40
74	110.77.228.3
74	110.77.241.112
74	112.140.184.245
74	115.124.65.74
74	117.218.37.18
74	118.243.104.106
74	118.69.205.202
74	119.30.39.1
74	122.255.58.121
74	125.214.163.2
74	133.242.156.41
74	153.132.5.29
74	175.136.192.5
74	177.69.195.4
74	178.18.25.85
74	178.77.243.110
74	180.94.69.68
74	185.4.253.104
74	186.190.238.65
74	186.42.225.188
74	186.92.7.165
74	188.95.32.186
74	190.0.9.202
74	190.122.186.214
74	190.124.165.194
74	190.129.85.211
74	190.150.101.109
74	190.52.38.92
74	193.219.168.252
74	193.226.94.95
74	194.19.245.45
74	195.222.36.86
74	196.201.20.134
74	197.160.116.70
74	2.188.16.105
74	200.37.53.116
74	200.46.86.66
74	200.75.3.85
74	200.75.51.151
74	200.85.39.10
74	200.88.113.147
74	202.170.83.212
74	202.43.73.178
74	202.79.52.53
74	203.124.46.250
74	203.176.119.2
74	203.189.136.17
74	203.83.6.5
74	206.251.61.236
74	207.232.7.168
74	207.249.163.155
74	210.148.0.201
74	211.128.34.96
74	212.138.92.17
74	212.144.254.122
74	212.156.79.230
74	212.249.11.115
74	213.181.73.145
74	213.244.81.17
74	217.169.209.2
74	218.213.104.17
74	219.116.166.74
74	220.132.19.136
74	31.209.99.187
74	31.7.144.66
74	37.59.49.163
74	37.59.61.171
74	41.134.181.250
74	41.191.204.87
74	41.202.206.53
74	41.202.77.195
74	41.208.150.114
74	41.215.33.66
74	41.222.196.37
74	41.230.30.24
74	41.59.17.36
74	41.67.16.36
74	41.72.105.38
74	41.78.26.154
74	50.2.64.206
74	62.173.43.73
74	62.201.207.14
74	67.55.2.15
74	69.197.132.80
74	69.50.64.153
74	72.252.114.147
74	78.111.55.164
74	78.134.251.152
74	78.141.119.227
74	80.241.44.98
74	80.90.161.130
74	82.114.95.238
74	82.146.45.230
74	87.229.80.217
74	87.244.179.99
74	88.85.108.16
74	89.26.71.134
74	93.123.45.23
74	93.125.83.79
74	94.198.34.230
74	94.200.108.10
74	94.228.193.6
74	95.154.199.200
74	95.182.73.98
75	113.53.249.29
75	123.24.135.59
75	123.24.149.236
75	123.24.168.5
75	123.24.175.150
75	123.30.180.35
75	123.30.200.117
75	175.139.246.45
75	180.94.69.69
75	182.50.64.67
75	189.85.29.98
75	190.111.122.2
75	193.189.127.134
75	194.141.252.102
75	200.75.3.85
75	201.65.114.212
75	202.149.69.125
75	222.255.237.206
75	41.74.44.35
75	62.253.249.2
75	67.209.224.126
75	72.29.101.11
75	72.29.4.111
75	87.229.26.141
75	88.255.147.83
75	89.77.33.126
75	91.214.200.45
75	93.115.46.10
75	94.137.239.19
76	128.118.51.50
76	130.203.188.50
76	146.186.210.7
76	68.232.125.20
76	71.58.93.100
76	78.111.55.164
77	119.186.160.86
77	171.33.253.15
77	178.169.42.129
77	193.218.138.1
77	193.218.138.8
77	37.112.201.103
77	89.22.164.30
77	89.22.164.96
77	89.22.165.166
77	89.22.165.46
78	111.8.47.6
78	54.238.162.176
80	118.85.208.222
80	217.118.79.34
80	84.237.54.29
80	84.237.54.88
80	84.237.55.107
80	89.31.118.249
81	68.15.185.101
81	68.2.69.137
81	68.225.147.208
81	68.226.24.89
81	71.39.169.14
81	72.201.211.13
81	72.201.99.99
81	72.44.240.228
81	75.167.14.52
82	186.120.97.26
82	197.214.76.142
82	211.5.72.205
82	213.132.241.13
82	219.126.163.5
82	41.222.196.37
83	111.93.196.230
83	115.249.1.61
83	117.231.117.208
83	117.237.160.143
84	110.50.80.30
84	122.255.58.121
84	129.187.173.137
84	129.187.205.120
84	129.187.207.214
84	129.187.51.119
84	129.187.51.167
84	131.159.193.123
84	131.159.196.210
84	131.159.197.139
84	131.159.203.28
84	131.159.203.71
84	131.159.205.216
84	131.159.205.242
84	131.159.205.39
84	131.159.207.225
84	131.159.50.180
84	131.159.50.76
84	138.246.2.74
84	138.246.38.132
84	138.246.41.136
84	138.246.47.193
84	141.84.69.79
84	178.26.243.119
84	188.174.111.77
84	188.174.123.57
84	188.174.30.114
84	188.194.244.70
84	212.7.208.98
84	217.196.59.226
84	46.128.215.242
84	46.244.221.169
84	79.197.65.171
84	79.207.139.140
84	79.207.151.50
84	79.222.112.128
84	79.222.96.38
84	79.222.97.242
84	84.112.192.118
84	87.163.176.193
84	87.163.179.47
84	88.217.180.160
84	88.217.180.184
84	88.217.181.130
84	88.217.181.85
84	88.217.181.87
84	92.230.232.227
84	93.104.72.12
84	93.133.71.119
85	192.249.1.16
85	192.249.1.160
85	192.249.1.21
85	192.249.1.22
85	192.249.1.23
85	192.249.1.29
85	192.249.1.8
85	192.249.1.9
85	198.61.219.27
85	24.96.105.17
85	50.147.102.154
85	67.159.36.21
85	67.187.115.179
85	71.236.61.136
85	75.139.3.3
85	76.123.211.83
86	109.228.19.126
86	142.4.212.102
86	188.138.84.132
86	188.158.18.32
86	188.159.24.168
86	188.159.27.30
86	196.38.88.22
86	202.172.26.27
86	212.34.151.5
86	212.83.153.128
86	213.171.197.182
86	31.31.78.102
86	5.199.171.162
86	74.207.228.155
86	85.17.222.10
86	85.230.124.243
86	88.208.221.87
86	89.221.89.10
86	91.98.251.80
86	94.184.140.2
87	109.52.132.70
87	109.52.170.118
87	151.49.153.145
87	151.49.6.223
87	151.49.82.109
87	151.49.83.0
87	151.95.34.3
87	151.95.35.234
87	157.138.185.115
87	157.138.185.4
87	157.138.185.43
87	157.138.188.207
87	157.138.188.244
87	157.138.191.103
87	157.138.191.14
87	157.138.191.177
87	157.138.20.232
87	180.178.124.122
87	188.125.126.174
87	2.40.117.139
87	217.200.200.251
87	217.200.201.146
87	217.200.201.154
87	5.56.169.85
87	78.134.70.85
87	79.16.156.187
87	79.44.244.191
87	79.54.236.225
87	82.105.116.121
87	82.60.162.248
87	84.220.121.217
87	87.15.34.32
87	87.8.59.4
87	92.25.152.62
87	93.144.111.27
87	93.144.115.251
87	93.147.222.101
87	93.147.72.116
87	94.36.9.248
87	95.241.3.169
88	162.203.112.25
88	192.249.1.139
88	192.249.1.154
88	192.249.1.162
88	192.249.1.168
88	216.96.166.116
88	216.96.179.145
88	216.96.181.165
88	216.96.207.250
88	50.142.231.243
88	76.10.60.66
88	76.10.62.233
89	109.170.8.139
89	31.44.93.2
89	82.198.190.193
90	193.71.65.33
90	84.208.99.161
91	204.14.239.150
91	46.23.68.180
91	50.152.134.219
91	50.58.150.26
91	79.31.230.237
91	85.53.197.140
92	78.94.161.134
93	115.133.245.88
93	141.0.61.166
93	175.100.85.84
93	178.131.185.11
93	180.245.253.30
93	188.168.29.191
93	192.95.32.187
93	196.205.129.5
93	199.201.125.147
93	202.53.172.202
93	203.176.119.2
93	212.83.151.26
93	213.132.241.13
93	221.204.223.38
93	5.116.94.192
93	5.119.65.53
93	5.122.203.66
93	5.124.128.86
93	5.124.64.79
93	5.52.6.191
93	59.21.114.99
93	65.49.2.181
93	87.229.80.217
93	89.26.71.134
93	94.77.199.148
94	109.195.66.224
94	115.127.29.210
94	146.185.31.212
94	173.228.233.126
94	174.126.96.211
94	180.94.69.68
94	184.58.5.116
94	186.190.238.65
94	186.65.96.30
94	190.181.27.24
94	190.248.132.54
94	193.226.94.95
94	196.210.144.51
94	2.133.93.74
94	206.190.158.72
94	207.232.7.168
94	213.131.41.98
94	24.243.32.103
94	41.74.44.35
94	41.79.61.26
94	5.199.166.250
94	65.189.17.73
94	69.50.64.153
94	77.65.19.35
94	78.111.55.164
94	82.114.95.238
94	83.212.125.177
94	88.255.147.83
95	178.154.42.238
95	178.154.65.9
95	185.6.24.11
95	185.6.24.115
95	185.6.24.6
95	188.44.42.219
95	86.57.158.78
95	86.57.187.83
95	93.125.49.170
95	93.84.24.245
95	96.56.145.250
97	108.28.166.44
97	173.79.161.120
97	68.49.56.16
97	96.244.100.209
98	101.161.153.243
98	101.161.25.154
98	103.16.26.234
98	109.163.233.195
98	110.33.211.56
98	111.119.205.194
98	112.140.184.245
98	113.106.200.179
98	113.23.10.221
98	118.100.212.124
98	118.167.15.162
98	128.52.128.105
98	139.192.38.100
98	14.63.38.41
98	153.107.33.153
98	153.107.33.154
98	153.107.33.155
98	153.107.33.156
98	153.107.33.157
98	153.107.33.161
98	153.107.97.164
98	153.107.97.165
98	153.107.97.166
98	153.107.97.168
98	171.25.193.20
98	173.254.216.68
98	173.254.247.16
98	180.149.96.169
98	180.180.122.214
98	186.238.51.149
98	187.185.44.97
98	190.0.17.202
98	190.111.122.2
98	190.122.186.214
98	190.245.157.126
98	195.222.36.86
98	195.228.45.176
98	197.160.56.108
98	200.124.242.99
98	200.35.149.224
98	200.37.53.116
98	202.154.105.248
98	202.247.35.187
98	210.4.73.230
98	212.83.151.26
98	213.165.71.31
98	217.115.113.222
98	217.169.209.2
98	222.124.15.123
98	36.86.185.71
98	41.164.23.162
98	41.191.204.87
98	41.78.26.154
98	49.49.113.92
98	58.168.89.138
98	58.26.194.59
98	62.173.37.203
98	77.109.138.42
98	77.123.76.157
98	80.242.34.242
98	81.7.13.4
98	84.55.126.9
98	85.185.42.3
98	88.150.191.39
98	89.234.142.13
98	91.121.248.221
98	91.220.124.37
98	93.115.82.179
98	94.23.32.209
98	94.244.31.33
98	95.141.37.19
98	95.143.193.16
98	96.44.189.100
98	96.47.226.20
98	96.47.226.21
99	109.188.126.111
99	109.201.66.170
99	109.201.71.96
99	46.20.177.177
99	81.4.242.10
99	83.220.236.210
99	83.220.239.59
99	84.53.241.23
99	84.53.254.172
99	85.142.151.47
99	94.28.21.6
99	95.66.182.167
100	190.42.121.245
100	190.43.37.129
101	107.200.39.99
101	108.219.80.16
101	129.244.135.104
101	129.244.136.254
101	129.244.144.238
101	129.244.144.246
101	129.244.176.86
101	129.244.183.201
101	129.244.184.84
101	129.244.187.243
101	129.244.189.47
101	129.244.217.243
101	129.244.219.160
101	129.244.226.24
101	129.244.226.27
101	129.244.242.49
101	162.243.4.222
101	198.199.120.220
101	70.189.80.11
101	72.222.74.53
103	114.70.4.6
103	114.70.9.204
103	114.70.9.205
103	114.70.9.67
103	221.161.111.118
103	221.161.111.135
103	221.161.111.22
103	221.161.111.25
103	221.161.111.84
104	129.12.218.221
104	129.12.218.7
104	129.12.219.240
104	134.214.146.221
104	141.237.14.195
104	178.199.69.191
104	178.79.135.109
104	188.142.188.193
104	193.42.158.48
104	2.3.115.58
104	212.194.96.51
104	24.34.125.42
104	46.140.72.202
104	75.144.181.206
104	77.57.161.39
104	78.192.27.121
104	80.119.68.149
104	86.195.43.139
104	86.195.43.224
107	195.95.131.65
107	213.205.230.70
107	81.99.252.190
107	86.153.77.179
108	14.139.243.162
108	202.78.173.18
109	220.255.44.236
110	178.79.137.157
110	188.158.101.100
110	188.158.103.112
110	188.158.106.75
110	188.158.114.198
110	188.158.86.207
110	188.158.98.7
110	188.159.134.136
110	188.159.144.9
110	217.219.66.62
110	37.221.161.235
110	87.236.208.139
111	109.79.159.142
111	133.242.137.148
111	180.94.69.68
111	185.4.253.106
111	190.122.177.14
111	190.122.186.214
111	190.129.85.211
111	196.201.20.134
111	197.214.76.142
111	197.218.196.82
111	200.37.53.116
111	200.46.24.114
111	200.85.39.10
111	201.149.84.67
111	203.124.46.250
111	203.97.49.252
111	212.138.92.17
111	212.249.11.115
111	213.244.81.17
111	31.209.99.187
111	41.188.38.161
111	41.191.204.87
111	41.202.77.195
111	41.210.55.157
111	41.222.196.37
111	41.59.254.18
111	41.67.2.2
111	41.72.105.38
111	41.74.44.35
111	41.79.61.26
111	5.199.166.250
111	5.98.86.141
111	72.252.114.147
111	78.111.55.164
111	79.97.104.98
111	79.97.2.201
111	80.241.44.98
111	80.90.27.60
111	89.100.1.53
111	89.100.25.54
111	89.100.45.17
111	89.26.71.134
111	91.123.226.1
111	93.115.46.10
111	94.200.108.10
111	95.83.253.167
111	95.83.253.19
112	193.55.113.196
112	194.154.214.210
112	81.220.107.33
112	81.255.98.253
112	82.236.8.145
113	41.228.40.142
114	193.240.114.29
115	113.161.73.210
115	113.28.54.72
115	131.220.194.170
115	131.220.236.210
115	131.220.236.212
115	131.220.6.142
115	131.220.6.4
115	131.220.6.85
115	131.220.6.86
115	131.220.6.87
115	178.219.12.210
115	190.124.165.194
115	196.202.116.2
115	2.133.93.74
115	200.29.216.146
115	200.88.113.147
115	202.170.83.212
115	202.79.52.53
115	203.176.119.2
115	203.83.6.5
115	37.81.70.18
115	41.222.196.37
115	41.225.3.117
115	78.141.120.184
115	80.136.7.24
115	80.136.9.131
115	87.165.106.13
115	89.0.108.107
115	89.0.154.253
115	89.0.173.157
115	89.0.191.19
115	89.0.64.153
115	91.230.254.2
115	93.232.252.97
116	46.246.37.12
116	46.246.47.25
116	81.230.242.77
116	82.182.181.183
117	1.202.144.149
117	109.109.53.61
117	114.141.162.60
117	115.135.94.34
117	116.226.46.58
117	116.236.216.116
117	119.30.39.1
117	124.119.50.254
117	125.209.73.122
117	125.214.163.2
117	141.76.45.34
117	141.76.45.35
117	175.144.181.82
117	176.123.246.178
117	177.39.101.102
117	178.149.22.103
117	178.48.2.237
117	180.183.225.147
117	180.183.52.33
117	180.254.76.90
117	180.94.69.68
117	181.67.114.5
117	182.50.64.67
117	183.89.104.247
117	183.89.59.7
117	185.4.253.106
117	186.46.160.189
117	188.65.166.253
117	188.95.32.186
117	190.121.163.14
117	190.122.186.214
117	190.150.101.109
117	190.151.10.226
117	190.181.243.84
117	190.181.27.24
117	190.207.156.165
117	192.227.139.227
117	192.30.86.205
117	195.114.128.12
117	196.201.20.134
117	197.214.76.142
117	197.218.196.82
117	197.253.9.10
117	199.19.214.140
117	2.133.93.74
117	200.0.27.62
117	200.46.24.114
117	200.52.182.236
117	200.88.113.147
117	201.248.252.161
117	203.144.201.124
117	203.189.136.17
117	204.93.54.15
117	207.232.7.168
117	210.211.125.25
117	212.126.122.130
117	212.138.92.17
117	212.249.11.115
117	213.135.234.6
117	213.244.81.17
117	217.196.59.226
117	218.57.136.200
117	218.78.210.158
117	219.136.252.120
117	220.132.19.136
117	221.210.40.150
117	37.128.240.152
117	41.191.204.87
117	41.202.206.53
117	41.210.55.157
117	41.215.33.66
117	41.222.196.37
117	41.46.212.205
117	41.59.254.18
117	41.67.2.2
117	41.74.44.35
117	41.75.111.162
117	41.79.61.26
117	41.79.65.109
117	46.21.81.165
117	46.225.33.74
117	46.225.41.130
117	46.225.90.235
117	49.144.118.50
117	5.39.94.48
117	62.162.6.11
117	62.175.140.154
117	62.253.249.2
117	65.49.2.87
117	65.49.2.91
117	65.49.68.214
117	65.49.68.49
117	69.50.64.153
117	72.252.114.147
117	78.141.120.184
117	79.170.189.20
117	80.90.27.60
117	88.146.243.118
117	89.144.170.117
117	89.144.170.118
117	89.190.195.170
117	89.234.195.145
117	91.210.81.156
117	91.220.124.37
117	91.98.19.238
117	91.98.61.96
117	91.98.75.59
117	92.39.54.161
118	1.179.147.2
118	106.187.47.17
118	109.163.233.195
118	109.173.29.229
118	109.74.151.149
118	110.93.23.170
118	113.106.200.182
118	113.28.244.195
118	119.30.39.1
118	119.81.54.58
118	120.72.84.192
118	122.255.58.121
118	125.214.163.2
118	128.117.43.92
118	128.2.142.104
118	128.208.2.233
118	128.52.128.105
118	128.6.224.107
118	141.138.141.208
118	144.76.16.66
118	162.213.1.6
118	162.213.223.139
118	162.218.95.121
118	162.221.184.64
118	162.243.23.22
118	162.243.62.94
118	166.70.207.2
118	171.25.193.131
118	171.25.193.20
118	171.25.193.21
118	171.25.193.235
118	172.245.44.177
118	173.208.196.250
118	173.230.138.96
118	173.242.121.199
118	173.254.216.66
118	173.254.216.67
118	173.254.216.68
118	173.254.216.69
118	173.255.210.205
118	173.255.248.29
118	173.48.45.20
118	174.136.98.202
118	176.31.143.182
118	176.31.184.126
118	176.61.137.221
118	176.9.122.78
118	176.9.140.103
118	176.9.203.132
118	178.17.170.19
118	178.175.131.194
118	178.18.17.111
118	178.18.17.174
118	178.18.83.215
118	178.32.172.126
118	178.32.210.159
118	178.32.252.34
118	178.33.169.35
118	178.33.169.46
118	178.63.169.84
118	178.63.97.34
118	18.187.1.68
118	18.238.1.85
118	180.149.96.169
118	180.149.96.170
118	180.178.124.122
118	182.50.64.67
118	184.105.182.85
118	184.105.220.24
118	184.66.3.178
118	185.2.31.195
118	185.22.64.55
118	185.4.253.106
118	186.42.225.188
118	186.65.96.30
118	187.120.208.211
118	188.186.123.149
118	188.95.32.186
118	189.209.113.88
118	190.0.47.242
118	190.122.186.214
118	190.128.170.18
118	190.129.85.211
118	190.201.105.85
118	190.42.160.241
118	192.227.139.227
118	192.228.104.221
118	192.241.220.137
118	192.241.226.234
118	192.241.230.170
118	192.241.86.124
118	192.252.217.33
118	192.3.116.166
118	192.43.244.42
118	192.81.249.23
118	193.107.85.61
118	193.107.85.62
118	193.110.157.151
118	193.138.216.101
118	194.104.126.126
118	194.132.32.42
118	195.168.11.108
118	195.176.254.140
118	195.180.11.247
118	195.191.16.63
118	195.222.36.86
118	195.228.45.176
118	195.37.190.67
118	195.46.185.37
118	196.201.20.134
118	197.136.42.3
118	197.218.196.82
118	197.220.195.174
118	198.175.125.102
118	198.23.164.6
118	198.245.51.188
118	198.50.177.195
118	198.50.236.217
118	198.50.251.27
118	198.96.155.3
118	199.15.112.86
118	199.19.110.166
118	199.241.186.150
118	199.254.238.44
118	199.48.147.35
118	199.48.147.36
118	199.48.147.37
118	199.48.147.38
118	199.48.147.39
118	199.48.147.40
118	199.48.147.41
118	199.48.147.42
118	2.228.23.58
118	2.50.7.65
118	2.60.230.104
118	200.46.24.114
118	201.149.84.67
118	202.169.239.101
118	202.170.83.212
118	202.29.241.57
118	202.71.101.187
118	202.95.192.46
118	203.124.46.250
118	203.176.119.2
118	203.77.202.138
118	204.11.50.131
118	204.12.235.20
118	204.124.83.130
118	204.124.83.134
118	204.8.156.142
118	205.164.14.235
118	207.232.7.168
118	209.15.212.177
118	209.15.212.49
118	209.17.191.117
118	209.222.8.196
118	209.234.102.238
118	210.65.151.65
118	212.114.47.52
118	212.138.92.17
118	212.186.51.184
118	212.232.24.57
118	212.63.218.1
118	212.63.218.2
118	212.83.151.15
118	212.83.151.18
118	212.83.151.26
118	212.96.58.189
118	213.108.105.253
118	213.138.110.88
118	213.163.72.224
118	213.165.71.31
118	213.180.70.24
118	213.186.7.232
118	213.239.214.175
118	213.245.91.1
118	213.41.130.7
118	213.61.149.100
118	216.119.149.174
118	216.218.134.12
118	217.115.10.131
118	217.115.10.132
118	217.115.10.133
118	217.115.10.134
118	217.13.197.5
118	217.16.182.20
118	217.169.214.144
118	217.219.93.77
118	220.117.150.36
118	23.29.121.166
118	23.88.99.18
118	23.92.30.134
118	27.124.124.122
118	31.172.30.1
118	31.172.30.2
118	31.172.30.3
118	31.172.30.4
118	31.185.27.1
118	31.41.45.235
118	37.0.123.207
118	37.130.227.133
118	37.139.24.230
118	37.153.194.171
118	37.218.245.204
118	37.221.160.203
118	37.221.161.234
118	37.221.161.235
118	37.251.95.134
118	37.58.94.42
118	37.59.162.218
118	37.59.163.222
118	37.59.40.61
118	37.59.7.177
118	37.99.79.13
118	38.70.17.69
118	4.31.64.70
118	41.164.23.162
118	41.178.156.50
118	41.188.38.161
118	41.191.204.87
118	41.208.150.114
118	41.208.68.52
118	41.59.17.36
118	41.67.2.2
118	41.74.44.35
118	41.79.61.26
118	46.160.45.37
118	46.165.221.166
118	46.167.245.50
118	46.249.33.122
118	46.249.58.148
118	46.38.63.7
118	46.4.103.98
118	5.100.249.68
118	5.104.106.97
118	5.135.152.208
118	5.199.130.188
118	5.199.142.195
118	5.254.96.81
118	5.255.80.27
118	5.34.241.111
118	5.35.249.38
118	5.79.81.200
118	50.133.183.237
118	62.162.6.11
118	62.173.43.73
118	62.197.40.155
118	62.212.67.209
118	62.220.135.129
118	62.75.217.22
118	64.113.32.29
118	64.188.47.163
118	64.31.47.117
118	65.183.151.13
118	65.49.60.164
118	66.109.24.204
118	66.146.193.31
118	69.147.252.44
118	69.50.64.153
118	70.184.237.31
118	72.52.91.19
118	72.52.91.30
118	74.200.252.52
118	77.109.138.42
118	77.109.139.26
118	77.109.139.87
118	77.244.254.227
118	77.244.254.228
118	77.244.254.229
118	77.244.254.230
118	77.247.181.163
118	77.247.181.164
118	77.247.181.165
118	77.37.146.56
118	78.108.63.44
118	78.108.63.46
118	78.111.55.164
118	78.130.201.110
118	78.157.31.171
118	78.228.127.130
118	78.245.95.215
118	78.41.200.38
118	78.46.66.112
118	78.63.212.14
118	79.134.234.200
118	79.134.235.5
118	79.172.193.32
118	8.28.87.108
118	80.242.34.242
118	80.255.3.74
118	80.70.5.14
118	81.169.153.101
118	81.193.153.236
118	81.210.220.9
118	81.7.13.4
118	81.80.228.20
118	82.113.63.206
118	82.114.95.238
118	82.135.112.218
118	82.154.134.32
118	82.196.122.129
118	82.196.13.177
118	83.133.106.73
118	83.169.40.140
118	83.177.96.71
118	83.212.125.177
118	84.122.75.253
118	84.25.78.229
118	84.32.116.93
118	85.10.211.53
118	85.135.52.30
118	85.166.189.172
118	85.17.177.73
118	85.17.24.95
118	85.214.52.156
118	85.214.73.63
118	85.25.208.201
118	85.25.46.235
118	85.31.186.106
118	85.68.19.161
118	85.68.20.168
118	85.93.218.204
118	86.192.137.186
118	86.192.208.116
118	87.118.91.140
118	87.236.194.158
118	87.240.95.137
118	87.98.250.222
118	88.150.203.215
118	88.162.51.108
118	88.176.230.45
118	88.190.14.21
118	88.191.158.147
118	88.191.159.232
118	88.191.190.7
118	88.198.120.155
118	88.198.14.171
118	88.217.20.27
118	89.108.86.11
118	89.163.171.250
118	89.187.142.208
118	89.187.142.96
118	89.22.98.56
118	89.221.249.161
118	89.239.213.168
118	89.79.83.166
118	90.34.107.153
118	90.61.49.40
118	91.121.154.129
118	91.121.156.156
118	91.121.232.224
118	91.121.232.225
118	91.121.232.226
118	91.121.248.217
118	91.121.248.220
118	91.121.248.221
118	91.138.20.50
118	91.138.253.244
118	91.194.60.126
118	91.207.183.244
118	91.213.8.235
118	91.213.8.236
118	91.213.8.43
118	91.213.8.84
118	91.219.237.161
118	91.219.237.229
118	91.219.238.107
118	91.233.116.68
118	92.103.215.19
118	93.115.46.10
118	93.115.82.179
118	93.115.87.34
118	93.155.211.93
118	93.167.245.178
118	93.184.66.227
118	93.189.40.230
118	93.72.98.246
118	94.103.175.85
118	94.126.178.1
118	94.242.197.84
118	94.242.204.74
118	94.242.251.112
118	95.128.43.164
118	95.130.10.70
118	95.130.11.247
118	95.130.9.89
118	95.131.252.1
118	95.140.34.188
118	95.159.105.2
118	95.170.88.81
118	95.211.6.197
118	95.211.60.34
118	95.222.204.113
118	95.9.181.5
118	96.39.179.44
118	96.44.189.100
118	96.44.189.101
118	96.44.189.102
118	96.47.226.20
118	96.47.226.21
118	96.47.226.22
118	98.112.235.34
119	103.247.16.2
119	121.52.146.117
119	122.255.58.121
119	122.52.125.100
119	123.200.20.6
119	123.30.75.115
119	134.240.120.41
119	134.240.123.51
119	134.240.124.121
119	134.240.124.18
119	134.240.124.47
119	134.240.13.2
119	134.240.131.48
119	134.240.18.43
119	134.240.202.13
119	134.240.202.34
119	134.240.36.17
119	134.240.39.115
119	134.240.43.1
119	134.240.43.63
119	134.240.52.12
119	134.240.52.23
119	134.240.55.0
119	134.240.56.11
119	134.240.59.13
119	134.240.59.132
119	134.240.59.240
119	134.240.59.38
119	134.240.59.44
119	134.240.63.37
119	134.240.72.59
119	134.240.78.52
119	134.240.93.141
119	176.110.172.82
119	176.31.233.170
119	178.208.255.123
119	180.94.69.69
119	181.112.217.211
119	181.29.30.22
119	185.12.46.151
119	185.4.253.106
119	186.190.238.65
119	188.136.216.129
119	190.0.16.58
119	190.121.163.14
119	190.122.186.214
119	190.128.170.18
119	190.150.101.109
119	190.181.27.24
119	190.42.160.241
119	190.92.64.210
119	194.141.252.102
119	196.201.20.134
119	196.202.252.21
119	196.216.74.10
119	197.160.116.70
119	197.214.76.142
119	197.218.196.82
119	2.133.93.74
119	200.109.228.67
119	200.7.33.250
119	200.88.113.147
119	202.79.52.53
119	202.95.192.46
119	203.122.52.146
119	203.172.218.90
119	203.176.119.2
119	203.189.136.17
119	203.189.136.199
119	207.232.7.168
119	212.138.92.17
119	218.18.210.155
119	223.27.170.85
119	24.105.147.66
119	24.92.151.85
119	31.209.99.187
119	37.252.68.150
119	4.31.18.61
119	41.188.38.161
119	41.191.204.87
119	41.202.77.195
119	41.208.150.114
119	41.208.68.52
119	41.210.55.157
119	41.222.196.37
119	41.230.30.24
119	41.59.254.18
119	41.67.2.2
119	41.72.105.38
119	41.74.44.35
119	41.75.111.162
119	41.79.61.26
119	54.229.138.114
119	62.162.6.11
119	62.173.37.203
119	62.173.43.73
119	62.201.207.14
119	69.29.105.153
119	69.50.64.153
119	72.252.114.147
119	78.111.55.164
119	82.114.95.238
119	83.235.177.207
119	84.20.82.82
119	91.149.150.226
119	91.213.8.235
119	91.214.84.110
119	94.198.34.230
119	94.228.204.10
121	134.58.253.57
121	134.58.39.81
121	134.58.46.129
121	141.135.134.15
121	193.190.253.145
121	193.190.253.147
121	78.20.174.76
121	84.192.99.140
121	87.64.100.49
121	94.224.62.192
122	158.64.122.2
122	158.64.32.241
122	194.154.214.210
122	194.154.216.90
122	212.233.32.49
122	212.233.41.213
122	31.22.122.2
122	83.217.138.26
123	46.59.176.163
123	46.59.214.133
123	62.109.86.71
124	1.172.188.203
124	1.53.211.102
124	111.223.116.242
124	113.106.200.182
124	113.162.167.18
124	113.172.174.77
124	113.173.199.130
124	113.22.215.42
124	113.22.250.52
124	115.74.14.173
124	115.74.144.216
124	115.74.148.86
124	118.69.151.231
124	119.15.81.210
124	120.72.81.15
124	121.6.22.250
124	122.255.58.121
124	123.30.135.76
124	125.209.73.122
124	128.174.236.103
124	14.161.27.108
124	175.196.65.153
124	180.180.122.214
124	180.94.69.68
124	183.80.46.168
124	183.91.31.85
124	185.4.253.104
124	186.115.116.90
124	186.190.238.65
124	186.4.224.12
124	186.65.96.30
124	188.26.115.161
124	188.95.32.186
124	189.125.102.126
124	190.124.165.194
124	190.150.101.109
124	190.42.160.241
124	195.222.36.86
124	196.201.20.134
124	196.46.247.34
124	197.160.56.108
124	197.214.76.142
124	198.50.96.107
124	2.133.93.74
124	2.183.155.2
124	200.109.228.67
124	200.85.39.10
124	200.88.113.147
124	201.149.84.67
124	202.71.101.187
124	203.122.52.146
124	203.162.139.106
124	203.162.139.108
124	203.176.119.2
124	203.189.136.17
124	207.232.7.168
124	212.126.122.130
124	213.131.41.98
124	213.181.73.145
124	213.244.81.17
124	216.10.193.23
124	216.10.193.24
124	217.219.93.77
124	218.185.55.9
124	218.213.104.17
124	220.231.91.130
124	222.254.171.88
124	27.147.148.194
124	27.74.99.114
124	41.215.33.66
124	41.59.254.18
124	41.75.111.162
124	41.79.61.26
124	46.20.0.114
124	49.236.212.23
124	50.148.112.213
124	50.148.125.20
124	62.162.6.11
124	62.253.249.2
124	77.122.84.73
124	77.244.254.228
124	77.65.19.35
124	78.111.55.164
124	78.134.255.42
124	78.141.119.227
124	78.46.250.85
124	80.80.173.78
124	80.90.27.60
124	84.42.3.3
124	87.229.26.141
124	87.98.216.22
124	89.26.71.134
124	91.109.17.199
124	92.245.172.38
124	92.247.48.44
124	95.130.9.89
125	188.189.80.55
125	193.190.154.173
125	213.119.104.158
125	81.11.208.85
126	117.55.68.152
126	119.72.195.52
126	126.164.1.39
126	126.185.21.12
126	126.251.0.144
126	162.210.196.173
126	162.210.196.175
126	186.167.32.115
126	188.95.32.186
126	192.96.203.105
126	195.222.36.86
126	201.163.18.108
126	218.45.244.198
126	222.151.223.114
126	41.72.105.38
126	92.245.172.38
126	95.182.73.98
127	195.208.224.134
127	31.23.151.123
127	31.23.170.251
127	46.61.3.241
127	46.61.78.71
127	46.61.86.17
127	93.178.104.26
127	94.77.190.137
127	95.139.10.213
128	189.212.40.138
128	50.152.41.196
129	128.131.236.104
129	128.131.236.50
129	128.131.236.62
129	128.131.239.252
129	188.23.196.123
129	213.33.9.200
129	84.113.240.5
130	178.131.182.236
130	31.59.57.99
131	109.185.116.199
131	112.140.184.245
131	112.175.251.56
131	113.28.244.195
131	114.141.162.60
131	118.157.45.160
131	120.72.84.192
131	121.52.146.117
131	125.214.163.2
131	134.147.115.112
131	134.147.115.145
131	134.147.115.187
131	134.147.115.236
131	134.147.116.217
131	134.147.116.52
131	134.147.117.243
131	134.147.119.179
131	134.147.119.78
131	134.147.13.123
131	134.147.13.29
131	134.147.13.37
131	134.147.162.251
131	134.147.175.138
131	134.147.175.238
131	134.147.188.54
131	134.147.202.17
131	134.147.203.201
131	134.147.252.130
131	134.147.29.50
131	134.147.31.116
131	134.147.31.20
131	134.147.63.250
131	134.147.69.44
131	134.147.73.145
131	134.147.73.167
131	134.147.73.178
131	134.147.73.78
131	159.255.166.131
131	175.136.192.5
131	176.221.76.46
131	176.9.140.14
131	178.132.216.250
131	180.152.100.217
131	180.211.185.66
131	182.50.66.67
131	186.129.250.136
131	186.151.248.234
131	186.94.164.248
131	187.61.117.11
131	188.26.115.161
131	188.95.32.186
131	189.254.5.82
131	190.0.17.202
131	190.128.170.18
131	190.128.205.2
131	190.181.27.24
131	190.203.253.249
131	190.92.64.210
131	190.99.75.3
131	193.255.143.63
131	194.141.252.102
131	195.222.36.86
131	197.136.42.3
131	197.210.252.44
131	197.214.76.142
131	197.253.9.10
131	2.188.16.83
131	2.206.0.33
131	2.206.1.165
131	2.206.2.117
131	2.206.2.185
131	2.206.3.201
131	2.244.188.216
131	200.37.53.116
131	200.54.78.66
131	200.88.113.147
131	202.43.188.5
131	202.95.192.46
131	203.122.52.146
131	203.172.218.90
131	203.176.119.2
131	203.189.136.199
131	203.83.6.5
131	206.251.61.236
131	207.232.27.12
131	212.12.160.48
131	212.23.140.110
131	212.3.190.77
131	217.187.141.241
131	220.132.19.136
131	31.209.99.187
131	31.22.122.2
131	31.22.122.5
131	31.7.144.66
131	37.24.157.110
131	37.24.59.12
131	41.134.181.250
131	41.191.204.87
131	41.202.206.53
131	41.202.77.195
131	41.208.150.114
131	41.222.196.37
131	41.32.16.82
131	41.59.17.36
131	41.67.2.2
131	41.74.44.35
131	41.78.76.214
131	41.79.61.26
131	46.115.87.24
131	46.20.0.114
131	5.98.86.141
131	72.252.114.147
131	77.182.63.49
131	78.111.55.164
131	78.133.124.58
131	78.134.251.152
131	78.141.119.227
131	78.157.31.171
131	78.50.89.254
131	78.50.91.115
131	79.226.224.206
131	79.226.225.36
131	79.226.255.226
131	80.187.109.9
131	80.252.17.253
131	80.90.27.60
131	82.114.95.238
131	84.119.209.102
131	87.229.80.217
131	88.150.220.203
131	88.153.217.47
131	88.207.220.122
131	88.208.148.249
131	88.208.150.45
131	89.26.71.134
131	91.214.200.45
131	92.112.242.82
131	92.231.24.107
131	92.231.24.61
131	92.231.25.184
131	93.131.255.73
132	109.47.3.10
132	77.20.89.58
133	150.244.199.197
133	150.244.199.233
133	80.26.83.175
133	81.61.14.125
134	178.45.74.175
134	188.168.13.42
134	80.234.58.255
134	81.162.34.110
134	81.162.35.115
134	83.234.54.147
134	85.113.37.68
134	85.113.49.119
134	91.222.128.24
135	128.198.16.221
135	128.198.180.176
135	128.198.213.231
135	128.198.215.100
135	128.198.216.186
135	128.198.220.214
135	128.198.46.17
135	128.198.62.13
135	174.24.40.176
135	67.174.100.122
135	75.173.240.130
135	75.70.225.60
135	75.71.162.183
135	75.71.173.197
135	75.71.54.126
136	159.149.148.11
136	159.149.148.24
136	159.149.148.25
136	159.149.148.33
136	82.84.188.149
136	93.34.153.176
136	93.34.202.150
136	93.36.195.219
136	93.36.203.5
138	109.40.181.193
138	109.90.70.187
138	110.77.208.40
138	119.161.133.188
138	131.234.242.253
138	131.234.64.103
138	178.200.168.36
138	187.120.208.211
138	31.135.196.229
138	37.221.160.203
138	46.246.33.190
138	80.133.126.202
138	88.198.14.171
138	93.196.254.42
138	95.128.43.164
140	197.1.129.60
140	197.1.160.124
140	197.1.197.124
140	197.15.201.62
140	41.226.117.127
140	41.227.183.116
140	41.227.35.178
141	109.74.151.149
141	166.70.207.2
141	171.25.193.131
141	171.25.193.20
141	173.254.216.68
141	173.254.216.69
141	176.31.184.126
141	178.18.17.174
141	178.33.169.46
141	180.149.96.169
141	194.132.32.42
141	198.96.155.3
141	204.8.156.142
141	209.15.212.49
141	209.222.8.196
141	212.83.151.26
141	23.20.163.234
141	31.172.30.4
141	37.130.227.133
141	37.221.161.235
141	5.199.130.188
141	5.45.180.209
141	77.109.139.26
141	77.247.181.165
141	79.134.235.5
141	81.155.185.78
141	86.163.73.109
141	91.219.237.229
141	93.115.82.179
141	93.184.66.227
141	93.189.40.230
141	96.44.189.102
141	96.47.226.20
141	96.47.226.21
142	128.54.1.182
142	137.110.46.182
142	76.88.36.141
143	1.179.147.2
143	110.77.217.224
143	113.28.244.195
143	116.193.170.214
143	117.218.37.18
143	117.59.224.58
143	118.97.130.10
143	120.72.84.192
143	122.255.58.121
143	123.241.22.129
143	137.48.178.202
143	137.48.206.55
143	137.48.228.144
143	137.48.234.43
143	174.71.84.157
143	175.100.85.84
143	178.248.44.18
143	182.50.64.67
143	186.46.187.43
143	190.0.33.18
143	190.124.165.194
143	195.222.36.86
143	198.144.156.141
143	202.170.83.212
143	207.249.163.155
143	217.169.214.144
143	24.252.14.233
143	24.252.21.132
143	41.215.33.66
143	41.225.3.117
143	62.162.6.11
143	62.173.43.73
143	68.99.26.202
143	70.198.0.97
143	72.215.223.131
143	77.242.22.254
143	78.111.55.164
143	78.141.119.227
143	80.90.161.130
143	82.114.95.238
143	84.244.26.209
143	88.146.243.118
143	88.249.230.31
143	91.203.140.46
143	95.159.105.2
143	98.190.179.132
145	217.122.121.173
146	107.197.140.123
146	109.207.61.14
146	121.31.255.15
146	142.129.79.43
146	172.56.30.190
146	173.55.94.117
146	190.248.132.54
146	205.175.98.227
146	207.249.163.155
146	208.185.199.190
146	208.69.158.11
146	217.219.93.77
146	50.9.139.148
146	64.129.230.2
146	71.105.114.179
146	71.118.70.38
146	72.130.54.56
146	72.220.96.201
146	75.142.61.204
146	76.166.29.100
146	76.168.76.179
146	76.168.80.175
146	76.87.104.98
146	78.141.120.184
146	98.154.170.241
147	2.190.7.233
147	78.38.193.254
147	85.133.195.251
147	95.38.203.225
148	216.68.89.43
148	74.83.96.122
150	108.75.1.208
150	109.175.6.188
150	132.170.102.86
150	132.170.104.234
150	132.170.105.218
150	132.170.106.137
150	132.170.106.175
150	132.170.108.145
150	132.170.110.127
150	132.170.111.59
150	132.170.112.105
150	132.170.112.245
150	132.170.115.213
150	132.170.117.195
150	132.170.126.125
150	132.170.126.255
150	132.170.128.125
150	132.170.128.49
150	132.170.129.39
150	132.170.137.199
150	132.170.138.111
150	132.170.145.138
150	132.170.148.223
150	132.170.151.127
150	132.170.151.44
150	132.170.155.57
150	132.170.163.85
150	132.170.164.214
150	132.170.164.252
150	132.170.167.78
150	132.170.169.172
150	132.170.174.50
150	132.170.174.6
150	132.170.175.255
150	132.170.253.255
150	132.170.34.20
150	132.170.46.61
150	132.170.46.64
150	132.170.47.98
150	132.170.74.83
150	132.170.76.164
150	132.170.80.166
150	132.170.80.196
150	132.170.80.241
150	132.170.81.220
150	132.170.83.181
150	132.170.85.143
150	132.170.88.87
150	132.170.89.247
150	132.170.89.54
150	132.170.91.145
150	132.170.94.209
150	132.170.99.22
150	180.94.69.68
150	192.73.237.132
150	205.204.17.87
150	64.134.69.3
150	68.62.252.108
150	70.118.22.166
150	70.15.170.145
150	71.47.155.56
150	71.47.17.215
150	71.47.24.160
150	72.238.114.82
150	75.102.129.131
150	75.102.129.99
150	75.112.131.92
151	71.237.92.15
152	103.11.50.232
152	116.14.90.110
152	121.6.180.225
152	42.60.188.134
153	1.234.65.110
153	103.16.79.195
153	103.26.212.42
153	103.4.175.82
153	103.8.221.253
153	108.179.180.217
153	108.179.184.115
153	108.179.184.166
153	108.179.184.81
153	108.179.185.111
153	108.179.185.17
153	108.179.185.89
153	109.172.63.94
153	109.195.66.224
153	109.197.92.60
153	109.224.6.170
153	110.136.109.39
153	110.138.216.157
153	110.139.58.31
153	110.170.168.45
153	110.172.170.99
153	110.77.136.102
153	110.77.154.126
153	110.77.181.251
153	110.77.228.142
153	110.77.232.150
153	110.77.232.58
153	110.77.236.7
153	111.13.87.150
153	111.241.24.1
153	111.8.88.122
153	112.124.61.166
153	112.78.148.110
153	112.93.248.48
153	113.106.19.28
153	113.106.200.179
153	113.106.200.182
153	113.120.251.197
153	113.20.138.238
153	113.53.249.29
153	113.53.254.124
153	113.98.123.3
153	114.113.125.116
153	114.80.142.20
153	115.124.65.166
153	115.124.65.90
153	115.124.74.97
153	115.135.94.221
153	115.28.39.42
153	115.85.64.122
153	116.112.66.102
153	116.193.170.214
153	116.212.112.247
153	116.226.46.58
153	116.228.55.184
153	116.228.55.217
153	116.236.216.116
153	116.90.230.22
153	117.102.226.166
153	117.141.112.123
153	117.36.231.239
153	117.36.50.52
153	117.41.182.188
153	117.59.224.58
153	117.59.224.60
153	117.59.224.62
153	118.174.137.34
153	118.175.14.131
153	118.186.146.38
153	118.85.208.222
153	118.96.141.122
153	118.96.31.91
153	118.97.107.65
153	118.97.130.10
153	118.97.191.205
153	118.97.194.52
153	118.97.206.254
153	118.97.239.123
153	118.97.31.179
153	118.97.63.228
153	119.10.115.165
153	119.110.75.246
153	119.161.133.188
153	119.161.222.19
153	119.252.160.34
153	119.30.39.1
153	119.97.151.141
153	120.193.17.162
153	120.202.249.199
153	120.72.84.192
153	121.11.167.246
153	121.12.167.197
153	121.134.107.178
153	121.31.255.15
153	121.52.146.117
153	121.8.69.162
153	122.144.130.11
153	122.226.169.246
153	122.255.58.121
153	123.103.23.106
153	123.13.205.185
153	123.200.20.6
153	123.232.118.231
153	123.241.22.129
153	123.63.120.67
153	124.119.50.254
153	124.126.42.11
153	124.129.30.74
153	124.207.82.166
153	124.225.52.14
153	124.248.211.170
153	124.81.127.84
153	124.81.226.210
153	125.162.149.223
153	125.39.66.153
153	125.39.66.163
153	125.39.66.164
153	125.46.65.107
153	125.90.93.8
153	128.208.1.110
153	128.208.1.119
153	128.208.1.126
153	128.208.1.135
153	128.208.1.149
153	128.208.1.154
153	128.208.1.178
153	128.208.1.214
153	128.208.1.232
153	128.208.1.241
153	128.208.1.73
153	128.208.5.164
153	128.208.7.11
153	128.208.7.126
153	128.208.7.128
153	128.208.7.180
153	128.208.7.186
153	128.208.7.2
153	128.208.7.20
153	128.208.7.241
153	128.208.7.89
153	128.95.168.207
153	133.242.206.94
153	14.154.148.188
153	14.18.17.162
153	159.226.169.103
153	163.23.70.129
153	166.137.185.165
153	166.147.82.22
153	172.245.13.164
153	172.56.10.210
153	173.212.242.28
153	173.213.113.111
153	173.213.96.229
153	173.250.140.187
153	173.250.152.214
153	173.250.155.253
153	173.250.158.141
153	173.250.158.142
153	173.250.158.207
153	173.250.159.232
153	173.250.159.48
153	173.250.173.11
153	173.250.173.114
153	173.250.173.232
153	173.250.173.57
153	173.250.173.7
153	173.250.173.71
153	173.250.173.77
153	173.250.177.237
153	173.250.180.119
153	173.250.183.235
153	173.250.187.229
153	173.250.188.198
153	173.250.188.25
153	173.250.188.7
153	173.250.189.144
153	173.250.189.25
153	173.250.189.8
153	173.250.202.135
153	173.250.202.170
153	174.127.231.65
153	175.136.192.5
153	175.139.246.45
153	175.144.181.124
153	175.144.181.82
153	175.196.65.153
153	175.25.243.22
153	176.110.172.82
153	176.194.189.56
153	177.103.202.115
153	177.107.97.245
153	177.12.225.131
153	177.124.60.91
153	177.129.214.44
153	177.159.200.69
153	177.180.118.77
153	177.43.210.162
153	177.73.200.134
153	178.149.22.103
153	178.169.169.50
153	178.18.31.116
153	178.208.255.123
153	178.33.169.46
153	179.190.141.128
153	179.214.195.101
153	180.148.142.131
153	180.152.100.217
153	180.180.121.128
153	180.180.121.171
153	180.180.121.185
153	180.180.121.238
153	180.180.121.251
153	180.180.121.35
153	180.180.122.214
153	180.211.179.42
153	180.241.113.26
153	180.245.235.37
153	180.248.123.53
153	180.250.165.205
153	180.250.215.106
153	180.250.43.85
153	180.250.67.54
153	180.250.82.189
153	181.112.217.211
153	182.18.13.98
153	182.50.64.67
153	182.52.237.158
153	183.1.204.201
153	183.136.146.99
153	183.224.1.55
153	183.234.60.43
153	183.60.109.75
153	183.60.44.136
153	183.62.172.50
153	183.62.38.50
153	183.63.205.18
153	183.63.81.66
153	183.91.79.106
153	183.91.85.130
153	184.170.129.116
153	185.22.64.55
153	186.0.202.150
153	186.101.0.69
153	186.103.143.211
153	186.115.116.90
153	186.167.32.115
153	186.190.238.65
153	186.194.47.46
153	186.209.34.66
153	186.211.6.222
153	186.215.126.175
153	186.215.255.210
153	186.222.69.54
153	186.225.183.150
153	186.238.51.149
153	186.249.7.46
153	186.42.225.188
153	186.46.187.43
153	186.65.96.30
153	186.67.46.229
153	186.93.206.6
153	186.95.122.150
153	187.0.222.167
153	187.120.100.70
153	187.44.1.202
153	187.5.208.242
153	187.51.139.5
153	187.58.129.105
153	187.59.5.208
153	187.60.96.7
153	187.61.117.11
153	187.62.220.57
153	187.84.216.75
153	187.95.0.210
153	187.95.116.173
153	188.26.115.161
153	189.11.215.154
153	189.113.1.158
153	189.114.75.21
153	189.2.90.226
153	189.3.25.146
153	189.39.36.241
153	189.57.6.122
153	189.76.71.202
153	189.80.213.213
153	189.84.209.251
153	189.85.18.3
153	189.85.29.98
153	189.89.170.182
153	189.90.240.126
153	190.0.16.58
153	190.0.60.238
153	190.111.122.2
153	190.124.165.194
153	190.128.170.18
153	190.150.101.109
153	190.151.10.226
153	190.189.93.245
153	190.198.27.80
153	190.201.195.238
153	190.207.192.117
153	190.207.249.112
153	190.207.36.128
153	190.218.246.30
153	190.248.128.238
153	190.36.164.58
153	190.36.95.206
153	190.38.180.36
153	190.39.1.55
153	190.39.151.223
153	190.40.54.245
153	190.7.157.82
153	190.79.53.98
153	190.79.78.188
153	190.82.101.74
153	192.69.200.37
153	193.160.225.13
153	193.189.127.134
153	193.226.94.95
153	194.19.245.45
153	195.222.36.86
153	195.34.100.5
153	196.201.20.134
153	197.136.42.3
153	197.160.116.70
153	197.210.252.44
153	197.220.195.174
153	198.27.97.214
153	198.50.96.107
153	198.74.50.36
153	199.59.107.214
153	2.133.93.74
153	2.181.177.7
153	2.183.155.2
153	200.152.107.242
153	200.153.144.246
153	200.164.73.194
153	200.168.240.2
153	200.192.214.138
153	200.192.215.138
153	200.195.33.3
153	200.196.51.130
153	200.225.198.121
153	200.229.226.33
153	200.229.233.145
153	200.44.126.114
153	200.46.24.114
153	200.46.86.66
153	200.55.206.210
153	200.7.33.250
153	200.85.39.10
153	200.87.139.227
153	200.93.57.223
153	200.98.64.95
153	201.20.190.202
153	201.20.190.204
153	201.211.227.92
153	201.243.41.145
153	201.248.231.63
153	201.44.177.132
153	201.62.48.153
153	201.65.114.212
153	201.75.10.108
153	201.75.25.31
153	201.76.172.110
153	202.101.96.154
153	202.106.16.36
153	202.112.113.250
153	202.112.114.27
153	202.116.1.148
153	202.116.1.149
153	202.116.160.89
153	202.118.236.130
153	202.148.26.218
153	202.149.69.125
153	202.150.129.26
153	202.150.145.142
153	202.150.148.30
153	202.152.196.118
153	202.152.6.10
153	202.159.15.190
153	202.162.208.2
153	202.162.78.181
153	202.194.14.222
153	202.29.241.59
153	202.47.72.203
153	202.51.102.34
153	202.51.110.110
153	202.71.101.187
153	202.79.52.53
153	202.80.122.58
153	202.91.25.41
153	202.99.244.209
153	203.122.52.146
153	203.142.75.35
153	203.144.201.124
153	203.176.119.2
153	203.78.161.82
153	203.83.6.5
153	204.93.54.15
153	205.175.116.23
153	205.175.116.34
153	205.175.98.110
153	205.175.98.120
153	205.175.98.133
153	205.175.98.139
153	205.175.98.167
153	205.175.98.169
153	205.175.98.173
153	205.175.98.177
153	205.175.98.180
153	205.175.98.227
153	205.175.98.71
153	205.175.98.73
153	205.175.98.87
153	206.132.109.84
153	207.232.7.168
153	210.0.205.70
153	210.211.124.250
153	210.45.78.50
153	210.51.23.91
153	210.65.151.65
153	211.142.236.135
153	211.144.76.36
153	212.126.122.130
153	212.156.79.230
153	213.110.195.249
153	213.160.146.140
153	216.218.133.217
153	216.224.174.117
153	217.12.113.67
153	217.148.205.19
153	217.169.209.2
153	217.169.214.144
153	217.219.93.77
153	218.108.85.122
153	218.213.104.17
153	218.24.15.98
153	218.29.154.54
153	218.75.223.51
153	218.92.227.165
153	219.137.229.146
153	219.141.240.130
153	219.143.238.178
153	219.149.45.42
153	219.150.117.116
153	219.154.46.138
153	219.159.105.180
153	219.159.186.7
153	219.159.198.68
153	219.159.198.8
153	219.159.199.6
153	219.72.225.251
153	219.83.100.195
153	220.113.1.73
153	220.132.19.136
153	220.135.105.67
153	220.170.159.185
153	220.181.161.121
153	221.11.67.114
153	221.11.67.115
153	221.123.144.51
153	221.123.144.53
153	221.2.228.202
153	221.2.80.126
153	221.204.223.38
153	221.210.40.150
153	221.210.5.30
153	221.211.190.99
153	221.232.247.27
153	221.7.213.216
153	222.124.12.92
153	222.124.178.98
153	222.168.67.10
153	222.218.152.36
153	222.218.157.23
153	222.65.131.234
153	222.66.117.50
153	222.69.237.212
153	222.74.220.226
153	222.74.224.79
153	222.83.14.143
153	222.88.240.3
153	222.88.242.213
153	222.89.159.131
153	223.202.16.144
153	223.87.0.176
153	24.18.116.133
153	24.18.242.103
153	24.18.246.106
153	24.18.248.161
153	24.18.254.175
153	24.19.1.82
153	24.19.51.55
153	24.22.235.52
153	27.129.196.30
153	27.131.190.66
153	27.147.148.194
153	27.251.61.134
153	36.76.243.97
153	36.77.3.134
153	37.59.49.163
153	41.191.204.87
153	41.222.196.37
153	41.230.30.24
153	41.59.254.18
153	41.72.105.38
153	41.76.170.19
153	41.79.61.26
153	41.79.65.109
153	46.13.10.218
153	46.20.0.114
153	46.248.58.62
153	46.29.78.20
153	46.38.63.7
153	46.50.175.146
153	5.199.166.250
153	50.132.88.237
153	50.135.141.120
153	50.159.67.200
153	50.159.67.96
153	50.170.123.83
153	50.2.64.206
153	50.46.236.80
153	54.214.50.160
153	54.241.33.249
153	58.215.167.132
153	58.242.249.31
153	58.252.56.149
153	58.56.19.66
153	58.62.43.131
153	59.151.37.8
153	59.151.88.241
153	59.72.109.30
153	60.12.218.137
153	60.161.14.77
153	60.190.129.52
153	60.190.93.70
153	60.191.35.42
153	60.220.212.60
153	60.223.255.141
153	61.134.38.42
153	61.134.62.119
153	61.135.255.31
153	61.150.113.146
153	61.153.236.30
153	61.153.98.6
153	61.155.203.69
153	61.156.217.135
153	61.156.235.172
153	61.158.219.226
153	61.160.126.157
153	61.163.163.145
153	61.163.236.158
153	61.164.184.66
153	61.164.46.26
153	61.167.49.188
153	61.178.176.25
153	61.181.131.102
153	61.181.131.34
153	61.19.42.244
153	61.218.178.146
153	61.53.64.37
153	61.54.226.217
153	61.94.133.41
153	62.162.6.11
153	62.173.37.203
153	62.201.220.78
153	62.220.54.115
153	64.34.14.28
153	66.23.230.230
153	66.35.68.145
153	66.35.68.146
153	66.45.227.90
153	66.87.112.70
153	66.87.70.75
153	66.87.71.14
153	67.170.104.191
153	67.170.39.67
153	69.197.132.80
153	69.91.132.173
153	69.91.136.130
153	69.91.136.147
153	69.91.137.116
153	69.91.149.94
153	69.91.153.121
153	69.91.153.141
153	69.91.153.191
153	69.91.153.75
153	69.91.156.113
153	69.91.156.227
153	69.91.156.44
153	69.91.157.100
153	69.91.157.125
153	69.91.157.138
153	69.91.157.153
153	69.91.159.219
153	69.91.165.24
153	69.91.176.158
153	69.91.176.66
153	69.91.176.75
153	69.91.181.94
153	71.197.194.155
153	71.231.107.170
153	71.231.187.162
153	72.252.114.147
153	72.29.101.11
153	72.29.4.111
153	72.64.146.136
153	76.104.199.142
153	76.121.176.241
153	76.28.232.189
153	77.245.207.102
153	77.48.185.122
153	78.111.55.164
153	78.141.119.227
153	78.38.80.131
153	79.135.207.34
153	79.140.98.212
153	79.175.187.2
153	80.240.98.78
153	80.250.23.178
153	82.145.242.105
153	82.146.45.230
153	83.146.70.81
153	84.10.1.42
153	84.244.26.209
153	84.40.111.206
153	85.204.69.231
153	85.96.192.177
153	86.120.196.242
153	87.229.26.141
153	87.244.179.99
153	88.255.147.83
153	89.251.103.130
153	89.26.71.134
153	91.203.140.46
153	91.210.81.156
153	91.214.200.45
153	91.214.62.59
153	91.214.84.110
153	91.225.78.152
153	91.228.53.28
153	91.230.54.60
153	91.241.21.10
153	92.247.48.44
153	94.198.34.230
153	94.200.108.10
153	94.23.32.209
153	94.245.162.126
153	95.154.199.200
153	95.182.73.98
153	95.65.58.61
153	98.237.252.220
154	195.53.255.246
154	87.219.197.181
154	87.223.96.247
154	88.26.228.132
155	109.251.139.157
155	110.164.213.97
155	176.36.166.84
155	178.151.223.232
155	190.110.218.18
155	190.152.245.235
155	195.85.198.51
155	200.7.33.250
155	210.43.128.18
155	65.49.14.158
155	77.123.128.188
155	94.153.230.50
158	146.64.164.122
158	146.64.164.21
158	146.64.8.10
158	146.64.81.112
158	41.135.101.21
158	79.143.191.11
159	109.198.160.154
159	109.198.181.148
159	178.20.177.219
159	193.233.48.78
159	213.87.139.184
159	78.25.121.201
159	94.136.196.117
161	152.62.109.61
161	195.19.226.178
161	195.19.229.33
161	195.19.236.38
161	217.118.78.109
161	217.118.78.114
161	217.118.78.119
161	217.197.0.189
161	217.197.0.29
161	217.197.2.120
161	217.197.2.2
161	217.197.2.59
161	217.197.4.19
161	217.197.4.29
161	46.32.69.171
161	78.25.120.19
161	78.25.121.34
161	84.204.177.202
161	92.100.217.70
161	92.42.28.138
162	108.53.202.49
162	128.238.240.189
162	128.238.243.53
162	128.238.249.70
162	162.243.23.22
162	173.254.216.66
162	199.48.147.39
162	31.172.30.4
162	37.130.227.133
162	65.49.60.164
162	72.52.91.30
162	72.76.190.11
162	91.121.156.156
162	96.242.176.118
162	96.44.189.100
163	95.211.138.225
164	111.108.227.88
164	118.243.196.183
164	118.243.199.100
164	119.245.240.198
164	121.114.52.239
164	122.249.72.249
164	125.214.163.2
164	180.51.31.32
164	182.251.13.172
164	182.251.15.25
164	186.190.238.65
164	188.165.3.15
164	190.110.218.18
164	190.122.186.214
164	196.202.252.21
164	197.218.196.82
164	2.50.7.65
164	200.85.39.10
164	201.195.100.83
164	202.95.192.46
164	203.124.46.250
164	203.176.119.2
164	212.138.92.17
164	218.228.195.11
164	222.11.23.49
164	31.209.99.187
164	41.188.38.161
164	41.202.77.195
164	41.208.68.52
164	41.210.55.157
164	41.222.196.37
164	41.230.30.24
164	41.59.254.18
164	41.67.2.2
164	41.74.44.35
164	41.78.76.214
164	78.38.80.131
164	91.149.150.226
165	109.201.154.177
165	129.107.119.32
165	129.107.131.194
165	129.107.144.152
165	129.107.146.239
165	129.107.147.112
165	129.107.147.69
165	129.107.148.127
165	129.107.148.251
165	129.107.150.211
165	129.107.151.15
165	130.185.155.130
165	162.213.194.42
165	176.227.206.250
165	23.29.115.86
165	23.29.120.254
165	23.29.121.18
165	23.29.121.6
165	46.19.140.62
165	5.63.144.156
165	5.63.151.156
165	66.169.138.162
165	70.244.181.161
165	75.126.39.93
165	93.115.83.16
166	168.126.12.131
166	182.213.252.149
168	194.85.160.55
168	217.66.157.102
168	88.201.205.113
168	95.55.24.9
169	2.94.128.121
170	46.128.42.10
171	109.8.152.162
171	109.8.160.28
171	163.5.111.1
171	163.5.111.100
171	163.5.111.111
171	163.5.111.19
171	163.5.151.14
171	163.5.151.18
171	163.5.151.49
171	163.5.151.60
171	163.5.171.41
171	163.5.171.44
171	163.5.171.48
171	163.5.171.71
171	163.5.171.74
171	163.5.191.107
171	163.5.191.2
171	163.5.191.49
171	163.5.191.51
171	163.5.191.71
171	18.187.1.68
171	193.251.69.162
171	217.128.6.153
171	37.130.227.133
171	37.162.17.233
171	81.66.220.174
171	82.236.175.167
171	82.243.110.159
171	82.246.12.2
172	1.53.29.109
172	1.54.141.244
172	1.54.214.203
172	109.185.116.199
172	113.172.205.190
172	115.73.72.210
172	115.78.0.48
172	115.78.0.50
172	116.108.233.48
172	116.108.233.49
172	116.108.233.53
172	116.108.233.57
172	116.108.233.59
172	118.97.191.203
172	119.15.81.210
172	123.21.91.229
172	175.139.246.45
172	175.196.65.153
172	180.250.42.74
172	180.94.69.68
172	182.160.110.221
172	182.50.64.67
172	182.52.235.83
172	183.80.141.88
172	186.190.238.65
172	188.136.216.141
172	189.57.6.122
172	190.116.12.146
172	190.200.183.175
172	190.248.132.54
172	190.92.64.210
172	193.189.127.134
172	193.25.120.235
172	196.201.20.134
172	197.220.195.174
172	2.133.93.74
172	200.46.24.114
172	201.211.130.52
172	203.162.147.150
172	203.162.147.200
172	203.162.147.201
172	203.162.147.212
172	203.162.147.213
172	203.162.44.41
172	203.162.44.52
172	203.162.44.74
172	203.162.44.94
172	212.156.79.230
172	212.249.11.115
172	217.169.209.2
172	220.132.19.136
172	220.225.131.41
172	222.83.14.144
172	31.209.99.187
172	41.215.33.66
172	41.222.196.37
172	41.59.254.18
172	42.116.152.204
172	62.173.37.203
172	78.28.145.2
172	80.80.173.78
172	86.111.144.194
172	94.154.24.1
173	90.157.117.82
174	188.193.193.92
174	188.193.208.167
174	192.129.26.16
174	192.129.26.32
174	192.129.29.32
176	1.172.188.203
176	109.185.116.199
176	113.106.200.182
176	118.69.168.7
176	122.255.58.121
176	124.248.211.170
176	175.196.65.153
176	178.140.122.75
176	178.169.169.50
176	180.94.69.68
176	181.198.71.172
176	185.22.64.55
176	186.190.238.65
176	186.93.206.6
176	187.95.116.173
176	190.129.85.211
176	190.150.101.109
176	190.92.64.210
176	195.222.36.86
176	195.39.167.45
176	196.201.20.134
176	197.220.195.174
176	197.253.6.69
176	200.37.53.116
176	200.41.181.170
176	201.149.84.67
176	202.71.101.187
176	203.189.136.199
176	203.76.145.147
176	203.78.161.82
176	217.219.93.77
176	41.205.106.49
176	41.59.254.18
176	41.76.170.19
176	41.79.61.26
176	62.162.6.11
176	78.111.55.164
176	78.134.251.152
176	80.242.34.242
176	81.88.222.67
176	83.235.177.207
176	85.143.112.40
176	86.120.196.242
176	87.244.179.99
176	91.230.254.2
176	91.79.177.191
176	92.245.172.38
176	94.154.24.1
177	103.26.194.109
177	103.26.194.114
177	103.26.194.120
177	103.26.194.126
177	103.26.194.136
177	103.26.194.140
177	103.26.194.152
177	103.26.194.2
177	103.26.194.24
177	103.26.194.32
177	103.26.194.4
177	103.26.194.42
177	103.26.194.49
177	103.26.194.71
177	109.175.6.188
177	111.241.24.1
177	112.140.184.245
177	112.93.248.48
177	113.28.244.195
177	115.127.29.210
177	118.69.168.7
177	122.255.58.121
177	125.209.73.122
177	125.214.163.2
177	175.100.85.84
177	175.139.246.45
177	175.196.65.153
177	176.123.246.178
177	178.217.9.18
177	180.180.122.214
177	183.91.79.106
177	185.4.253.106
177	186.42.212.237
177	189.29.201.189
177	190.122.177.14
177	190.122.186.214
177	190.128.205.2
177	190.151.144.42
177	190.167.214.134
177	190.181.27.24
177	190.236.93.98
177	190.38.86.17
177	190.92.64.210
177	194.141.252.102
177	194.19.245.45
177	196.201.20.134
177	196.202.252.21
177	197.210.255.150
177	197.214.76.142
177	197.218.196.82
177	197.220.195.174
177	197.253.6.69
177	199.48.147.38
177	2.188.16.105
177	200.23.26.7
177	200.46.24.114
177	200.7.33.250
177	200.75.3.85
177	200.75.51.149
177	201.195.100.83
177	202.21.106.101
177	202.21.106.104
177	202.21.106.105
177	202.21.106.166
177	202.21.106.169
177	202.95.192.46
177	203.176.119.2
177	203.77.202.138
177	203.78.161.82
177	203.83.6.5
177	206.251.61.236
177	207.232.7.168
177	212.126.122.130
177	212.138.92.17
177	212.249.11.115
177	213.131.41.98
177	213.244.81.17
177	27.123.214.10
177	27.123.214.11
177	27.123.214.12
177	27.123.214.2
177	31.209.99.187
177	41.188.38.161
177	41.191.204.87
177	41.202.206.53
177	41.202.77.195
177	41.208.150.114
177	41.215.33.66
177	41.217.164.18
177	41.222.196.37
177	41.230.30.24
177	41.59.254.18
177	41.67.2.2
177	41.67.6.254
177	41.74.44.35
177	41.79.61.26
177	5.152.206.177
177	5.199.166.250
177	54.216.99.239
177	62.162.6.11
177	69.50.64.153
177	72.252.114.147
177	77.123.76.157
177	77.48.185.122
177	78.111.55.164
177	78.134.251.152
177	78.141.119.227
177	80.241.44.98
177	80.80.173.78
177	80.90.161.130
177	83.212.125.177
177	85.113.39.107
177	85.20.241.114
177	86.58.18.231
177	87.229.26.141
177	87.236.194.158
177	88.249.230.31
177	89.26.71.134
177	89.28.120.190
177	91.220.124.37
177	92.99.233.42
177	94.154.24.1
177	94.46.217.169
177	95.159.105.2
177	96.44.189.100
179	162.242.112.88
179	173.162.48.37
179	192.232.191.254
179	24.176.47.141
179	24.247.177.90
179	35.46.11.228
179	35.46.16.156
179	35.46.16.221
179	35.46.21.43
179	35.46.23.101
179	35.46.25.215
179	35.46.25.227
179	35.46.27.55
179	35.46.37.118
179	35.46.39.216
179	35.46.4.242
179	35.46.40.125
179	35.46.59.34
179	35.46.63.41
179	35.46.9.84
179	64.136.247.226
179	68.40.101.188
179	71.82.82.102
179	91.236.116.114
180	109.163.233.195
180	128.2.100.151
180	128.2.100.155
180	128.2.100.184
180	128.2.116.101
180	128.2.121.106
180	128.237.120.219
180	128.237.126.237
180	128.237.170.49
180	128.237.170.70
180	128.237.173.226
180	128.237.185.50
180	128.237.201.138
180	128.237.202.154
180	128.237.205.20
180	128.237.212.40
180	128.237.226.232
180	128.237.226.67
180	128.237.238.71
180	128.237.241.58
180	128.237.64.57
180	128.237.96.57
180	159.253.145.183
180	173.164.129.221
180	184.95.55.18
180	184.95.55.21
180	184.95.55.22
180	208.90.213.243
180	216.239.45.95
180	216.239.55.198
180	24.131.85.21
180	37.130.224.21
180	50.240.210.46
180	54.205.127.73
180	67.163.245.234
180	67.180.51.7
180	71.178.192.179
180	71.199.96.239
180	71.61.182.107
180	75.151.229.169
180	83.170.97.105
180	96.240.140.46
180	98.188.152.86
180	98.219.175.21
180	99.236.146.9
184	175.139.10.170
184	175.139.4.12
184	175.142.246.152
184	203.121.22.125
184	210.187.243.252
185	213.233.169.228
185	213.233.169.32
185	213.233.169.33
185	213.233.169.34
185	213.233.169.40
185	213.233.169.46
188	110.74.203.243
188	110.77.250.191
188	113.28.244.195
188	118.97.194.52
188	139.0.16.202
188	162.243.62.94
188	175.136.192.5
188	175.196.65.153
188	178.18.31.116
188	178.219.12.210
188	180.94.69.68
188	182.50.64.67
188	185.4.253.106
188	186.101.0.69
188	187.120.208.211
188	190.0.16.58
188	190.151.10.226
188	190.152.245.235
188	192.241.230.170
188	193.226.94.95
188	194.19.245.45
188	195.222.36.86
188	196.202.252.21
188	196.41.40.98
188	199.115.117.194
188	2.133.93.74
188	2.50.7.65
188	200.46.24.114
188	200.55.206.210
188	200.7.33.250
188	200.8.84.74
188	203.119.8.69
188	203.122.52.146
188	203.76.98.194
188	203.83.6.5
188	204.11.50.131
188	206.132.109.80
188	207.232.7.168
188	211.22.11.46
188	217.12.113.67
188	217.219.131.141
188	218.213.104.17
188	23.29.121.166
188	37.130.224.202
188	37.130.229.149
188	41.178.156.50
188	41.191.204.87
188	41.208.68.52
188	41.215.33.66
188	41.222.196.37
188	41.72.105.38
188	46.20.0.114
188	46.236.165.106
188	60.250.62.46
188	62.173.43.73
188	62.201.207.14
188	77.247.181.165
188	78.106.17.177
188	78.111.55.164
188	78.134.255.42
188	78.140.12.206
188	78.40.176.162
188	79.136.241.42
188	82.114.95.238
188	84.10.1.42
188	85.10.211.53
188	85.135.52.30
188	88.204.72.78
188	89.106.14.236
188	89.26.71.134
188	91.121.182.155
188	91.149.150.226
188	91.214.84.110
188	91.221.60.82
188	94.154.24.1
188	96.47.226.21
189	194.197.118.152
189	194.197.118.192
189	194.197.118.238
189	37.221.161.234
189	83.150.82.121
189	85.166.189.172
189	88.114.152.22
189	88.192.137.28
189	88.192.33.151
189	89.27.4.25
191	109.124.26.154
191	116.90.230.22
191	184.154.116.157
191	188.134.44.103
191	189.254.5.82
191	213.135.234.6
191	31.211.9.9
191	41.178.156.50
191	46.236.163.248
191	46.236.186.211
191	78.139.197.169
191	79.136.219.135
191	80.241.44.98
191	83.149.48.17
191	83.172.38.66
191	92.63.71.187
191	95.174.213.100
191	95.174.221.210
191	95.191.29.93
192	158.227.204.199
192	194.179.92.147
192	212.142.248.147
192	31.4.176.124
192	77.209.224.224
192	82.52.92.82
192	83.43.230.253
192	85.60.134.122
192	85.60.135.248
192	87.0.36.66
192	95.16.104.166
197	121.129.25.120
197	121.160.70.58
197	121.169.223.15
197	182.172.3.25
197	211.48.41.131
197	211.48.41.133
197	58.140.167.138
198	83.25.207.158
198	83.25.208.67
199	122.144.6.71
200	62.233.162.154
200	89.64.201.215
200	93.157.76.153
203	162.213.1.6
203	176.31.184.126
203	204.11.50.131
203	213.163.72.224
203	23.88.99.18
203	37.130.227.133
203	5.199.165.171
203	81.34.196.29
204	109.173.2.10
204	109.173.3.45
205	109.75.167.42
205	141.135.55.135
205	198.199.70.240
205	209.132.188.19
205	209.132.188.8
205	212.63.234.30
205	46.105.125.31
205	46.165.221.230
205	61.196.187.131
205	61.197.30.82
205	80.57.153.13
205	90.156.81.2
205	91.121.166.108
205	93.103.159.31
207	193.240.114.29
207	88.164.12.71
210	197.2.110.228
211	114.160.71.147
211	121.116.146.143
211	123.226.32.112
211	130.153.26.5
211	130.153.27.171
211	130.153.8.66
211	182.250.63.78
211	210.138.208.234
211	49.212.193.129
215	119.234.1.4
215	121.6.242.110
215	164.78.142.119
215	164.78.248.66
215	168.226.35.19
215	178.217.9.18
215	180.180.121.192
215	180.94.69.68
215	186.249.7.46
215	190.128.233.78
215	190.181.243.84
215	190.248.132.54
215	196.201.20.134
215	197.210.252.44
215	2.50.7.65
215	200.88.113.147
215	202.170.83.212
215	202.79.52.53
215	203.124.46.250
215	210.0.205.70
215	213.135.234.6
215	217.12.113.67
215	31.209.99.187
215	41.208.150.114
215	41.208.68.52
215	41.225.3.117
215	41.67.6.254
215	5.199.166.250
215	69.50.64.153
215	77.242.22.254
215	78.111.55.164
215	78.141.120.184
215	78.28.145.2
215	80.90.27.60
215	82.207.51.92
219	2.184.101.148
219	217.219.116.208
219	65.49.14.83
219	65.49.14.98
222	206.190.135.216
222	206.190.140.251
222	37.63.237.240
222	79.127.98.2
223	37.255.63.165
223	37.255.79.213
223	37.255.92.247
223	67.215.229.4
224	115.64.45.222
224	122.108.42.87
224	129.94.168.107
224	129.94.168.63
224	129.94.169.177
224	129.94.169.224
224	129.94.169.8
224	129.94.170.152
224	129.94.170.96
224	129.94.242.49
224	139.216.166.202
224	149.171.12.250
224	149.171.229.134
224	220.239.226.48
224	49.181.189.74
224	49.181.67.161
224	49.182.5.244
224	49.2.4.225
224	54.252.29.104
224	58.108.147.15
224	60.240.88.110
224	85.178.3.82
224	85.178.3.96
224	85.178.6.218
225	37.24.42.31
225	93.184.129.101
226	160.39.129.11
226	160.39.150.174
229	108.216.81.178
229	71.11.104.178
230	128.187.97.23
230	161.28.85.35
230	162.211.152.254
230	63.235.131.194
230	96.47.226.20
231	184.242.187.7
231	50.195.66.94
231	69.143.203.221
231	91.219.237.59
231	91.233.249.42
232	110.168.244.167
232	171.6.181.149
232	171.98.93.200
232	203.150.32.26
232	58.8.12.19
232	58.8.155.126
232	58.8.250.61
232	61.19.59.26
233	109.108.78.5
233	109.175.6.188
233	111.119.205.194
233	113.53.232.46
233	119.30.39.1
233	121.52.146.117
233	131.188.30.163
233	131.188.31.130
233	131.188.31.145
233	131.188.31.85
233	131.188.31.97
233	175.139.246.45
233	176.123.246.178
233	178.217.9.18
233	178.26.158.114
233	180.180.121.171
233	180.250.160.58
233	180.94.69.68
233	182.50.64.67
233	185.4.253.104
233	186.5.53.94
233	190.121.163.14
233	190.122.177.14
233	190.122.186.214
233	190.151.10.226
233	190.181.27.24
233	190.248.132.54
233	190.92.64.210
233	192.44.85.23
233	192.44.85.27
233	192.44.85.28
233	194.19.245.45
233	196.201.20.134
233	197.210.252.44
233	197.214.76.142
233	197.218.196.82
233	197.220.195.174
233	2.133.93.74
233	2.50.7.65
233	200.46.24.114
233	200.88.113.147
233	203.176.119.2
233	207.232.7.168
233	212.126.122.130
233	212.138.92.17
233	213.131.41.98
233	213.244.81.17
233	41.191.204.87
233	41.202.206.53
233	41.208.150.116
233	41.222.196.37
233	41.225.3.117
233	41.42.250.193
233	41.67.6.254
233	41.74.44.35
233	41.75.111.162
233	41.76.170.19
233	41.79.61.26
233	62.201.220.78
233	69.50.64.153
233	72.252.114.147
233	77.7.38.220
233	78.111.55.164
233	78.51.129.30
233	80.80.173.78
233	82.115.31.14
233	84.148.29.36
233	84.148.35.254
233	88.217.116.143
233	88.217.121.136
233	88.85.108.16
233	91.220.124.37
233	95.65.58.61
234	15.219.153.75
234	15.219.153.82
234	15.219.153.83
234	172.56.32.55
234	184.76.50.238
234	204.124.83.134
234	208.54.32.143
234	212.83.151.18
234	213.163.72.224
234	31.172.30.1
234	31.172.30.2
234	67.171.252.184
234	67.5.216.112
234	71.193.217.255
234	83.133.106.73
234	85.10.211.53
234	95.130.9.89
234	96.44.189.100
234	96.47.226.22
234	98.246.82.94
235	109.175.6.188
235	109.185.116.199
235	109.224.6.170
235	110.77.200.239
235	115.248.217.178
235	118.97.194.52
235	119.30.39.1
235	120.72.84.192
235	123.63.120.67
235	125.214.163.2
235	151.237.220.10
235	175.139.246.45
235	175.196.65.153
235	176.223.62.75
235	180.211.159.138
235	180.94.69.69
235	182.50.64.67
235	185.4.253.106
235	186.101.0.69
235	186.167.32.115
235	186.42.225.188
235	186.65.96.30
235	186.67.46.229
235	186.93.142.246
235	188.128.123.53
235	188.136.216.141
235	188.95.32.186
235	189.113.1.158
235	190.121.135.178
235	190.248.128.238
235	190.92.64.210
235	193.189.127.134
235	193.226.94.95
235	194.19.245.45
235	196.201.20.134
235	197.210.252.44
235	197.210.255.150
235	197.220.195.174
235	2.133.93.74
235	200.37.53.116
235	200.46.24.114
235	200.7.33.250
235	200.85.39.10
235	201.149.84.67
235	202.170.83.212
235	202.79.52.53
235	202.91.25.41
235	203.124.46.250
235	203.176.119.2
235	203.189.136.199
235	207.232.7.168
235	210.65.151.65
235	212.138.92.17
235	212.156.79.230
235	212.156.86.242
235	212.249.11.115
235	213.244.81.17
235	213.87.139.27
235	217.12.113.67
235	217.169.209.2
235	220.132.19.136
235	222.83.14.143
235	31.209.99.187
235	31.7.144.66
235	41.202.206.53
235	41.208.150.114
235	41.215.33.66
235	41.46.197.79
235	41.59.254.18
235	41.67.2.2
235	41.79.61.26
235	62.162.6.11
235	63.216.146.37
235	72.64.146.136
235	77.242.22.254
235	78.111.55.164
235	78.141.119.227
235	78.141.120.184
235	80.250.23.178
235	84.10.1.42
235	85.141.179.135
235	85.141.206.186
235	86.111.144.194
235	87.229.80.217
235	89.26.71.134
235	93.123.45.23
235	94.23.32.209
236	37.221.169.136
237	163.5.218.116
237	163.5.218.199
237	163.5.218.200
237	163.5.218.201
237	163.5.218.202
237	163.5.218.203
237	163.5.218.209
237	163.5.218.212
237	163.5.218.4
237	163.5.218.82
237	163.5.219.200
237	163.5.219.230
237	163.5.219.64
237	163.5.219.68
237	163.5.220.62
237	163.5.222.191
237	163.5.222.2
237	163.5.222.239
237	163.5.222.61
237	163.5.224.15
237	80.13.252.117
237	80.13.35.166
237	81.65.143.172
237	90.24.145.42
237	91.121.16.104
237	92.151.137.104
238	109.163.233.195
238	128.52.128.105
238	171.25.193.20
238	176.9.57.235
238	193.190.138.250
238	194.104.126.126
238	194.132.32.42
238	198.96.155.3
238	198.98.49.3
238	199.48.147.35
238	204.11.50.131
238	204.12.235.20
238	204.124.83.130
238	204.124.83.134
238	209.15.212.49
238	209.222.8.196
238	212.232.24.57
238	212.83.151.18
238	213.114.125.118
238	213.163.72.224
238	23.29.121.166
238	23.92.30.134
238	31.172.30.3
238	37.130.227.133
238	37.139.24.230
238	37.221.160.203
238	37.221.161.234
238	37.221.161.235
238	37.59.162.218
238	37.59.40.61
238	46.249.33.122
238	66.96.16.32
238	77.109.139.26
238	77.247.181.163
238	77.247.181.165
238	78.108.63.46
238	79.134.234.200
238	79.134.235.5
238	84.193.76.32
238	85.120.207.246
238	87.118.91.140
238	89.123.47.26
238	91.89.123.192
238	92.82.239.100
238	93.115.82.179
238	96.44.189.101
238	96.44.189.102
238	96.47.226.20
238	96.47.226.21
238	96.47.226.22
240	78.239.175.64
241	199.201.127.215
242	112.5.234.241
242	218.106.145.43
242	58.22.113.174
243	94.54.198.171
246	1.179.128.2
246	109.172.63.94
246	116.193.170.214
246	166.147.127.125
246	174.56.222.118
246	180.180.121.35
246	182.50.64.67
246	190.0.47.242
246	190.203.253.90
246	190.248.128.238
246	190.99.75.3
246	200.192.215.138
246	202.148.26.218
246	207.249.163.155
246	207.98.169.18
246	221.204.246.170
246	46.4.253.179
246	62.253.249.2
246	68.47.96.70
246	77.242.22.254
246	80.90.27.60
246	95.38.32.66
246	95.65.58.61
247	37.24.146.132
248	103.247.16.2
248	113.28.244.195
248	114.41.201.63
248	114.80.142.20
248	125.209.73.122
248	175.141.176.68
248	186.133.228.161
248	190.200.28.55
248	190.37.104.251
248	201.149.84.67
248	203.77.202.138
248	210.138.208.11
248	217.219.190.209
248	222.159.71.121
248	41.46.230.69
248	41.46.232.171
248	41.46.253.53
248	49.49.14.20
248	58.143.131.79
248	83.212.125.177
248	94.23.32.209
251	174.136.98.98
251	195.46.241.226
251	195.46.241.227
251	195.46.241.230
251	31.22.122.2
251	31.22.122.5
251	83.254.113.171
252	121.131.125.86
252	121.160.90.87
252	180.182.8.13
252	223.62.175.22
252	223.62.188.82
252	39.7.19.158
252	61.43.248.144
253	206.225.113.112
253	206.225.113.221
253	206.225.126.34
254	81.162.35.115
256	115.249.1.61
257	180.94.69.68
257	185.3.135.34
257	64.237.51.171
257	70.198.197.79
257	70.199.4.199
257	72.77.16.243
257	76.125.198.120
257	8.225.204.2
257	82.114.95.238
257	98.236.4.130
259	173.176.30.209
260	192.249.1.149
260	192.249.1.152
260	192.249.1.154
260	192.249.1.168
260	192.249.1.189
260	216.186.141.234
260	216.96.220.121
260	216.96.223.107
260	216.96.224.29
260	50.142.234.34
260	71.236.57.133
260	76.123.234.221
260	91.220.124.37
261	197.205.126.65
261	41.100.104.94
261	41.100.114.154
261	41.100.93.210
261	41.100.96.96
261	41.103.244.41
261	41.107.241.221
261	41.107.89.58
261	41.200.98.82
261	41.97.115.191
261	41.97.124.21
261	41.97.149.129
261	41.97.211.107
261	41.97.214.253
261	41.97.237.47
261	41.97.77.96
262	109.203.11.202
263	109.163.233.195
263	37.221.161.234
263	69.137.148.167
263	69.250.78.71
263	77.247.181.165
263	78.108.63.44
263	96.47.226.22
264	82.233.118.237
265	109.212.169.97
265	113.53.254.124
265	115.133.239.99
265	120.72.84.192
265	122.52.125.100
265	129.88.241.43
265	129.88.241.66
265	129.88.57.112
265	130.190.28.236
265	130.190.30.228
265	130.190.32.157
265	130.190.32.5
265	130.190.33.160
265	147.171.189.168
265	147.171.189.209
265	147.171.189.78
265	175.136.192.5
265	182.50.64.67
265	186.101.84.218
265	190.110.218.18
265	195.221.228.2
265	195.221.228.9
265	195.222.36.86
265	200.37.53.116
265	200.88.113.147
265	202.53.172.202
265	27.111.38.253
265	31.7.144.66
265	37.160.103.186
265	37.161.41.204
265	37.162.51.140
265	41.210.55.157
265	41.67.2.2
265	46.193.64.69
265	62.173.43.73
265	78.226.232.86
265	80.90.27.60
265	82.122.153.16
265	82.233.119.108
265	82.67.63.139
265	82.67.63.185
265	82.79.66.19
265	83.235.177.207
265	88.150.220.203
265	89.156.204.27
265	90.29.78.103
265	92.129.202.97
265	93.125.83.79
265	95.38.32.66
266	109.190.96.24
266	109.29.103.107
266	158.169.131.14
266	158.169.9.14
266	163.5.141.22
266	163.5.141.79
266	163.5.141.85
266	163.5.201.5
266	194.154.214.210
266	213.245.137.20
266	78.226.197.216
266	78.236.229.52
266	78.237.188.230
266	81.62.45.192
266	81.64.2.60
266	82.227.154.84
266	83.196.243.136
266	83.78.17.196
266	90.15.213.23
266	90.15.89.106
266	92.161.204.28
266	93.24.70.104
267	12.248.108.202
267	173.228.10.99
267	38.122.74.18
267	66.166.58.170
267	98.198.19.223
267	99.6.169.29
268	117.206.4.16
269	173.246.4.250
270	128.54.17.215
270	128.54.17.40
270	128.54.17.67
270	128.54.244.114
270	128.54.246.184
270	128.54.250.232
270	128.54.35.208
270	128.54.40.106
270	128.54.41.199
270	128.54.43.210
270	128.54.44.115
270	128.54.44.18
270	128.54.45.208
270	128.54.45.29
270	128.54.49.227
270	128.54.49.72
270	128.54.51.147
270	128.54.51.155
270	128.54.51.84
270	132.239.10.231
270	132.239.95.57
270	132.239.95.68
270	137.110.222.250
270	137.110.52.229
270	137.110.52.232
270	137.110.54.126
270	137.110.54.241
270	137.110.56.104
270	137.110.61.9
270	137.110.62.26
270	169.228.176.21
270	169.228.183.39
270	68.111.252.119
270	76.88.32.137
270	99.10.120.12
270	99.44.112.154
271	162.195.147.42
271	173.174.191.60
271	24.28.143.90
271	66.69.86.65
271	66.69.95.200
272	1.217.41.36
272	119.195.124.124
272	119.195.124.175
272	119.196.52.99
272	175.121.7.55
272	211.115.127.251
272	37.130.227.133
272	67.159.5.242
272	77.247.181.164
273	101.68.72.106
273	101.84.186.36
273	112.65.138.202
273	114.61.43.170
273	192.110.166.151
273	198.52.103.196
273	202.104.70.254
273	58.37.79.63
273	8.35.201.48
273	8.35.201.49
273	8.35.201.50
273	8.35.201.51
273	8.35.201.52
273	8.35.201.53
273	8.35.201.54
273	8.35.201.55
274	108.51.32.152
275	1.55.137.26
275	110.77.217.224
275	113.190.132.188
275	113.22.59.18
275	117.0.228.49
275	117.6.84.159
275	118.71.98.27
275	123.24.74.175
275	203.113.133.224
275	203.113.133.232
275	220.231.123.134
276	103.11.50.227
276	103.11.50.232
276	121.6.180.225
277	128.42.68.156
277	128.42.87.113
277	128.42.90.66
277	128.62.41.108
277	128.62.45.188
277	138.91.139.190
277	168.7.252.211
278	1.224.156.3
278	112.148.164.118
278	125.252.52.58
278	210.106.3.115
278	211.189.163.250
278	211.232.167.130
278	58.102.135.209
278	61.83.176.14
279	195.162.14.4
279	5.76.211.127
280	106.188.49.8
280	114.145.74.101
280	122.130.157.113
280	36.2.207.163
280	58.158.215.14
281	118.181.176.196
281	61.135.152.207
283	121.50.192.3
284	192.81.215.23
284	24.241.49.83
284	67.190.151.18
284	76.97.211.1
285	106.207.115.66
285	223.187.233.250
285	223.187.239.103
285	27.60.245.153
287	115.75.128.159
289	156.17.190.230
289	178.235.254.84
289	178.83.161.140
289	178.83.24.235
289	178.83.27.186
289	195.187.238.128
289	195.187.238.96
289	31.204.153.99
289	37.190.218.139
289	74.125.57.36
289	77.254.42.99
289	79.186.15.51
289	83.4.158.159
289	83.5.159.125
289	83.8.160.58
289	87.206.97.90
289	87.207.87.154
289	87.246.237.162
289	88.156.85.15
289	89.66.116.229
289	94.192.85.69
289	94.254.144.154
289	94.254.148.25
289	94.254.211.228
290	117.192.65.134
290	117.254.151.254
290	210.212.205.18
291	210.128.212.165
292	77.247.181.165
293	62.160.12.121
294	111.87.58.124
294	111.87.58.218
294	111.87.58.238
294	111.87.58.34
294	49.96.32.175
295	166.111.132.83
295	202.152.6.10
295	223.69.41.140
295	223.69.41.168
295	65.49.68.81
295	65.49.68.93
296	188.115.54.186
296	213.166.50.57
297	1.234.65.110
297	103.247.16.2
297	109.185.116.199
297	109.224.6.170
297	110.74.203.243
297	111.119.205.194
297	112.140.184.245
297	113.28.244.195
297	113.53.232.46
297	113.98.123.3
297	115.133.239.99
297	115.186.153.127
297	115.248.217.178
297	115.84.242.84
297	116.212.112.247
297	118.70.129.101
297	118.97.206.254
297	119.15.81.210
297	119.160.176.102
297	119.160.176.21
297	119.160.176.31
297	119.160.177.234
297	119.160.188.84
297	119.73.60.72
297	120.72.84.192
297	122.52.125.100
297	125.209.73.122
297	125.214.163.2
297	150.140.5.12
297	159.255.166.131
297	163.23.70.129
297	175.136.192.5
297	176.31.233.170
297	176.33.138.156
297	177.129.214.44
297	178.169.169.50
297	178.217.9.18
297	178.254.3.111
297	178.48.2.237
297	178.76.129.69
297	178.77.243.110
297	179.185.66.149
297	179.190.141.128
297	179.214.195.101
297	180.180.121.171
297	180.211.159.138
297	180.250.67.54
297	180.94.69.68
297	180.94.69.69
297	181.114.225.50
297	182.50.64.67
297	186.101.40.138
297	186.101.84.218
297	186.120.97.26
297	186.129.250.136
297	186.42.212.235
297	186.46.187.43
297	186.47.228.238
297	186.47.84.139
297	187.157.32.65
297	187.28.169.85
297	187.28.49.126
297	187.51.175.122
297	187.60.96.7
297	189.84.209.251
297	190.0.17.202
297	190.0.45.98
297	190.0.60.238
297	190.108.43.180
297	190.110.218.18
297	190.121.135.178
297	190.122.186.214
297	190.124.165.194
297	190.128.170.18
297	190.128.205.2
297	190.129.85.211
297	190.151.10.226
297	190.167.214.134
297	190.181.27.24
297	190.216.229.68
297	190.249.133.219
297	190.29.22.247
297	190.41.70.37
297	190.57.73.146
297	190.60.59.74
297	190.82.101.74
297	192.227.139.227
297	192.99.0.172
297	193.251.26.23
297	193.40.239.25
297	194.141.252.102
297	194.186.246.58
297	194.19.245.45
297	194.213.60.222
297	195.222.36.86
297	195.49.20.2
297	196.202.252.21
297	196.216.74.10
297	196.28.228.253
297	197.160.56.108
297	197.210.252.44
297	197.210.255.150
297	197.214.76.142
297	197.220.195.174
297	197.255.213.146
297	199.19.214.140
297	2.133.93.74
297	2.183.155.2
297	2.50.7.65
297	200.0.27.62
297	200.123.130.129
297	200.13.157.186
297	200.206.169.42
297	200.23.26.7
297	200.37.53.116
297	200.5.113.202
297	200.54.78.66
297	200.85.39.10
297	200.88.113.147
297	201.195.100.83
297	201.99.29.243
297	202.141.241.66
297	202.143.185.107
297	202.147.161.6
297	202.152.6.10
297	202.170.83.212
297	202.53.172.202
297	202.62.118.138
297	202.95.192.46
297	203.119.8.69
297	203.172.218.90
297	203.189.136.17
297	203.93.104.10
297	210.0.205.70
297	210.211.124.250
297	210.211.125.25
297	212.138.92.17
297	212.144.254.122
297	212.156.86.242
297	212.198.163.70
297	212.249.11.115
297	212.3.190.77
297	213.135.234.6
297	213.181.73.145
297	217.12.113.67
297	217.169.209.2
297	217.169.214.144
297	217.196.59.226
297	218.91.206.146
297	219.137.229.146
297	220.132.19.136
297	222.122.47.198
297	222.124.15.123
297	222.180.173.1
297	31.209.99.187
297	31.7.144.66
297	37.187.31.39
297	41.130.195.106
297	41.134.181.250
297	41.164.23.162
297	41.191.204.87
297	41.202.77.195
297	41.208.150.116
297	41.208.68.52
297	41.210.55.157
297	41.215.33.66
297	41.215.7.94
297	41.222.196.37
297	41.230.30.24
297	41.32.16.82
297	41.59.17.36
297	41.67.2.2
297	41.72.105.38
297	41.74.44.35
297	41.75.111.162
297	41.78.26.154
297	41.78.76.214
297	41.79.65.109
297	46.13.10.218
297	46.143.233.76
297	46.249.66.50
297	5.39.95.191
297	50.7.67.226
297	58.27.253.213
297	59.90.160.164
297	62.162.6.11
297	62.173.37.203
297	62.201.207.14
297	66.165.98.25
297	69.50.64.153
297	72.252.114.147
297	72.29.4.111
297	77.242.22.254
297	78.130.136.18
297	78.130.201.110
297	78.134.255.43
297	78.192.27.77
297	79.142.55.19
297	80.11.109.196
297	80.120.42.142
297	80.14.218.102
297	80.193.214.226
297	80.241.44.98
297	80.246.2.33
297	80.90.27.60
297	81.113.237.138
297	81.198.148.186
297	82.114.95.238
297	82.223.208.75
297	82.247.113.158
297	84.20.82.82
297	84.40.111.206
297	85.135.52.30
297	85.168.241.52
297	86.111.144.194
297	86.114.160.245
297	87.229.80.217
297	87.236.233.66
297	87.98.216.22
297	88.146.243.118
297	88.150.220.203
297	88.161.108.134
297	88.249.227.98
297	88.255.147.83
297	88.85.108.16
297	89.106.14.236
297	89.190.195.170
297	89.26.71.134
297	91.109.17.199
297	91.200.171.245
297	91.214.200.45
297	91.220.124.37
297	91.228.53.28
297	91.241.21.10
297	91.98.156.148
297	93.125.83.79
297	93.89.107.123
297	94.183.36.43
297	94.200.108.10
297	94.23.32.209
297	95.159.105.2
297	95.211.129.17
297	95.38.32.66
297	95.87.239.115
299	77.20.209.31
299	77.22.11.11
299	93.196.82.240
299	93.218.123.37
299	93.218.82.133
300	163.5.218.164
300	163.5.218.249
300	163.5.219.154
300	163.5.219.9
300	163.5.55.17
300	78.238.105.182
300	81.220.130.120
300	88.184.60.174
300	89.80.220.28
300	92.163.49.164
300	92.243.11.168
300	94.126.119.22
301	122.16.49.159
301	182.249.106.133
301	182.249.116.229
301	210.225.229.252
301	219.117.217.217
301	59.128.172.75
301	60.74.240.66
302	82.154.40.229
304	143.205.128.206
304	80.120.179.134
304	80.121.113.110
304	92.63.211.90
305	1.171.13.27
305	1.234.65.110
305	106.1.242.102
305	109.175.6.188
305	109.185.116.199
305	110.74.207.101
305	112.140.184.245
305	115.124.72.62
305	115.127.29.210
305	115.133.122.234
305	115.188.136.161
305	115.248.217.178
305	116.193.170.214
305	116.90.230.22
305	117.218.37.18
305	119.30.39.1
305	120.72.84.192
305	121.52.146.117
305	123.200.20.6
305	125.214.163.2
305	140.113.125.114
305	140.113.216.144
305	140.113.216.148
305	140.113.216.151
305	140.113.216.154
305	140.113.216.178
305	140.113.216.214
305	151.237.220.10
305	175.136.192.5
305	178.132.216.250
305	178.149.22.103
305	178.18.25.85
305	178.48.2.237
305	180.176.207.41
305	180.180.122.214
305	180.211.159.138
305	181.112.217.211
305	182.50.64.67
305	186.42.225.188
305	188.136.216.129
305	188.26.115.161
305	188.95.32.186
305	189.80.20.162
305	190.0.17.202
305	190.121.135.178
305	190.121.163.14
305	190.122.186.214
305	190.124.165.194
305	190.129.85.211
305	190.150.101.109
305	190.151.10.226
305	190.153.121.136
305	190.201.224.24
305	190.232.225.186
305	190.42.160.241
305	194.141.252.102
305	194.19.245.45
305	195.225.144.38
305	196.201.20.134
305	196.202.252.21
305	196.210.144.51
305	196.45.51.39
305	196.46.247.34
305	197.136.42.3
305	197.160.116.70
305	197.214.76.142
305	197.253.9.10
305	197.255.213.146
305	199.19.110.166
305	2.133.93.74
305	200.23.26.7
305	200.37.53.116
305	200.41.181.170
305	200.46.24.114
305	200.7.33.250
305	200.85.39.10
305	200.88.113.147
305	201.240.155.5
305	202.137.22.183
305	202.170.83.212
305	202.71.101.187
305	203.176.119.2
305	203.83.6.5
305	209.222.8.196
305	212.138.92.17
305	212.249.11.115
305	213.181.73.145
305	213.231.192.213
305	213.244.81.17
305	218.213.104.17
305	219.94.251.115
305	23.92.67.189
305	24.92.151.85
305	31.209.99.187
305	37.221.160.203
305	41.188.38.161
305	41.191.204.87
305	41.208.150.114
305	41.208.68.52
305	41.210.55.157
305	41.215.33.66
305	41.222.196.37
305	41.225.3.117
305	41.230.30.24
305	41.59.17.36
305	41.67.2.2
305	41.72.105.38
305	41.74.44.35
305	41.79.61.26
305	46.4.103.98
305	5.199.166.250
305	5.39.223.19
305	5.9.154.169
305	62.162.6.11
305	62.175.140.154
305	62.201.207.14
305	69.50.64.153
305	72.252.114.147
305	72.52.91.30
305	77.242.22.254
305	78.111.55.164
305	78.130.136.18
305	78.130.201.110
305	78.134.255.42
305	78.141.120.184
305	78.141.79.233
305	78.40.176.162
305	80.193.214.226
305	80.80.173.78
305	80.90.27.60
305	82.114.95.238
305	83.235.177.207
305	85.20.241.114
305	86.120.196.242
305	87.98.216.22
305	89.190.195.170
305	91.214.84.110
305	91.230.54.60
305	92.39.54.161
305	95.159.105.2
305	95.65.58.61
306	109.188.127.184
306	128.69.210.192
306	188.244.40.5
306	212.41.32.106
306	212.41.32.118
306	212.41.41.144
306	46.46.142.163
306	95.25.192.222
307	58.106.66.92
308	83.149.8.173
308	85.143.112.33
308	85.143.112.35
309	1.179.128.3
309	101.110.25.19
309	110.77.228.130
309	110.77.232.150
309	115.23.195.112
309	119.192.179.7
309	123.200.20.6
309	177.101.8.13
309	180.250.130.130
309	182.50.64.67
309	190.189.93.245
309	190.248.128.238
309	200.13.157.186
309	202.221.177.114
309	203.249.2.19
309	203.249.6.92
309	203.249.6.94
309	203.249.6.96
309	203.249.6.99
309	207.232.7.168
309	221.123.144.53
309	41.202.206.53
309	41.67.2.2
309	46.20.0.114
309	58.227.202.69
309	62.173.43.73
309	66.23.230.230
309	78.141.120.184
309	94.24.245.104
309	95.65.58.61
310	31.22.122.2
310	88.207.220.122
314	113.224.148.93
314	115.248.217.178
314	118.97.63.228
314	119.108.189.8
314	119.119.228.107
314	119.180.69.93
314	122.193.143.37
314	124.207.24.205
314	186.24.10.76
314	187.120.208.211
314	190.122.186.214
314	194.141.252.102
314	198.27.97.214
314	200.42.56.146
314	203.189.136.199
314	212.144.254.122
314	37.59.49.163
314	49.76.93.126
314	5.226.86.83
314	91.228.53.28
315	114.141.162.60
315	195.34.100.5
315	196.41.253.4
315	201.62.65.18
315	204.93.54.15
315	31.204.152.197
315	31.204.153.49
315	72.29.4.111
315	77.242.22.254
316	109.207.61.14
316	134.147.13.15
316	134.147.13.212
316	134.147.13.213
316	134.147.13.55
316	134.147.13.70
316	134.147.252.130
316	146.60.164.222
316	177.69.195.4
316	178.201.65.46
316	189.80.213.213
316	189.84.209.251
316	200.195.138.45
316	46.115.104.79
316	77.242.22.254
316	81.217.14.212
316	87.123.200.183
316	87.123.202.187
316	87.123.218.187
316	87.160.107.84
316	89.204.137.171
316	94.154.24.1
316	94.220.178.45
317	219.143.205.68
317	61.135.152.194
317	61.135.152.218
317	8.35.201.48
317	8.35.201.49
317	8.35.201.50
317	8.35.201.51
317	8.35.201.52
317	8.35.201.53
317	8.35.201.54
317	8.35.201.55
318	109.227.215.142
318	217.118.79.37
319	128.69.30.213
319	188.32.50.195
319	193.232.61.26
319	77.51.38.239
319	78.47.101.148
319	88.198.112.29
319	91.244.183.5
319	95.24.204.202
319	95.72.58.231
320	103.247.16.2
320	109.185.116.199
320	109.207.61.14
320	113.28.244.195
320	113.53.232.46
320	115.188.136.161
320	116.71.193.183
320	118.69.168.7
320	119.15.81.210
320	119.160.176.21
320	119.92.60.115
320	124.240.203.66
320	125.214.163.2
320	128.186.121.175
320	128.186.121.4
320	128.186.121.57
320	144.76.63.53
320	149.210.140.130
320	176.123.246.178
320	178.48.2.237
320	179.185.66.146
320	179.185.66.149
320	180.94.69.68
320	182.50.64.67
320	185.4.253.104
320	185.4.253.106
320	186.101.40.138
320	186.47.228.232
320	186.47.84.139
320	186.93.142.74
320	188.95.32.186
320	189.114.75.21
320	190.0.46.66
320	190.122.177.14
320	190.122.186.214
320	190.124.165.194
320	190.128.170.18
320	190.129.85.211
320	190.189.93.245
320	190.218.246.30
320	190.82.89.156
320	192.99.0.172
320	194.141.252.102
320	194.19.245.45
320	195.39.167.45
320	196.201.20.134
320	196.202.252.21
320	196.216.74.10
320	196.41.253.4
320	197.160.56.108
320	197.214.76.142
320	197.218.196.82
320	197.220.195.174
320	197.243.40.108
320	199.19.214.140
320	199.192.171.195
320	2.133.93.74
320	200.37.53.116
320	200.7.33.250
320	200.88.113.147
320	201.116.196.98
320	201.195.100.83
320	202.43.188.5
320	202.53.172.202
320	202.95.192.46
320	203.122.52.146
320	203.189.136.17
320	206.251.61.236
320	210.186.150.33
320	212.138.92.17
320	212.156.86.242
320	212.249.11.115
320	213.131.41.98
320	213.135.234.6
320	213.181.73.145
320	213.244.81.17
320	217.169.214.144
320	217.196.59.226
320	220.132.19.136
320	222.122.47.198
320	24.92.151.85
320	31.209.99.187
320	31.7.144.66
320	41.188.38.161
320	41.191.204.87
320	41.202.77.195
320	41.208.150.116
320	41.208.68.52
320	41.211.108.167
320	41.222.196.37
320	41.230.30.24
320	41.59.254.18
320	41.67.2.2
320	41.74.44.35
320	41.75.111.162
320	41.79.61.26
320	42.61.39.158
320	46.144.137.170
320	5.199.166.250
320	5.29.68.113
320	54.228.210.35
320	62.162.6.11
320	62.173.37.203
320	67.235.140.209
320	69.50.64.153
320	69.80.129.157
320	70.35.154.30
320	70.35.154.50
320	71.229.24.248
320	71.229.6.218
320	72.252.114.147
320	77.123.76.157
320	77.242.22.254
320	78.111.55.164
320	78.134.255.42
320	78.134.255.43
320	78.141.120.184
320	78.28.145.2
320	80.167.238.77
320	80.191.193.2
320	80.90.161.130
320	81.246.77.185
320	83.235.177.207
320	86.111.144.194
320	86.58.18.231
320	88.146.243.118
320	89.236.221.105
320	89.26.71.134
320	91.210.81.156
320	91.220.124.37
320	91.241.21.10
320	94.200.108.10
320	94.228.204.10
320	94.23.32.209
320	94.46.217.169
321	178.32.138.117
321	193.55.114.4
321	46.193.137.216
321	78.199.232.28
322	109.167.210.157
322	188.134.48.237
322	87.118.99.84
324	103.13.242.43
324	103.16.26.145
324	108.171.115.3
324	111.90.150.13
324	115.187.74.82
324	121.125.67.216
324	149.154.153.229
324	178.32.205.50
324	178.86.31.81
324	180.210.203.230
324	181.119.18.29
324	187.157.45.39
324	187.45.182.236
324	188.165.30.35
324	188.165.4.100
324	188.208.33.3
324	190.120.228.89
324	193.105.134.161
324	202.170.122.3
324	205.133.84.129
324	205.133.84.144
324	210.211.108.228
324	213.128.81.67
324	213.229.66.60
324	217.170.202.185
324	27.50.70.227
324	27.50.70.242
324	31.131.253.195
324	37.59.78.228
324	41.77.136.27
324	5.199.171.225
324	68.71.58.169
324	69.47.237.235
324	75.187.60.46
324	81.95.123.208
324	82.103.142.192
324	82.80.245.83
324	91.216.105.26
324	93.93.70.100
324	94.23.150.243
324	94.23.163.49
324	94.23.170.130
324	94.23.75.61
324	94.242.205.219
324	95.110.198.233
324	99.22.5.240
326	108.40.118.136
326	108.93.11.103
326	74.107.114.134
326	96.244.15.115
326	96.244.217.250
331	181.114.225.50
331	186.129.250.136
331	186.88.43.68
331	188.26.115.161
331	188.95.32.186
331	190.128.205.2
331	190.198.27.80
331	190.40.54.245
331	195.175.202.130
331	196.201.20.134
331	197.220.195.174
331	198.228.194.213
331	198.228.206.231
331	202.118.236.130
331	202.43.188.5
331	212.249.11.115
331	24.63.101.213
331	41.59.254.18
331	41.79.65.109
331	62.175.140.154
331	74.79.34.232
331	79.140.98.212
331	82.114.95.238
331	84.10.1.42
331	91.214.84.110
332	195.220.250.130
332	84.101.108.178
332	92.90.17.16
332	93.9.181.77
333	109.221.31.8
333	110.170.168.45
333	113.53.249.29
333	117.102.101.210
333	117.102.121.19
333	119.15.81.210
333	178.169.169.50
333	178.208.255.123
333	182.160.110.221
333	182.50.64.67
333	190.0.9.202
333	193.189.127.134
333	196.201.20.134
333	200.229.233.145
333	200.61.21.75
333	202.79.52.53
333	207.232.7.168
333	210.211.124.250
333	212.126.122.130
333	212.249.11.115
333	213.181.73.145
333	41.222.196.37
333	72.29.4.111
333	72.64.146.136
333	78.28.145.2
333	78.46.250.85
333	82.114.95.238
333	84.10.1.42
333	87.229.26.141
333	88.146.243.118
333	92.148.121.121
333	93.115.46.10
334	193.152.243.60
334	80.174.16.16
334	80.174.16.51
334	80.28.193.240
334	80.28.98.94
334	81.60.150.178
334	84.79.60.226
335	128.229.4.2
335	24.33.131.192
336	108.6.244.199
336	109.163.233.195
336	109.74.151.149
336	128.238.241.45
336	128.238.242.7
336	128.238.243.153
336	128.238.244.14
336	128.238.244.87
336	128.238.246.143
336	128.238.246.95
336	128.238.249.248
336	128.238.250.198
336	128.238.251.13
336	128.238.252.62
336	128.238.254.15
336	128.238.66.6
336	128.238.79.129
336	207.237.184.67
336	207.237.184.68
336	207.237.81.188
336	208.120.32.194
336	209.150.40.135
336	213.61.149.100
336	216.165.95.72
336	24.146.219.255
336	24.193.83.109
336	69.114.183.16
336	91.213.8.235
336	96.232.190.214
336	98.116.13.107
336	98.116.149.177
337	81.243.196.204
338	141.23.99.123
338	2.82.128.62
338	78.130.0.220
338	92.195.13.59
338	94.242.205.235
339	178.254.72.9
340	164.138.31.195
341	179.159.0.224
341	188.165.227.226
341	189.20.19.66
341	72.29.101.11
342	194.151.67.60
342	80.112.236.194
342	82.170.102.219
342	84.104.61.204
342	84.86.66.145
342	89.98.58.63
342	94.209.79.117
343	106.188.42.183
343	106.188.46.230
343	114.182.156.209
343	121.2.20.185
343	125.214.163.2
343	133.51.89.151
343	133.51.89.172
343	133.51.90.5
343	133.51.92.218
343	133.51.94.249
343	133.51.95.196
343	175.139.246.45
343	182.253.34.147
343	185.22.64.55
343	185.4.253.104
343	188.160.3.234
343	197.220.195.174
343	201.149.84.67
343	202.166.121.210
343	203.178.132.107
343	210.65.151.65
343	212.138.92.17
343	217.169.209.2
343	27.251.61.134
343	31.24.142.23
343	41.0.57.69
343	41.129.80.74
343	41.208.68.52
343	41.215.33.66
343	41.222.196.37
343	41.225.3.117
343	41.74.44.35
343	46.164.180.133
343	46.209.70.74
343	5.9.154.169
343	58.69.203.104
343	61.192.183.24
343	78.219.115.8
343	80.242.34.242
343	89.106.14.236
343	91.220.124.37
343	94.200.108.10
343	95.102.8.9
344	112.167.92.225
346	84.31.249.124
347	185.10.182.160
347	213.178.52.178
347	46.0.224.26
347	89.186.225.198
347	94.29.37.157
348	1.179.147.2
348	109.224.6.170
348	111.186.1.106
348	111.186.1.108
348	111.186.1.192
348	111.186.1.249
348	111.186.1.77
348	111.186.1.99
348	117.218.37.18
348	118.69.168.7
348	119.15.81.210
348	123.200.20.66
348	125.214.163.2
348	151.237.220.10
348	175.136.192.5
348	176.31.241.53
348	176.33.138.156
348	178.217.9.18
348	178.48.2.237
348	178.76.129.69
348	180.250.82.188
348	180.94.69.69
348	183.192.182.107
348	183.192.182.46
348	185.12.46.151
348	186.46.187.43
348	187.157.32.65
348	188.191.207.176
348	188.95.32.186
348	190.121.135.178
348	190.122.186.214
348	190.124.165.194
348	190.146.132.205
348	190.167.214.134
348	190.181.27.24
348	190.24.10.122
348	190.40.54.245
348	194.19.245.45
348	195.222.36.86
348	195.39.167.45
348	196.202.252.21
348	197.160.56.108
348	197.210.252.44
348	2.50.7.65
348	200.109.228.67
348	200.42.56.146
348	200.46.86.66
348	200.7.33.250
348	200.75.3.85
348	200.85.39.10
348	202.120.47.68
348	202.121.182.12
348	202.168.236.202
348	202.170.83.212
348	202.53.172.190
348	207.232.7.168
348	210.211.124.250
348	212.138.92.17
348	212.144.254.122
348	212.3.183.209
348	213.131.41.98
348	27.147.148.194
348	31.209.99.187
348	41.134.181.250
348	41.164.23.162
348	41.202.77.195
348	41.210.55.157
348	41.222.196.37
348	41.59.254.18
348	41.74.44.35
348	41.75.111.162
348	41.78.26.154
348	46.249.66.50
348	5.199.166.250
348	58.27.253.213
348	59.78.17.175
348	59.78.26.125
348	59.78.56.136
348	59.78.56.59
348	59.78.56.84
348	59.78.57.206
348	59.78.57.213
348	59.78.58.71
348	60.52.157.178
348	61.164.36.180
348	61.19.42.244
348	69.50.64.153
348	78.111.55.164
348	78.130.201.110
348	78.134.255.43
348	78.157.31.171
348	79.142.55.19
348	8.35.201.50
348	8.35.201.51
348	80.242.34.242
348	80.255.0.206
348	80.90.161.130
348	81.246.77.185
348	82.114.95.238
348	86.120.196.242
348	89.190.195.170
348	91.203.140.46
348	91.220.124.37
348	91.241.21.10
348	92.39.54.161
348	93.125.83.79
348	93.89.107.123
350	50.88.108.100
351	91.109.156.105
351	95.129.173.10
352	113.163.216.94
352	113.190.59.157
352	115.73.151.120
352	183.91.4.68
352	27.2.154.227
353	170.74.56.83
355	192.64.10.84
357	31.22.122.2
357	78.236.233.139
357	88.207.220.125
359	109.205.249.43
359	110.74.210.218
360	101.63.191.184
360	101.63.196.45
360	112.79.41.18
360	115.242.243.215
360	117.209.228.251
360	117.230.237.27
360	117.231.40.159
360	117.236.224.4
360	193.205.210.47
360	216.10.193.20
363	217.124.245.170
363	217.124.245.71
363	77.27.252.55
363	87.223.245.234
363	91.117.42.161
364	174.78.145.156
364	63.118.84.186
364	68.100.110.204
364	71.191.248.94
365	193.55.113.196
365	4.58.28.225
365	68.100.130.86
365	80.11.92.166
366	194.154.214.210
367	128.190.161.199
367	128.190.33.10
367	128.190.33.13
367	128.190.33.14
367	128.190.33.4
367	128.190.33.5
367	128.190.33.6
367	128.190.33.8
367	128.190.33.9
367	71.191.72.116
369	128.229.4.2
369	173.79.42.157
370	120.61.11.95
370	120.61.23.32
370	120.61.39.192
370	120.61.60.179
370	120.61.94.46
370	183.87.83.156
370	50.167.212.17
370	50.241.97.93
370	67.186.1.25
370	98.217.243.77
371	178.131.130.76
371	178.131.98.241
371	213.171.205.131
371	5.119.181.71
371	5.52.252.151
371	65.49.68.50
371	68.71.138.131
371	77.68.40.56
371	80.191.27.10
371	84.241.39.183
371	86.57.47.111
371	88.208.221.254
371	91.133.135.154
371	91.133.199.5
371	95.38.192.216
372	1.179.128.3
372	109.175.6.188
372	109.185.116.199
372	110.77.241.194
372	119.92.60.115
372	125.214.163.2
372	133.242.206.94
372	149.62.53.209
372	149.62.53.210
372	149.62.53.229
372	178.18.31.116
372	178.213.192.37
372	180.148.142.131
372	180.178.124.122
372	185.4.253.104
372	185.4.253.106
372	186.42.225.188
372	186.65.96.30
372	187.120.208.211
372	188.165.85.115
372	188.26.115.161
372	188.95.32.186
372	190.111.122.2
372	190.122.186.214
372	190.124.165.194
372	190.248.132.54
372	190.82.101.74
372	193.189.127.134
372	195.34.100.5
372	196.201.20.134
372	197.162.4.37
372	197.210.255.150
372	197.220.195.174
372	198.74.50.36
372	2.133.93.74
372	2.50.7.65
372	200.23.26.7
372	200.37.53.116
372	200.46.24.114
372	200.85.39.10
372	200.88.113.147
372	202.143.185.107
372	202.170.83.212
372	202.71.101.187
372	202.79.52.53
372	203.124.46.250
372	203.176.119.2
372	203.189.136.17
372	204.93.54.15
372	210.212.55.221
372	212.126.122.130
372	212.138.92.17
372	213.181.73.145
372	217.169.209.2
372	218.213.104.17
372	219.83.100.195
372	220.132.19.136
372	221.120.101.122
372	222.83.14.144
372	27.251.61.134
372	41.188.38.161
372	41.59.17.36
372	41.59.254.18
372	41.67.2.2
372	41.76.170.19
372	41.79.61.26
372	46.13.10.218
372	46.20.0.114
372	46.209.70.74
372	46.29.78.20
372	5.29.68.113
372	5.9.154.169
372	58.229.178.42
372	62.162.6.11
372	62.173.37.203
372	62.201.207.14
372	66.23.230.230
372	77.37.159.245
372	78.111.55.164
372	78.141.119.227
372	78.141.79.233
372	82.114.95.238
372	85.26.241.113
372	87.229.80.217
372	88.85.108.16
372	89.77.33.126
372	95.154.199.100
373	109.173.165.151
373	213.134.140.99
373	217.74.64.220
373	83.144.117.130
373	89.69.109.54
373	89.74.160.104
373	94.42.245.129
374	161.69.7.20
374	98.207.86.75
375	109.185.116.199
375	109.224.6.170
375	109.238.189.252
375	110.74.213.227
375	111.119.205.194
375	118.175.28.3
375	121.52.146.117
375	124.248.211.170
375	175.106.15.12
375	175.139.246.45
375	175.196.65.153
375	178.217.9.18
375	180.211.159.138
375	182.50.64.67
375	186.190.238.65
375	186.4.224.12
375	188.95.32.186
375	190.0.17.202
375	190.122.186.214
375	190.124.165.194
375	190.129.85.211
375	190.38.141.208
375	192.211.17.49
375	192.211.17.83
375	192.211.17.90
375	192.211.18.187
375	192.211.19.103
375	192.211.19.138
375	192.211.20.220
375	192.211.20.81
375	192.211.21.103
375	192.211.21.217
375	192.211.22.87
375	192.211.23.52
375	195.222.36.86
375	197.160.116.70
375	197.255.213.146
375	200.41.181.170
375	201.149.84.67
375	201.240.155.5
375	202.169.236.195
375	203.119.8.69
375	203.176.119.2
375	207.232.7.168
375	41.78.26.154
375	5.199.166.250
375	60.250.62.46
375	67.183.191.205
375	67.183.200.150
375	71.197.202.203
375	71.231.166.72
375	76.28.187.205
375	77.242.22.254
375	80.242.34.242
375	82.79.66.19
375	85.20.241.114
375	91.214.84.110
377	89.73.86.8
378	109.69.220.112
378	194.154.214.210
378	212.99.48.166
378	31.22.122.2
378	31.22.122.5
378	54.225.56.41
378	54.234.53.32
378	62.2.213.50
378	77.199.99.93
378	80.11.55.35
378	83.217.158.17
378	88.161.108.134
378	88.176.192.189
378	88.188.188.124
378	88.191.136.110
378	90.13.151.42
378	91.121.13.44
378	91.183.186.247
379	79.97.206.155
380	70.90.191.238
382	140.32.16.3
382	50.170.132.163
382	50.76.142.206
383	111.175.127.250
383	111.175.88.31
383	50.2.43.37
384	126.19.239.107
385	108.160.81.240
387	84.107.36.113
388	123.192.173.147
388	124.11.190.243
388	140.112.16.129
388	140.112.16.132
388	140.112.16.136
388	140.112.16.140
388	140.112.16.146
388	140.112.16.147
388	140.112.16.150
388	140.112.196.40
388	140.112.25.17
388	140.112.25.2
388	140.112.25.29
388	140.112.25.30
388	140.112.25.35
388	140.112.25.43
388	140.112.25.5
388	140.112.25.52
388	140.112.25.53
388	219.85.196.102
391	42.61.41.114
393	192.249.1.151
393	192.249.1.171
393	216.96.162.92
393	216.96.194.94
393	75.131.33.87
393	76.73.176.139
393	99.110.64.73
394	113.22.8.166
394	113.23.34.243
394	118.70.128.104
394	123.16.194.45
394	123.16.201.168
394	123.24.214.59
394	202.191.57.160
394	222.255.237.206
395	15.211.153.74
395	15.211.153.77
396	1.179.147.2
396	109.175.6.188
396	109.185.116.199
396	110.50.80.30
396	112.140.184.245
396	113.210.3.10
396	113.28.244.195
396	113.28.54.72
396	117.218.37.18
396	118.69.168.7
396	119.30.39.1
396	121.52.146.117
396	122.0.20.146
396	122.255.58.121
396	123.241.22.129
396	176.123.246.178
396	176.223.62.75
396	177.69.195.4
396	178.217.9.18
396	178.219.12.210
396	178.48.2.237
396	180.180.122.214
396	180.224.184.79
396	180.94.69.69
396	185.4.253.106
396	186.103.143.211
396	186.42.212.237
396	186.46.187.43
396	188.165.3.15
396	188.95.32.186
396	190.0.16.58
396	190.122.177.14
396	190.122.186.214
396	190.128.205.2
396	190.129.85.211
396	190.146.132.205
396	190.150.101.109
396	190.181.27.24
396	193.110.108.33
396	194.141.252.102
396	195.114.128.12
396	195.222.36.86
396	196.201.20.134
396	196.216.74.10
396	196.41.253.4
396	197.214.76.142
396	197.218.196.82
396	197.220.195.174
396	2.50.7.65
396	200.109.228.67
396	200.37.53.116
396	200.42.56.146
396	200.46.24.114
396	200.52.182.236
396	200.7.33.250
396	200.85.39.10
396	200.88.113.147
396	201.195.100.83
396	202.79.52.53
396	202.95.192.46
396	203.115.226.245
396	203.176.119.2
396	203.83.6.5
396	203.97.29.15
396	207.232.7.168
396	212.138.92.17
396	212.249.11.115
396	213.131.41.98
396	213.135.234.6
396	213.181.73.145
396	213.244.81.17
396	217.169.209.2
396	217.219.93.77
396	219.94.251.115
396	31.209.99.187
396	41.188.38.161
396	41.191.204.87
396	41.191.28.248
396	41.202.206.53
396	41.202.77.195
396	41.208.150.114
396	41.208.150.116
396	41.208.68.52
396	41.210.55.157
396	41.222.196.37
396	41.225.3.117
396	41.67.2.2
396	41.74.44.35
396	41.75.111.162
396	46.249.66.50
396	5.199.166.250
396	5.53.134.241
396	60.53.21.85
396	61.163.163.145
396	69.197.132.80
396	69.50.64.153
396	72.252.114.147
396	77.48.185.122
396	78.111.55.164
396	78.130.201.110
396	78.134.255.42
396	78.141.119.227
396	78.141.79.233
396	78.28.145.2
396	80.241.44.98
396	80.242.34.242
396	80.80.173.77
396	80.80.173.78
396	80.90.161.130
396	80.90.27.60
396	82.128.124.174
396	84.20.82.82
396	87.229.26.141
396	87.98.216.22
396	88.249.230.31
396	88.85.108.16
396	91.203.140.46
396	91.220.124.37
396	91.228.53.28
396	91.230.54.60
396	91.241.21.10
396	94.154.24.1
396	94.46.217.169
396	95.65.58.61
398	109.163.233.195
398	162.221.184.64
398	194.104.126.126
398	199.48.147.36
398	24.190.67.61
398	85.17.177.73
398	96.44.189.101
398	96.44.189.102
399	129.10.110.48
399	129.10.112.47
399	129.10.9.114
399	129.10.9.29
399	129.10.9.52
399	129.10.9.58
399	155.33.148.202
399	216.15.126.242
399	65.96.126.230
399	68.6.66.131
399	78.129.148.101
402	117.96.16.8
402	14.139.155.210
402	72.52.91.30
403	134.191.220.71
403	134.191.221.74
403	153.19.32.205
403	192.198.151.37
403	192.198.151.44
403	37.209.136.144
403	37.209.136.171
403	37.8.235.161
403	78.30.110.86
403	78.30.88.176
403	78.30.93.46
403	78.30.97.126
403	93.154.227.218
404	220.94.174.35
404	221.142.38.130
404	27.1.154.203
404	61.43.248.144
406	108.61.31.203
406	113.172.92.54
406	115.79.41.163
406	123.30.135.76
409	125.19.212.250
410	70.211.0.63
410	70.211.11.91
410	70.211.13.195
410	70.211.16.77
410	70.211.4.54
410	70.211.6.218
410	70.211.6.33
410	70.211.7.219
410	70.211.9.210
410	76.88.92.203
411	188.27.116.48
412	1.179.147.2
412	1.63.18.22
412	109.175.6.188
412	109.207.61.14
412	110.138.248.78
412	110.77.247.77
412	114.41.201.63
412	119.235.251.115
412	119.30.39.1
412	121.52.146.117
412	123.241.22.129
412	123.30.75.115
412	125.214.163.2
412	128.72.13.47
412	128.72.144.201
412	133.242.206.94
412	159.253.145.150
412	175.139.246.45
412	176.14.74.166
412	178.149.22.103
412	178.169.169.50
412	178.18.25.85
412	178.18.31.116
412	178.219.12.210
412	178.66.227.61
412	178.66.245.254
412	180.183.234.206
412	180.183.52.33
412	180.224.184.79
412	180.94.69.68
412	181.14.202.229
412	182.50.64.67
412	182.52.235.47
412	183.89.131.71
412	185.4.253.106
412	186.120.97.26
412	186.151.248.234
412	186.190.238.65
412	186.42.212.237
412	186.42.225.188
412	186.46.160.189
412	186.65.96.30
412	186.91.199.159
412	186.95.72.97
412	187.120.208.211
412	188.165.3.15
412	188.242.47.80
412	188.26.115.161
412	188.95.32.186
412	190.0.16.58
412	190.0.9.202
412	190.121.163.14
412	190.122.177.14
412	190.124.165.194
412	190.128.170.18
412	190.129.85.211
412	190.150.101.109
412	190.232.225.186
412	190.248.94.78
412	190.42.50.202
412	190.82.101.74
412	190.92.64.210
412	193.165.68.68
412	194.19.245.45
412	196.201.20.134
412	196.202.252.21
412	197.136.41.6
412	197.160.56.108
412	197.218.196.82
412	197.220.195.174
412	197.253.9.10
412	199.201.125.147
412	2.50.7.65
412	200.192.215.138
412	200.23.26.7
412	200.37.53.116
412	200.41.181.170
412	200.46.24.114
412	200.7.33.250
412	200.75.3.85
412	200.88.113.147
412	201.116.196.98
412	202.116.1.148
412	202.170.83.212
412	202.71.101.187
412	202.95.192.46
412	203.119.8.69
412	203.122.52.166
412	203.176.119.2
412	203.189.136.17
412	203.78.161.82
412	203.83.6.5
412	207.232.7.168
412	210.65.151.65
412	212.156.86.242
412	212.249.11.115
412	213.131.41.98
412	213.135.234.6
412	213.244.81.17
412	217.12.113.67
412	217.169.209.2
412	217.169.214.144
412	218.78.210.158
412	27.251.61.134
412	31.209.99.187
412	37.130.229.149
412	41.188.38.161
412	41.191.204.87
412	41.202.77.195
412	41.208.68.52
412	41.210.55.157
412	41.215.33.66
412	41.222.196.37
412	41.225.3.117
412	41.230.30.24
412	41.59.254.18
412	41.67.2.2
412	41.74.44.35
412	41.75.111.162
412	41.76.170.19
412	41.78.26.154
412	41.79.61.26
412	42.61.39.158
412	46.143.233.76
412	5.135.80.83
412	5.135.80.89
412	5.199.166.250
412	5.9.154.169
412	50.57.97.192
412	58.143.131.79
412	61.19.42.244
412	61.218.178.146
412	62.162.6.11
412	62.201.207.14
412	62.201.220.78
412	67.213.218.72
412	67.213.218.74
412	69.50.64.153
412	72.252.114.147
412	72.29.4.111
412	78.111.55.164
412	78.141.119.227
412	80.241.44.98
412	80.242.34.242
412	80.80.173.78
412	81.113.237.138
412	82.137.247.134
412	83.212.125.177
412	84.10.1.42
412	84.120.105.202
412	85.20.241.114
412	85.214.100.87
412	85.96.192.177
412	86.111.144.194
412	87.229.26.141
412	88.146.243.118
412	88.150.229.251
412	88.201.139.207
412	88.85.108.16
412	89.112.54.177
412	89.26.71.134
412	91.210.81.156
412	91.220.124.37
412	93.125.83.79
412	94.158.148.166
412	94.19.31.245
412	94.23.32.209
412	94.25.229.33
412	94.46.217.169
412	95.154.199.100
412	95.55.158.56
412	95.65.58.61
413	67.187.110.207
414	194.154.214.210
414	31.22.122.2
414	80.79.116.54
414	88.207.220.122
414	91.183.186.247
415	109.192.39.171
415	141.70.81.145
415	145.228.33.78
415	188.109.209.76
415	196.41.253.4
415	31.204.152.197
415	69.50.64.153
415	72.64.146.136
415	77.242.22.254
415	79.250.185.107
415	85.177.225.54
415	85.177.54.104
415	88.208.145.245
415	88.78.17.44
415	88.78.26.113
416	213.124.219.8
416	24.132.155.168
416	83.81.85.41
417	175.139.10.170
418	194.154.214.210
418	212.233.48.99
418	31.22.122.2
419	78.223.36.203
419	82.237.14.81
419	82.247.9.90
419	84.103.69.117
420	144.85.169.0
420	144.85.178.157
420	194.154.214.210
420	194.209.70.218
420	31.22.122.2
420	83.228.142.31
420	85.218.3.184
421	5.12.174.227
421	5.12.178.18
421	83.166.215.96
421	86.34.37.98
423	128.39.142.120
423	128.39.143.81
423	128.39.42.68
423	128.39.44.217
423	129.177.138.114
423	62.16.139.102
423	91.149.19.182
425	122.106.150.15
425	125.214.163.2
425	181.112.217.211
425	194.19.245.45
425	199.175.51.105
425	201.209.205.251
425	202.162.208.2
425	202.45.119.11
425	202.45.119.21
425	202.45.119.27
425	211.30.155.250
425	220.233.38.77
425	220.233.42.19
425	42.121.0.81
427	134.54.0.27
427	134.54.14.180
427	62.235.198.197
427	83.134.184.41
428	117.4.6.99
430	193.48.225.142
430	193.54.24.130
433	31.22.122.2
434	14.201.66.248
434	203.126.136.142
434	203.126.136.143
436	1.53.74.63
436	113.162.155.118
436	115.72.236.218
436	115.72.237.174
436	115.72.244.114
436	115.79.41.163
436	118.68.11.35
436	123.20.237.146
436	123.21.193.39
436	183.80.109.80
436	42.116.6.44
437	194.154.214.210
437	31.22.122.2
437	85.93.195.227
439	1.55.43.238
439	113.185.3.116
439	113.23.126.139
439	118.71.221.61
439	128.208.2.233
439	173.254.216.67
439	213.163.72.224
439	213.61.149.100
439	220.231.105.166
439	220.231.107.226
439	37.130.227.133
439	58.187.115.237
439	77.247.181.164
439	88.191.190.7
441	58.187.125.253
442	176.9.41.8
442	188.165.43.222
442	194.154.216.91
442	194.154.216.94
442	31.22.122.2
442	80.90.42.58
443	123.227.80.51
443	218.228.195.11
444	193.51.36.204
444	82.240.52.167
444	90.62.1.158
445	118.70.124.143
447	122.101.132.118
447	122.101.132.185
447	122.101.132.209
447	122.101.132.65
450	117.6.84.159
450	203.113.133.224
455	109.163.233.195
455	117.0.186.14
455	166.70.207.2
455	176.9.140.103
455	204.124.83.130
455	212.83.151.15
455	213.108.105.253
455	23.29.121.166
455	23.88.99.18
455	31.172.30.2
455	37.221.161.235
455	58.187.219.43
455	77.247.181.163
455	78.108.63.44
455	82.202.70.16
455	89.187.142.208
455	91.121.248.220
455	93.115.82.179
457	103.245.47.20
458	84.237.54.23
459	130.233.228.12
459	193.55.113.196
459	86.203.48.55
459	86.203.64.211
463	123.24.48.94
464	123.30.135.76
465	195.20.130.1
465	195.64.149.48
465	213.109.80.138
465	77.123.128.188
465	89.209.13.92
465	91.202.130.245
465	91.209.51.190
465	91.234.37.55
465	94.153.230.50
465	94.154.213.170
465	94.45.37.149
465	95.67.82.10
467	42.116.6.44
468	109.46.68.122
468	109.84.122.174
468	134.96.199.181
468	134.96.199.227
468	158.64.77.102
468	190.82.101.74
468	194.154.214.210
468	202.92.204.174
468	212.255.232.96
468	212.255.252.165
468	31.22.122.2
468	83.222.63.186
468	85.94.247.148
468	95.38.32.66
471	113.161.84.110
473	210.195.154.180
474	183.81.52.84
476	115.78.208.198
476	115.78.227.220
476	115.79.41.163
476	123.30.135.76
476	42.119.5.220
479	80.11.55.35
479	81.56.136.200
479	89.95.79.20
480	109.173.114.118
480	195.191.88.99
480	37.221.161.234
481	1.73.241.192
481	153.132.87.18
481	27.228.227.205
483	153.187.174.116
485	37.160.152.99
485	37.162.178.236
485	82.66.232.193
485	82.79.66.19
485	83.114.221.119
486	85.143.112.33
489	117.6.135.85
489	118.70.128.104
489	123.16.194.45
489	159.253.145.150
489	42.113.237.50
490	115.78.65.249
494	195.46.229.98
495	117.6.135.85
495	118.70.128.104
498	109.163.233.195
498	194.154.214.210
498	198.96.155.3
498	213.61.149.100
498	23.88.99.18
498	31.172.30.3
498	31.22.122.2
498	37.130.227.133
498	37.221.161.235
498	78.108.63.44
498	79.134.234.200
498	80.47.227.161
498	82.123.4.28
498	91.240.66.43
498	94.23.55.63
498	94.252.118.196
498	96.47.226.22
501	193.136.44.193
502	146.185.152.202
502	194.154.214.210
502	31.22.122.2
502	62.190.106.2
503	194.154.214.210
505	46.19.137.116
505	77.7.173.234
507	85.168.71.172
507	89.158.199.236
508	118.68.122.19
511	120.146.220.159
511	123.243.127.234
512	46.38.250.97
512	5.10.165.210
512	88.198.17.37
515	195.6.51.239
515	81.53.225.16
515	90.84.144.79
517	185.3.45.6
518	31.22.122.2
518	31.22.122.5
519	115.73.203.184
519	14.161.77.87
520	103.247.16.2
520	111.119.205.194
520	111.223.88.132
520	111.251.147.126
520	112.140.184.245
520	115.43.70.213
520	118.168.72.56
520	119.30.39.1
520	121.31.255.15
520	123.193.250.54
520	125.227.139.193
520	128.2.142.104
520	140.112.25.11
520	140.112.25.13
520	140.112.25.21
520	140.112.25.23
520	140.112.25.3
520	140.112.25.4
520	140.112.25.46
520	140.112.25.48
520	140.112.25.49
520	140.112.25.50
520	140.112.25.58
520	140.112.25.6
520	140.112.25.63
520	140.112.25.64
520	140.112.25.66
520	140.112.25.69
520	140.112.25.72
520	140.112.25.74
520	140.112.25.77
520	140.112.25.87
520	140.112.25.88
520	140.112.25.90
520	175.106.14.234
520	175.180.67.220
520	175.98.71.211
520	178.219.12.210
520	180.149.96.169
520	180.250.130.130
520	182.50.64.67
520	186.47.84.139
520	188.95.32.186
520	190.0.33.18
520	190.124.165.194
520	190.38.2.17
520	190.57.73.146
520	190.82.89.156
520	190.99.75.3
520	193.40.239.25
520	194.141.252.102
520	197.160.89.73
520	197.210.252.44
520	197.220.195.174
520	200.88.113.147
520	203.189.136.17
520	212.138.92.17
520	217.196.59.226
520	218.211.32.194
520	219.84.235.241
520	219.85.182.141
520	219.87.142.18
520	220.132.115.200
520	41.191.204.87
520	41.202.77.195
520	41.208.150.116
520	41.215.33.66
520	41.222.196.37
520	41.74.44.35
520	42.71.250.170
520	60.251.42.235
520	62.173.43.73
520	69.50.64.153
520	77.242.22.254
520	77.48.185.122
520	78.134.255.42
520	78.141.120.184
520	82.114.95.238
520	83.235.177.207
520	84.42.3.3
520	88.249.230.31
521	128.178.115.161
521	128.178.115.37
521	188.60.87.124
521	212.243.190.53
521	62.220.135.200
521	62.220.135.208
522	218.228.195.11
523	109.156.122.202
523	129.31.230.76
523	129.31.231.72
523	151.230.174.137
523	90.193.46.26
523	90.193.88.253
523	90.199.57.33
523	90.199.66.83
523	93.96.116.61
524	123.30.135.76
524	183.80.41.210
526	128.39.43.110
526	128.39.81.184
526	213.187.190.50
526	37.139.22.73
526	62.16.208.94
526	77.40.159.35
526	82.147.39.131
526	94.102.42.74
526	95.34.252.232
526	95.34.253.12
526	95.34.253.173
527	1.179.147.2
527	109.185.116.199
527	111.119.205.194
527	112.140.184.245
527	113.28.244.195
527	115.124.74.97
527	116.251.209.115
527	121.130.177.59
527	121.52.146.117
527	122.52.125.100
527	123.200.20.66
527	125.214.163.2
527	151.237.220.10
527	173.245.67.198
527	175.136.192.5
527	176.221.76.46
527	178.155.65.180
527	178.18.31.116
527	178.208.255.123
527	178.48.2.237
527	178.76.152.89
527	178.78.2.93
527	178.78.4.92
527	185.4.253.104
527	186.103.143.211
527	186.24.10.76
527	187.157.32.65
527	188.233.104.20
527	188.233.109.154
527	188.233.153.193
527	188.233.16.9
527	188.233.52.25
527	188.95.32.186
527	190.0.9.202
527	190.110.218.18
527	190.122.177.14
527	190.122.186.214
527	190.124.165.194
527	190.151.10.226
527	190.181.27.24
527	190.232.225.186
527	192.69.200.37
527	194.132.32.42
527	194.141.252.102
527	195.222.36.86
527	196.201.20.134
527	196.202.252.21
527	197.160.56.108
527	197.214.76.142
527	197.218.196.82
527	198.50.237.84
527	2.228.23.58
527	2.92.25.166
527	200.46.24.114
527	200.5.113.202
527	201.195.100.83
527	201.76.172.110
527	202.95.192.46
527	203.119.8.69
527	203.189.136.199
527	203.78.161.82
527	203.83.6.5
527	204.8.156.142
527	206.251.61.236
527	207.232.7.168
527	210.65.151.65
527	212.138.92.17
527	212.249.11.115
527	213.131.41.98
527	213.231.192.213
527	217.149.179.66
527	31.180.152.247
527	31.180.155.61
527	31.180.180.2
527	41.188.38.161
527	41.191.204.87
527	41.193.36.226
527	41.202.77.195
527	41.208.150.114
527	41.208.68.52
527	41.222.196.37
527	41.225.3.117
527	41.67.2.2
527	41.72.105.38
527	41.74.44.35
527	41.78.26.154
527	41.79.61.26
527	42.120.20.120
527	54.228.210.35
527	62.201.207.14
527	62.253.249.2
527	72.252.114.147
527	78.107.6.100
527	78.134.255.43
527	78.141.79.233
527	78.38.80.131
527	80.241.44.98
527	80.242.34.242
527	80.80.173.78
527	80.90.27.60
527	82.114.78.201
527	82.128.124.174
527	83.235.177.207
527	85.173.64.232
527	86.111.144.194
527	88.249.227.98
527	88.85.108.16
527	89.26.71.134
527	89.28.120.190
527	92.243.6.225
527	93.115.46.10
527	94.154.222.127
527	94.200.108.10
527	94.233.122.49
527	94.233.42.62
527	94.46.217.169
530	177.1.238.14
530	177.6.111.167
530	179.176.62.125
530	179.186.121.78
530	179.252.1.162
530	186.214.59.217
530	187.126.177.201
530	189.105.139.234
530	201.41.75.126
531	80.112.236.194
532	143.127.2.8
534	177.17.30.155
534	179.76.18.151
535	166.70.207.2
535	188.165.208.7
535	195.26.129.185
535	212.63.218.1
535	212.96.58.189
535	24.30.17.202
535	37.221.160.203
535	46.217.191.57
535	5.9.146.202
535	66.129.63.64
535	69.15.17.214
535	76.187.104.235
535	77.247.181.163
535	77.247.181.165
535	78.22.182.45
535	82.196.13.177
535	93.115.87.34
535	94.23.170.2
535	96.44.189.102
535	96.47.226.21
536	109.195.66.224
536	109.205.249.43
536	78.25.121.253
539	37.235.49.16
539	78.142.142.99
540	193.190.253.149
540	84.210.97.221
540	86.127.10.70
540	86.127.13.63
543	98.233.12.190
544	50.115.123.212
545	134.147.202.121
547	109.201.154.162
547	193.190.253.145
547	193.190.253.147
547	46.165.210.17
547	46.19.137.78
549	112.255.12.160
549	112.255.12.44
549	124.127.108.135
549	222.195.149.190
549	222.206.196.74
549	222.206.197.8
552	173.255.253.196
554	109.175.6.188
554	115.188.136.161
554	118.82.27.1
554	118.96.94.252
554	119.114.195.18
554	121.52.146.117
554	123.30.75.115
554	125.214.163.2
554	133.242.206.94
554	159.255.166.131
554	173.193.202.116
554	175.196.65.153
554	180.211.143.100
554	183.89.131.71
554	185.4.253.106
554	186.67.46.229
554	188.95.32.186
554	190.0.58.58
554	190.122.186.214
554	190.129.85.211
554	190.150.101.109
554	190.167.214.134
554	190.236.93.98
554	193.40.239.25
554	196.201.20.134
554	196.202.252.21
554	196.28.228.253
554	197.214.76.142
554	199.201.125.147
554	2.188.16.105
554	2.50.7.65
554	200.124.242.99
554	200.192.215.138
554	201.116.216.149
554	201.149.84.67
554	201.248.252.161
554	202.170.83.212
554	202.71.101.187
554	202.79.52.53
554	202.95.192.46
554	203.122.52.166
554	203.189.136.199
554	203.83.6.5
554	206.190.158.75
554	208.122.242.158
554	213.131.41.98
554	213.135.234.6
554	213.244.81.17
554	219.94.251.115
554	31.209.99.187
554	37.130.229.149
554	37.4.46.101
554	41.134.181.250
554	41.188.38.161
554	41.191.204.87
554	41.208.68.52
554	41.215.33.66
554	41.72.105.38
554	41.74.44.35
554	41.79.61.26
554	42.3.157.231
554	46.8.147.160
554	5.199.166.250
554	5.29.68.113
554	54.253.154.57
554	69.50.64.153
554	72.252.114.147
554	77.247.181.163
554	78.111.55.164
554	78.130.136.18
554	82.114.95.238
554	83.212.125.177
554	83.235.177.207
554	85.33.52.218
554	87.236.194.158
554	88.255.147.83
554	89.26.71.134
554	91.214.200.45
554	91.220.124.37
554	91.239.232.49
554	93.125.83.79
554	94.154.24.1
554	95.211.129.17
555	66.162.4.62
555	68.50.228.45
555	69.2.182.167
555	71.127.53.31
556	217.197.2.96
559	84.107.84.17
561	195.95.131.65
561	77.97.128.8
562	71.175.97.111
563	194.154.216.91
563	31.22.122.2
564	94.209.79.117
565	2.233.250.247
565	200.10.167.1
565	200.30.233.90
566	123.30.75.115
566	196.201.20.134
566	213.163.72.224
566	23.92.16.185
566	46.0.31.143
566	5.164.151.187
566	88.191.190.7
566	92.247.48.44
567	109.207.61.14
567	109.224.6.170
567	110.74.207.101
567	113.28.244.195
567	116.193.170.214
567	118.69.205.202
567	118.97.130.10
567	121.52.146.117
567	122.248.228.149
567	123.13.205.185
567	125.214.163.2
567	129.110.241.77
567	129.110.242.7
567	173.57.107.239
567	173.57.95.183
567	175.139.246.45
567	175.196.65.153
567	178.208.255.123
567	178.48.2.237
567	178.63.74.6
567	180.180.121.35
567	180.94.69.68
567	181.14.202.229
567	182.50.64.67
567	185.4.253.106
567	186.46.187.43
567	187.125.147.178
567	188.136.216.129
567	188.95.32.186
567	190.0.47.242
567	190.124.165.194
567	190.150.101.109
567	190.181.27.24
567	190.216.229.68
567	190.43.50.127
567	190.82.89.156
567	193.189.127.134
567	194.19.245.45
567	195.222.36.86
567	195.39.167.45
567	196.201.20.134
567	196.202.252.21
567	196.41.253.4
567	197.136.42.3
567	197.160.56.108
567	197.218.196.82
567	197.220.195.174
567	199.204.45.90
567	2.133.93.74
567	2.50.7.65
567	200.46.86.66
567	200.85.39.10
567	200.88.113.147
567	201.163.18.108
567	201.249.7.76
567	203.176.119.2
567	203.189.136.17
567	203.83.6.5
567	207.232.7.168
567	210.65.151.65
567	212.249.11.115
567	213.110.196.195
567	213.131.41.98
567	213.135.234.6
567	213.181.73.145
567	213.244.81.17
567	217.169.209.2
567	217.19.216.87
567	220.225.131.41
567	37.187.60.3
567	41.0.57.69
567	41.191.204.87
567	41.202.77.195
567	41.210.55.157
567	41.211.108.167
567	41.222.196.37
567	41.59.254.18
567	41.67.2.2
567	41.79.61.26
567	46.144.137.170
567	67.214.94.122
567	72.252.114.147
567	76.187.59.226
567	78.111.55.164
567	78.134.255.42
567	78.134.255.43
567	78.141.119.227
567	78.141.79.233
567	80.250.23.178
567	80.90.161.130
567	82.114.95.238
567	82.128.124.174
567	88.249.230.31
567	88.85.108.16
567	89.190.195.170
567	92.245.172.38
567	94.46.217.169
567	99.6.235.165
569	211.24.8.188
570	93.42.199.11
570	93.42.214.55
572	108.176.197.66
572	123.13.205.185
572	128.113.147.33
572	128.213.48.84
572	129.161.225.113
572	129.161.225.136
572	129.161.225.175
572	129.161.44.222
572	129.161.66.97
572	129.161.84.168
572	178.48.2.237
572	202.152.6.10
572	222.180.173.1
572	63.216.146.37
572	63.251.248.156
572	64.102.254.33
572	71.174.125.252
572	82.114.95.238
572	91.230.54.60
572	94.228.193.6
574	84.237.53.3
574	84.237.55.29
576	72.130.251.55
580	116.236.216.116
580	178.132.21.58
580	180.183.234.206
580	77.196.252.127
580	83.157.65.201
580	88.187.2.57
583	188.226.27.237
583	193.151.56.30
583	194.226.244.126
583	195.206.50.34
583	212.193.76.45
583	212.193.76.57
583	212.193.77.13
583	212.193.77.16
583	212.193.77.93
583	213.191.25.14
583	213.87.240.46
583	213.87.241.156
583	46.17.201.51
583	95.82.243.203
584	85.16.40.84
584	91.96.27.254
585	110.174.186.119
585	114.179.18.36
585	118.167.10.165
585	118.70.67.239
585	121.140.224.197
585	151.21.64.227
585	177.96.11.57
585	190.222.194.54
585	190.228.11.167
585	192.149.109.214
585	37.15.2.203
585	41.189.45.36
585	50.98.45.1
585	72.237.56.20
585	81.230.48.116
585	82.6.155.232
585	88.170.217.51
586	220.108.170.173
587	149.239.163.211
587	31.22.122.2
587	92.205.106.183
588	117.20.91.238
589	70.171.8.136
589	70.209.11.24
590	68.48.96.45
591	203.194.113.3
592	31.22.122.2
594	107.25.10.161
594	115.87.71.151
594	116.40.129.219
594	146.185.24.28
594	185.3.135.154
594	189.59.137.109
594	209.222.18.35
594	24.130.204.19
594	24.5.124.27
594	46.165.208.194
594	5.39.68.159
594	50.174.238.61
594	50.197.165.201
594	64.134.220.240
594	69.255.47.168
594	72.66.8.138
594	85.222.186.142
594	85.83.32.41
594	89.66.4.50
594	91.176.43.117
594	93.115.83.16
594	94.102.63.86
594	94.202.19.237
594	99.115.80.192
594	99.135.68.198
596	91.218.222.38
597	195.19.33.191
597	195.19.34.161
597	195.19.34.171
597	195.19.34.207
597	87.249.17.101
597	95.25.246.123
598	125.24.109.187
599	109.90.117.69
599	109.90.119.86
599	176.198.220.11
599	178.200.56.195
601	184.57.154.202
601	216.68.89.74
601	216.68.89.80
601	24.27.183.206
601	64.134.47.34
601	66.42.134.183
602	105.135.0.65
602	105.139.18.66
603	195.46.44.195
603	79.253.142.103
605	140.113.208.226
605	140.113.62.215
607	92.239.20.53
608	67.164.178.227
608	8.18.116.2
610	81.164.199.228
611	192.197.54.62
611	199.7.156.133
611	206.223.185.250
611	212.63.218.1
611	37.221.161.234
611	70.51.234.61
611	78.108.63.46
612	24.190.67.61
613	84.80.236.146
614	194.203.215.254
615	62.160.12.121
615	62.2.213.50
615	77.199.99.93
615	80.10.159.68
615	80.10.159.75
615	80.12.100.68
615	81.220.31.74
615	82.235.60.209
615	82.67.132.206
615	88.188.188.124
615	90.84.145.17
615	94.103.98.25
616	122.168.206.253
617	82.67.132.206
618	130.85.224.15
619	108.6.142.201
619	128.238.242.19
619	128.238.245.192
619	128.238.246.227
619	128.238.246.246
619	128.238.248.99
619	128.238.249.105
619	128.238.66.6
620	129.7.134.195
620	38.122.74.18
621	62.210.239.118
622	81.38.14.214
623	78.192.7.102
624	108.61.55.67
624	130.85.203.151
624	130.85.224.15
624	130.85.240.48
624	130.85.243.3
624	130.85.247.111
624	130.85.58.227
624	130.85.58.235
624	130.85.58.236
624	130.85.58.237
624	130.85.58.238
624	209.222.18.43
624	209.222.5.236
624	209.222.7.236
624	212.138.92.17
624	64.237.37.119
624	64.237.37.120
624	64.237.51.170
624	66.55.150.187
624	68.232.186.195
624	68.232.186.235
624	68.50.3.140
624	68.54.175.188
624	69.243.124.242
625	81.166.238.228
626	109.90.217.58
626	217.6.21.93
626	84.201.30.172
627	117.0.200.94
628	174.24.40.176
628	75.71.54.126
629	91.50.77.241
630	81.153.235.129
630	94.23.170.2
631	46.42.212.51
632	108.40.31.31
632	109.185.116.199
632	109.207.61.14
632	115.133.122.234
632	118.69.168.7
632	119.10.115.165
632	119.15.81.210
632	121.52.146.117
632	122.255.58.121
632	125.160.181.211
632	163.29.38.166
632	168.226.35.19
632	175.196.65.153
632	176.31.233.170
632	178.18.25.85
632	178.18.31.116
632	182.52.235.27
632	185.4.253.104
632	185.4.253.106
632	186.101.40.138
632	188.26.115.161
632	188.95.32.186
632	190.128.205.2
632	190.150.101.109
632	190.151.10.226
632	190.207.156.165
632	190.249.133.219
632	194.19.245.45
632	195.222.36.86
632	197.136.42.3
632	197.163.85.11
632	199.204.45.90
632	200.13.157.186
632	200.152.100.160
632	200.23.26.7
632	200.37.53.116
632	200.46.24.114
632	200.7.33.250
632	202.219.117.82
632	202.79.52.53
632	203.83.6.5
632	207.232.7.168
632	212.144.254.122
632	213.181.73.145
632	217.169.209.2
632	218.213.104.17
632	220.225.131.41
632	27.147.148.194
632	41.164.23.162
632	41.223.64.91
632	41.74.44.35
632	71.179.179.108
632	71.179.49.217
632	77.43.143.31
632	78.111.55.164
632	78.130.136.18
632	78.134.255.42
632	78.141.79.233
632	78.157.31.171
632	80.122.215.250
632	80.193.214.226
632	80.241.44.98
632	82.114.78.201
632	82.145.242.105
632	85.185.42.3
632	86.111.144.194
632	87.229.26.141
632	93.89.107.123
632	94.158.148.166
632	96.244.42.7
632	96.244.99.57
633	216.96.216.22
633	96.60.250.229
635	134.61.96.208
635	46.246.47.31
635	46.246.58.163
635	89.0.27.157
635	89.0.30.201
635	92.73.99.80
636	188.224.15.19
636	188.224.19.40
636	93.182.197.63
636	93.182.201.226
637	70.29.216.136
638	195.206.50.34
638	84.244.55.130
639	68.110.65.219
640	192.197.54.26
641	109.201.154.140
641	130.185.155.170
641	146.185.18.114
641	155.246.105.38
641	155.246.107.58
641	155.246.110.106
641	155.246.114.200
641	155.246.126.67
641	155.246.136.110
641	155.246.137.54
641	155.246.202.48
641	155.246.209.31
641	155.246.209.62
641	155.246.222.38
641	155.246.46.38
641	155.246.5.67
641	155.246.9.221
641	162.219.179.18
641	173.3.148.180
641	185.3.135.18
641	200.225.198.121
641	46.165.251.67
641	46.19.140.62
641	46.23.68.180
641	5.39.68.159
641	5.63.147.100
641	66.55.150.183
641	66.55.150.188
641	68.193.55.222
641	68.194.80.202
641	68.196.254.206
641	74.50.124.114
641	78.141.120.184
641	93.115.82.54
642	200.38.168.156
642	200.38.176.170
643	190.216.26.194
643	193.251.26.23
643	79.80.48.73
645	108.207.101.74
645	110.74.213.227
645	111.119.205.194
645	118.70.129.101
645	118.97.194.52
645	120.72.84.192
645	162.243.36.229
645	174.113.163.166
645	175.136.192.5
645	182.50.64.67
645	186.42.212.237
645	188.136.216.129
645	188.165.3.15
645	188.95.32.186
645	190.38.191.47
645	190.42.160.241
645	190.99.75.3
645	195.225.144.38
645	197.160.56.108
645	198.23.71.87
645	200.253.116.3
645	200.75.3.85
645	200.75.51.151
645	203.176.119.2
645	207.232.7.168
645	217.169.209.2
645	41.215.33.66
645	41.216.171.154
645	46.248.58.62
645	61.178.176.25
645	62.162.6.11
645	62.201.207.14
645	64.125.69.200
645	70.36.146.223
645	78.111.55.164
645	78.130.201.110
645	78.141.120.184
645	84.42.3.3
645	92.245.172.38
645	92.39.54.161
645	94.154.24.1
646	66.108.51.1
647	188.60.84.114
648	199.241.213.184
649	122.173.119.231
650	119.192.179.7
651	182.160.49.184
651	182.160.9.86
651	183.177.103.108
651	218.100.84.14
651	218.100.84.174
652	130.85.240.48
653	173.116.33.39
653	68.26.85.190
654	141.70.81.135
654	141.70.81.139
654	46.5.2.240
654	46.5.2.98
655	128.198.220.214
655	128.198.46.17
655	174.24.61.180
656	76.167.137.155
657	24.213.116.185
658	1.179.128.2
658	1.246.25.81
658	1.246.27.25
658	1.248.101.244
658	105.224.109.43
658	105.225.57.226
658	111.119.205.194
658	115.127.29.210
658	116.193.170.214
658	118.44.143.207
658	120.51.211.137
658	125.146.248.89
658	125.214.163.2
658	14.52.168.33
658	175.136.192.5
658	178.219.12.210
658	178.48.2.237
658	182.50.64.67
658	185.4.253.104
658	186.46.187.43
658	187.59.5.208
658	188.26.115.161
658	190.124.165.194
658	190.150.101.109
658	190.151.10.226
658	190.181.27.24
658	192.227.139.227
658	194.213.60.222
658	195.222.36.86
658	195.225.144.38
658	196.205.129.5
658	197.160.56.108
658	2.185.1.100
658	2.50.7.65
658	200.7.33.250
658	203.176.119.2
658	203.189.136.17
658	213.135.234.6
658	217.12.113.67
658	217.169.209.2
658	220.72.15.53
658	220.78.196.59
658	31.47.103.3
658	41.191.204.87
658	41.215.33.66
658	41.216.171.154
658	41.67.2.2
658	46.248.58.62
658	49.1.218.115
658	49.1.218.93
658	5.199.166.250
658	54.229.138.114
658	62.162.6.11
658	62.175.140.154
658	62.253.249.2
658	77.242.22.254
658	78.130.136.18
658	78.130.201.110
658	78.134.251.152
658	78.141.119.227
658	78.141.120.184
658	80.90.27.60
658	81.113.237.138
658	82.128.124.174
658	88.146.243.118
658	88.249.230.31
658	91.220.124.37
658	92.39.54.161
658	93.125.83.79
658	94.154.24.1
658	95.159.105.2
659	67.159.5.242
659	67.84.57.63
659	85.25.139.51
660	66.44.228.38
661	128.2.142.23
661	128.2.142.55
661	128.237.200.188
661	128.237.200.38
661	67.165.106.243
662	172.14.122.43
662	70.245.72.233
663	128.223.223.65
664	192.35.156.11
664	192.81.129.29
664	75.80.57.22
666	171.98.93.200
667	60.241.79.55
668	126.205.133.202
668	126.205.155.213
669	162.205.4.201
670	126.209.83.31
670	180.19.239.90
670	209.239.114.86
671	182.158.146.193
672	50.7.31.202
673	78.94.53.172
675	75.83.44.240
676	118.70.128.104
677	94.224.178.231
678	80.215.65.132
678	83.152.62.23
679	122.160.65.142
680	222.122.41.200
681	62.39.9.251
681	86.64.185.52
684	211.129.228.95
684	96.47.226.20
685	182.250.53.144
685	60.71.162.243
686	117.213.240.154
687	31.22.122.2
688	158.64.77.110
689	156.17.33.118
691	180.200.190.52
692	115.254.75.113
695	116.14.202.106
695	143.127.2.8
695	216.10.193.21
695	42.61.41.114
696	109.134.10.113
696	158.64.77.110
696	158.64.77.98
696	178.254.99.214
696	188.115.29.39
696	194.154.216.82
696	194.154.216.89
696	194.154.216.90
696	212.63.218.1
696	212.66.74.148
696	212.66.74.149
696	212.76.9.216
696	213.163.72.224
696	31.172.30.1
696	31.172.30.2
696	31.34.214.231
696	78.235.124.74
696	83.99.77.96
696	85.93.199.115
696	85.95.194.158
696	88.207.220.123
696	88.207.220.124
696	88.207.220.228
696	91.45.122.134
696	92.130.73.10
696	94.109.121.20
696	94.109.82.51
696	94.252.1.119
696	94.252.52.173
696	96.44.189.100
697	113.172.73.142
697	123.20.174.11
697	123.20.176.20
697	123.20.176.231
697	183.80.183.241
698	123.26.130.135
699	194.29.214.244
700	79.168.250.201
700	89.191.34.217
700	95.83.253.129
700	95.83.253.152
701	219.228.110.221
702	14.140.125.213
703	113.108.76.39
705	59.11.87.199
706	87.238.44.72
707	41.217.166.136
707	41.40.168.247
708	192.30.86.247
709	108.78.248.14
709	98.207.93.95
710	108.12.41.24
710	12.31.4.250
710	150.156.201.20
710	166.137.80.124
711	91.153.118.224
712	58.187.38.118
714	112.148.17.48
714	183.91.226.83
714	218.55.247.75
714	220.87.16.9
717	134.147.232.61
718	197.153.50.164
719	117.7.77.227
723	93.223.207.210
724	163.5.222.61
724	163.5.223.215
725	37.24.153.212
726	132.170.47.29
727	109.163.233.195
727	109.74.151.149
727	111.110.246.205
727	128.52.128.105
727	166.70.207.2
727	171.25.193.131
727	172.245.44.177
727	173.254.216.66
727	173.254.216.67
727	173.254.216.69
727	178.32.172.126
727	178.33.169.46
727	18.187.1.68
727	194.104.126.126
727	194.132.32.42
727	198.50.177.195
727	198.96.155.3
727	199.15.112.86
727	199.19.110.166
727	199.48.147.39
727	204.124.83.130
727	209.15.212.177
727	209.222.8.196
727	212.232.24.57
727	212.83.151.15
727	212.83.151.18
727	212.83.151.26
727	212.96.58.189
727	213.108.105.253
727	213.163.72.224
727	213.165.71.31
727	213.61.149.100
727	216.218.134.12
727	217.115.10.134
727	217.16.182.20
727	23.29.121.166
727	31.172.30.1
727	31.172.30.4
727	37.130.227.133
727	37.139.24.230
727	37.221.160.203
727	37.221.161.234
727	37.221.161.235
727	37.59.162.218
727	46.165.221.166
727	46.167.245.50
727	5.79.81.200
727	62.220.135.129
727	77.109.139.26
727	77.244.254.228
727	77.247.181.163
727	77.247.181.165
727	78.108.63.44
727	78.108.63.46
727	79.136.23.82
727	79.172.193.32
727	80.101.43.16
727	81.7.13.4
727	85.25.208.201
727	85.25.46.235
727	87.118.91.140
727	91.121.248.217
727	91.194.60.126
727	91.213.8.235
727	91.213.8.84
727	93.115.82.179
727	95.128.43.164
727	95.130.9.89
727	96.44.189.100
727	96.44.189.101
727	96.44.189.102
727	96.47.226.20
727	96.47.226.21
727	96.47.226.22
728	109.175.6.188
728	110.139.206.93
728	110.74.207.101
728	110.74.213.227
728	110.77.232.150
728	118.179.4.221
728	121.11.167.246
728	122.52.125.100
728	125.214.163.2
728	175.136.192.5
728	175.196.65.153
728	176.123.246.178
728	178.149.22.103
728	178.169.169.50
728	178.18.25.85
728	178.48.2.237
728	185.4.253.104
728	189.85.29.110
728	190.110.218.18
728	190.122.186.214
728	190.181.27.24
728	190.206.243.72
728	190.218.246.30
728	190.248.86.10
728	190.57.73.146
728	190.82.101.74
728	194.154.214.210
728	197.210.252.44
728	197.220.195.174
728	197.255.213.146
728	2.188.16.83
728	201.243.121.198
728	202.162.208.2
728	202.95.192.46
728	203.83.6.5
728	206.251.61.16
728	206.251.61.236
728	207.232.7.168
728	210.65.151.65
728	212.249.11.115
728	217.71.228.121
728	218.213.104.17
728	31.209.99.187
728	41.202.77.195
728	41.208.68.52
728	41.32.16.82
728	41.67.2.2
728	41.72.105.38
728	41.78.76.214
728	41.79.61.26
728	62.162.6.11
728	63.216.146.37
728	67.17.44.2
728	69.50.64.153
728	77.242.22.254
728	78.130.136.18
728	78.134.255.43
728	80.185.184.169
728	80.242.34.242
728	80.93.22.78
728	82.114.95.238
728	83.235.177.207
728	85.20.241.114
728	89.28.120.190
728	90.33.46.237
728	92.247.48.44
728	92.51.109.181
728	94.46.217.169
729	206.183.28.85
729	75.118.125.22
730	1.55.155.96
731	78.25.120.191
732	41.227.150.211
733	24.50.80.52
734	118.71.96.15
735	123.243.53.229
735	136.186.17.183
736	14.139.225.181
736	14.139.225.182
736	14.139.225.183
736	14.139.228.211
736	14.139.228.212
736	210.212.61.151
736	91.207.183.244
737	108.174.98.53
737	166.147.126.87
738	194.154.214.210
738	88.125.101.87
739	36.83.103.63
740	41.143.94.130
741	80.101.71.77
743	134.147.31.242
744	122.172.11.17
745	77.207.111.119
745	84.14.214.215
746	199.111.183.99
747	115.74.131.53
748	64.125.69.200
749	80.218.20.38
751	178.149.87.85
751	24.135.215.103
751	89.216.124.208
752	122.164.40.114
753	12.31.4.250
753	150.156.210.201
754	50.152.134.219
754	79.10.221.205
755	198.140.203.1
756	150.156.201.20
756	150.156.210.239
756	150.156.215.67
756	150.156.216.214
756	150.156.218.42
756	150.156.221.42
757	173.69.204.212
758	209.129.244.250
759	173.250.152.254
759	69.91.137.11
760	58.187.219.43
761	24.151.191.64
762	144.76.16.66
762	96.44.189.102
763	98.233.84.65
764	203.13.146.51
764	203.13.146.61
766	158.64.77.102
767	31.3.255.194
768	192.70.106.67
769	140.109.135.164
1	32.11.12.0/24
\.


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: challenge_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY challenge
    ADD CONSTRAINT challenge_pkey PRIMARY KEY (id);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: geoip_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY geoip
    ADD CONSTRAINT geoip_pkey PRIMARY KEY (ip_range_start);


--
-- Name: massmail_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY massmail
    ADD CONSTRAINT massmail_pkey PRIMARY KEY (id);


--
-- Name: news_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: submission_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (team_id, challenge_id);


--
-- Name: team_avatar_filename_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_avatar_filename_key UNIQUE (avatar_filename);


--
-- Name: team_challenge_token_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_challenge_token_key UNIQUE (challenge_token);


--
-- Name: team_email_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_email_key UNIQUE (email);


--
-- Name: team_flag_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team_flag
    ADD CONSTRAINT team_flag_pkey PRIMARY KEY (team_id, flag);


--
-- Name: team_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team_ip
    ADD CONSTRAINT team_ip_pkey PRIMARY KEY (team_id, ip);


--
-- Name: team_name_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_name_key UNIQUE (name);


--
-- Name: team_pkey; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: team_ref_token_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_ref_token_key UNIQUE (ref_token);


--
-- Name: team_reset_token_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_reset_token_key UNIQUE (reset_token);


--
-- Name: team_token_key; Type: CONSTRAINT; Schema: public; Owner: javex; Tablespace: 
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_token_key UNIQUE (token);


--
-- Name: ix_geoip_ip_range_end; Type: INDEX; Schema: public; Owner: javex; Tablespace: 
--

CREATE UNIQUE INDEX ix_geoip_ip_range_end ON geoip USING btree (ip_range_end);


--
-- Name: challenge_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY challenge
    ADD CONSTRAINT challenge_category_id_fkey FOREIGN KEY (category_id) REFERENCES category(id);


--
-- Name: news_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES challenge(id);


--
-- Name: submission_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES challenge(id);


--
-- Name: submission_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(id);


--
-- Name: team_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(id);


--
-- Name: team_flag_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY team_flag
    ADD CONSTRAINT team_flag_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(id);


--
-- Name: team_ip_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: javex
--

ALTER TABLE ONLY team_ip
    ADD CONSTRAINT team_ip_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

