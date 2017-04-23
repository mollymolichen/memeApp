CREATE TABLE Users
(
uid INTEGER NOT NULL PRIMARY KEY,
name VARCHAR(256) NOT NULL,
password VARCHAR(256) NOT NULL,
avatar VARCHAR(256),
currentMeme INTEGER NOT NULL
-- CHECK(LEN(password)>10)
);

CREATE TABLE Meme
(
memeID INTEGER NOT NULL PRIMARY KEY,
caption VARCHAR(256) NOT NULL,
filepath VARCHAR(256) NOT NULL,
imagename VARCHAR(256) NOT NULL
);

CREATE TABLE TAG
(
name VARCHAR(256) NOT NULL PRIMARY KEY
);

CREATE TABLE IsFriend
(
uid INTEGER NOT NULL REFERENCES Users(uid),
friend INTEGER NOT NULL REFERENCES Users(uid),
PRIMARY KEY(uid,friend)
);

CREATE TABLE PotentialPartner
(
uid INTEGER NOT NULL REFERENCES Users(uid),
partner INTEGER NOT NULL REFERENCES Users(uid),
PRIMARY KEY (uid, partner)
);

CREATE TABLE Opinion
(
uid INTEGER NOT NULL REFERENCES Users(uid),
memeID INTEGER NOT NULL REFERENCES Meme(memeID),
preference INTEGER NOT NULL,
-- #0=neutral, 1=likes, -1=dislike
);

CREATE TABLE HasTag
(
memeID INTEGER NOT NULL REFERENCES Meme(memeID),
tagName VARCHAR(256) NOT NULL REFERENCES Tag(name),
PRIMARY KEY(memeID,tagName)
);

CREATE TABLE TagCount
(
uid INTEGER NOT NULL REFERENCES Users(uid),
multiPanel INTEGER NOT NULL,
celebrity INTEGER NOT NULL,
singleImage INTEGER NOT NULL,
anime INTEGER NOT NULL,
gaming INTEGER NOT NULL,
politics INTEGER NOT NULL,
wholesome INTEGER NOT NULL,
race INTEGER NOT NULL,
total INTEGER NOT NULL
);


-- check if the memes exist in the database or not 
CREATE FUNCTION Add_To_Opinion_Table() RETURNS TRIGGER AS $$
BEGIN 
	IF NOT EXISTS (Select * from TagCount WHERE NEW.uid = TagCount.uid) THEN
		INSERT INTO TagCount VALUES(new.uid,0,0,0,0,0,0,0,0,0); 
	END IF;
	IF (NEW.preference = 1) THEN
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'single-image') THEN
			UPDATE TagCount SET singleImage=singleImage+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'multi-panel') THEN
			UPDATE TagCount SET multiPanel=multiPanel+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'celebrity') THEN
			UPDATE TagCount SET celebrity=celebrity+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'anime') THEN
			UPDATE TagCount SET anime=anime+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'gaming') THEN
			UPDATE TagCount SET gaming=gaming+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'politics') THEN
			UPDATE TagCount SET politics=politics+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'wholesome') THEN
			UPDATE TagCount SET wholesome=wholesome+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
		IF EXISTS (Select * from HasTag WHERE NEW.memeID = hasTag.memeID AND hasTag.tagName = 'race') THEN
			UPDATE TagCount SET race=race+1,total=total+1 WHERE uid=NEW.uid;
		END IF;
	END IF; 
	RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

-- check if the tag exist in the database or not
CREATE TRIGGER Add_To_Opinion_Table
	BEFORE INSERT ON Opinion
	FOR EACH ROW
	EXECUTE PROCEDURE Add_To_Opinion_Table();

-- check if the memes exist in the database or not 
CREATE FUNCTION Add_To_Meme_Table() RETURNS TRIGGER AS $$
BEGIN 
	IF EXISTS (Select * from Meme WHERE NEW.caption = Meme.caption) THEN
	RAISE EXCEPTION '% : Duplicate Meme', NEW.Caption;
	END IF; 
	RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

-- check if the tag exist in the database or not
CREATE TRIGGER Add_To_Meme_Table
	BEFORE INSERT ON Meme
	FOR EACH ROW
	EXECUTE PROCEDURE Add_To_Meme_Table();
    
    
CREATE FUNCTION Add_To_Tag_Table() RETURNS TRIGGER AS $$
BEGIN 
	IF NOT EXISTS (Select * from Tag WHERE NEW.tagName = Tag.name) THEN
    INSERT INTO TAG VALUES(NEW.tagName);
	END IF; 
	RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Add_To_Tag_Table
	BEFORE INSERT ON HasTag
	FOR EACH ROW
	EXECUTE PROCEDURE Add_To_Tag_Table();


-- #hand-populated small dataset

INSERT INTO Users VALUES(1,'joyce','admin',NULL, 1);
INSERT INTO Users VALUES(2,'jerry','admin',NULL, 1);
INSERT INTO Users VALUES(3,'mom','admin',NULL, 1);
INSERT INTO Users VALUES(4,'dad','admin',NULL, 1);
INSERT INTO Users VALUES(5,'jessica','admin',NULL, 1);
INSERT INTO Users VALUES(6, 'molly','admin',NULL, 1);
INSERT INTO Users VALUES(7, 'fangge','admin',NULL, 1);
INSERT INTO Users VALUES(8, 'naijiao','admin',NULL, 1);
INSERT INTO Users VALUES(9, 'joyce Choi','admin',NULL, 1);
INSERT INTO Users VALUES(10, 'nana','admin',NULL, 1);

INSERT INTO Tag VALUES('multi-panel');
INSERT INTO Tag VALUES('celebrity');
INSERT INTO Tag VALUES('single-image');
INSERT INTO Tag VALUES('anime');
INSERT INTO Tag VALUES('gaming');
INSERT INTO Tag VALUES('politics');
INSERT INTO Tag VALUES('wholesome');
INSERT INTO Tag VALUES('race');


INSERT INTO isFriend VALUES(1, 3);
INSERT INTO isFriend VALUES(2, 4);

INSERT INTO PotentialPartner VALUES(1, 5);
INSERT INTO PotentialPartner VALUES(2, 5);
INSERT INTO PotentialPartner VALUES(2, 3);
INSERT INTO PotentialPartner VALUES(2, 4);
INSERT INTO PotentialPartner VALUES(2, 6);

INSERT INTO Meme VALUES(1, '10_seconds_later','../static/media/faces/10_seconds_later.jpg','10_seconds_later.jpg');
INSERT INTO Meme VALUES(2, '10guy','../static/media/faces/10guy.jpg','10guy.jpg');
INSERT INTO Meme VALUES(3, '12_seconds_later','../static/media/faces/12_seconds_later.jpg','12_seconds_later.jpg');
INSERT INTO Meme VALUES(4, '15_minutes_later','../static/media/faces/15_minutes_later.jpg','15_minutes_later.jpg');
INSERT INTO Meme VALUES(5, '1_minute_37_seconds','../static/media/faces/1_minute_37_seconds.jpg','1_minute_37_seconds.jpg');
INSERT INTO Meme VALUES(6, '2000_years_later','../static/media/faces/2000_years_later.jpg','2000_years_later.jpg');
INSERT INTO Meme VALUES(7, '3000_years_later','../static/media/faces/3000_years_later.jpg','3000_years_later.jpg');
INSERT INTO Meme VALUES(8, '346_minutes_later','../static/media/faces/346_minutes_later.jpg','346_minutes_later.jpg');
INSERT INTO Meme VALUES(9, '3_28_am','../static/media/faces/3_28_am.jpg','3_28_am.jpg');

INSERT INTO HasTag VALUES(1, 'single-image');
INSERT INTO HasTag VALUES(2, 'gaming');
INSERT INTO HasTag VALUES(3, 'wholesome');
INSERT INTO HasTag VALUES(4, 'anime');
INSERT INTO HasTag VALUES(5, 'politics');
INSERT INTO HasTag VALUES(6, 'race');
INSERT INTO HasTag VALUES(3, 'celebrity');

INSERT INTO Opinion VALUES(8,1,1);
INSERT INTO Opinion VALUES(7,1,1);

-- INSERT INTO Meme VALUES(10, '3_days_later','../static/media/faces/3_days_later.jpg','3_days_later.jpg');
-- INSERT INTO Meme VALUES(11, '3_days_later_2','../static/media/faces/3_days_later_2.jpg','3_days_later_2.jpg');
-- INSERT INTO Meme VALUES(12, '3_days_later_3','../static/media/faces/3_days_later_3.jpg','3_days_later_3.jpg');
-- INSERT INTO Meme VALUES(13, '3_days_later_4','../static/media/faces/3_days_later_4.jpg','3_days_later_4.jpg');
-- INSERT INTO Meme VALUES(14, '3_days_later_5','../static/media/faces/3_days_later_5.jpg','3_days_later_5.jpg');
-- INSERT INTO Meme VALUES(15, '3_hours_later','../static/media/faces/3_hours_later.jpg','3_hours_later.jpg');
-- INSERT INTO Meme VALUES(16, '48_hours_later','../static/media/faces/48_hours_later.jpg','48_hours_later.jpg');
-- INSERT INTO Meme VALUES(17, '4_to_6_weeks_later','../static/media/faces/4_to_6_weeks_later.jpg','4_to_6_weeks_later.jpg');
-- INSERT INTO Meme VALUES(18, '5_minutes_later','../static/media/faces/5_minutes_later.jpg','5_minutes_later.jpg');
-- INSERT INTO Meme VALUES(19, '6_half_hours_later','../static/media/faces/6_half_hours_later.jpg','6_half_hours_later.jpg');
-- INSERT INTO Meme VALUES(20, '6_months_later','../static/media/faces/6_months_later.jpg','6_months_later.jpg');
-- INSERT INTO Meme VALUES(21, '7_59_am','../static/media/faces/7_59_am.jpg','7_59_am.jpg');
-- INSERT INTO Meme VALUES(22, '7_hours_later','../static/media/faces/7_hours_later.jpg','7_hours_later.jpg');
-- INSERT INTO Meme VALUES(23, '8_01_pm','../static/media/faces/8_01_pm.jpg','8_01_pm.jpg');
-- INSERT INTO Meme VALUES(24, '8_hours_later','../static/media/faces/8_hours_later.jpg','8_hours_later.jpg');
-- INSERT INTO Meme VALUES(25, 'a_few_inches_later','../static/media/faces/a_few_inches_later.jpg','a_few_inches_later.jpg');
-- INSERT INTO Meme VALUES(26, 'a_few_minutes_later','../static/media/faces/a_few_minutes_later.jpg','a_few_minutes_later.jpg');
-- INSERT INTO Meme VALUES(27, 'a_few_moments_later','../static/media/faces/a_few_moments_later.jpg','a_few_moments_later.jpg');
-- INSERT INTO Meme VALUES(28, 'accidentally_open_internet_explorer','../static/media/faces/accidentally_open_internet_explorer.jpg','accidentally_open_internet_explorer.jpg');
-- INSERT INTO Meme VALUES(29, 'actually','../static/media/faces/actually.jpg','actually.jpg');
-- INSERT INTO Meme VALUES(30, 'advice_dog','../static/media/faces/advice_dog.jpg','advice_dog.jpg');
-- INSERT INTO Meme VALUES(31, 'advice_god','../static/media/faces/advice_god.jpg','advice_god.jpg');
-- INSERT INTO Meme VALUES(32, 'advice_yoda_gives','../static/media/faces/advice_yoda_gives.jpg','advice_yoda_gives.jpg');
-- INSERT INTO Meme VALUES(33, 'aint_that_some_shit','../static/media/faces/aint_that_some_shit.jpg','aint_that_some_shit.jpg');
-- INSERT INTO Meme VALUES(34, 'alien','../static/media/faces/alien.jpg','alien.jpg');
-- INSERT INTO Meme VALUES(35, 'all_the_things_fuu','../static/media/faces/all_the_things_fuu.jpg','all_the_things_fuu.jpg');
-- INSERT INTO Meme VALUES(36, 'all_the_things_sad','../static/media/faces/all_the_things_sad.jpg','all_the_things_sad.jpg');
-- INSERT INTO Meme VALUES(37, 'angry_bang','../static/media/faces/angry_bang.jpg','angry_bang.jpg');
-- INSERT INTO Meme VALUES(38, 'angry_dark_stare','../static/media/faces/angry_dark_stare.jpg','angry_dark_stare.jpg');
-- INSERT INTO Meme VALUES(39, 'angry_head_shake','../static/media/faces/angry_head_shake.jpg','angry_head_shake.jpg');
-- INSERT INTO Meme VALUES(40, 'angry_mom','../static/media/faces/angry_mom.jpg','angry_mom.jpg');
-- INSERT INTO Meme VALUES(41, 'angry_mouth','../static/media/faces/angry_mouth.jpg','angry_mouth.jpg');
-- INSERT INTO Meme VALUES(42, 'angry_school_boy','../static/media/faces/angry_school_boy.jpg','angry_school_boy.jpg');
-- INSERT INTO Meme VALUES(43, 'angry_shaking','../static/media/faces/angry_shaking.jpg','angry_shaking.jpg');
-- INSERT INTO Meme VALUES(44, 'angry_with_pc','../static/media/faces/angry_with_pc.jpg','angry_with_pc.jpg');
-- INSERT INTO Meme VALUES(45, 'annoying_childhood_friend','../static/media/faces/annoying_childhood_friend.jpg','annoying_childhood_friend.jpg');
-- INSERT INTO Meme VALUES(46, 'annoying_facebook_girl','../static/media/faces/annoying_facebook_girl.jpg','annoying_facebook_girl.jpg');
-- INSERT INTO Meme VALUES(47, 'anonymous_mask','../static/media/faces/anonymous_mask.jpg','anonymous_mask.jpg');
-- INSERT INTO Meme VALUES(48, 'anti_joke_chicken','../static/media/faces/anti_joke_chicken.jpg','anti_joke_chicken.jpg');
-- INSERT INTO Meme VALUES(49, 'are_you_fucking_kidding_me','../static/media/faces/are_you_fucking_kidding_me.jpg','are_you_fucking_kidding_me.jpg');
-- INSERT INTO Meme VALUES(50, 'are_you_fucking_kidding_me_clean','../static/media/faces/are_you_fucking_kidding_me_clean.jpg','are_you_fucking_kidding_me_clean.jpg');
-- INSERT INTO Meme VALUES(51, 'arrow_in_knee','../static/media/faces/arrow_in_knee.jpg','arrow_in_knee.jpg');
-- INSERT INTO Meme VALUES(52, 'art_student_owl','../static/media/faces/art_student_owl.jpg','art_student_owl.jpg');
-- INSERT INTO Meme VALUES(53, 'awkward_moment','../static/media/faces/awkward_moment.jpg','awkward_moment.jpg');
-- INSERT INTO Meme VALUES(54, 'aww_yeah','../static/media/faces/aww_yeah.jpg','aww_yeah.jpg');
-- INSERT INTO Meme VALUES(55, 'baby_godfather','../static/media/faces/baby_godfather.jpg','baby_godfather.jpg');
-- INSERT INTO Meme VALUES(56, 'baby_troll','../static/media/faces/baby_troll.jpg','baby_troll.jpg');
-- INSERT INTO Meme VALUES(57, 'bad_advice_cat','../static/media/faces/bad_advice_cat.jpg','bad_advice_cat.jpg');
-- INSERT INTO Meme VALUES(58, 'bad_luck_brian','../static/media/faces/bad_luck_brian.jpg','bad_luck_brian.jpg');
-- INSERT INTO Meme VALUES(59, 'bad_pokerface','../static/media/faces/bad_pokerface.jpg','bad_pokerface.jpg');
-- INSERT INTO Meme VALUES(60, 'bear_grylls','../static/media/faces/bear_grylls.jpg','bear_grylls.jpg');
-- INSERT INTO Meme VALUES(61, 'beard_guy','../static/media/faces/beard_guy.jpg','beard_guy.jpg');
-- INSERT INTO Meme VALUES(62, 'beer_guy','../static/media/faces/beer_guy.jpg','beer_guy.jpg');
-- INSERT INTO Meme VALUES(63, 'beng','../static/media/faces/beng.jpg','beng.jpg');
-- INSERT INTO Meme VALUES(64, 'big_smile','../static/media/faces/big_smile.jpg','big_smile.jpg');
-- INSERT INTO Meme VALUES(65, 'bill_oreilly','../static/media/faces/bill_oreilly.jpg','bill_oreilly.jpg');
-- INSERT INTO Meme VALUES(66, 'bitchslap','../static/media/faces/bitchslap.jpg','bitchslap.jpg');
-- INSERT INTO Meme VALUES(67, 'black_big_smile','../static/media/faces/black_big_smile.jpg','black_big_smile.jpg');
-- INSERT INTO Meme VALUES(68, 'black_concentrated','../static/media/faces/black_concentrated.jpg','black_concentrated.jpg');
-- INSERT INTO Meme VALUES(69, 'black_crying','../static/media/faces/black_crying.jpg','black_crying.jpg');
-- INSERT INTO Meme VALUES(70, 'black_dazed','../static/media/faces/black_dazed.jpg','black_dazed.jpg');
-- INSERT INTO Meme VALUES(71, 'black_determined','../static/media/faces/black_determined.jpg','black_determined.jpg');
-- INSERT INTO Meme VALUES(72, 'black_dude','../static/media/faces/black_dude.jpg','black_dude.jpg');
-- INSERT INTO Meme VALUES(73, 'black_dumbfounded','../static/media/faces/black_dumbfounded.jpg','black_dumbfounded.jpg');
-- INSERT INTO Meme VALUES(74, 'black_ewbte','../static/media/faces/black_ewbte.jpg','black_ewbte.jpg');
-- INSERT INTO Meme VALUES(75, 'black_excited','../static/media/faces/black_excited.jpg','black_excited.jpg');
-- INSERT INTO Meme VALUES(76, 'black_excited_bliss','../static/media/faces/black_excited_bliss.jpg','black_excited_bliss.jpg');
-- INSERT INTO Meme VALUES(77, 'black_excited_tears','../static/media/faces/black_excited_tears.jpg','black_excited_tears.jpg');
-- INSERT INTO Meme VALUES(78, 'black_facepalm','../static/media/faces/black_facepalm.jpg','black_facepalm.jpg');
-- INSERT INTO Meme VALUES(79, 'black_fake_smile','../static/media/faces/black_fake_smile.jpg','black_fake_smile.jpg');
-- INSERT INTO Meme VALUES(80, 'black_forever_alone','../static/media/faces/black_forever_alone.jpg','black_forever_alone.jpg');
-- INSERT INTO Meme VALUES(81, 'black_freddie','../static/media/faces/black_freddie.jpg','black_freddie.jpg');
-- INSERT INTO Meme VALUES(82, 'black_fuck_that_bitch','../static/media/faces/black_fuck_that_bitch.jpg','black_fuck_that_bitch.jpg');
-- INSERT INTO Meme VALUES(83, 'black_fuck_yeah','../static/media/faces/black_fuck_yeah.jpg','black_fuck_yeah.jpg');
-- INSERT INTO Meme VALUES(84, 'black_gasp','../static/media/faces/black_gasp.jpg','black_gasp.jpg');
-- INSERT INTO Meme VALUES(85, 'black_gasp2','../static/media/faces/black_gasp2.jpg','black_gasp2.jpg');
-- INSERT INTO Meme VALUES(86, 'black_guy_gun','../static/media/faces/black_guy_gun.jpg','black_guy_gun.jpg');
-- INSERT INTO Meme VALUES(87, 'black_happy','../static/media/faces/black_happy.jpg','black_happy.jpg');
-- INSERT INTO Meme VALUES(88, 'black_hmmm','../static/media/faces/black_hmmm.jpg','black_hmmm.jpg');
-- INSERT INTO Meme VALUES(89, 'black_i_wonder','../static/media/faces/black_i_wonder.jpg','black_i_wonder.jpg');
-- INSERT INTO Meme VALUES(90, 'black_ladystare','../static/media/faces/black_ladystare.jpg','black_ladystare.jpg');
-- INSERT INTO Meme VALUES(91, 'black_ladystare2','../static/media/faces/black_ladystare2.jpg','black_ladystare2.jpg');
-- INSERT INTO Meme VALUES(92, 'black_lean','../static/media/faces/black_lean.jpg','black_lean.jpg');
-- INSERT INTO Meme VALUES(93, 'black_lol','../static/media/faces/black_lol.jpg','black_lol.jpg');
-- INSERT INTO Meme VALUES(94, 'black_me_gusta','../static/media/faces/black_me_gusta.jpg','black_me_gusta.jpg');
-- INSERT INTO Meme VALUES(95, 'black_milk','../static/media/faces/black_milk.jpg','black_milk.jpg');
-- INSERT INTO Meme VALUES(96, 'black_normal','../static/media/faces/black_normal.jpg','black_normal.jpg');
-- INSERT INTO Meme VALUES(97, 'black_normal2','../static/media/faces/black_normal2.jpg','black_normal2.jpg');
-- INSERT INTO Meme VALUES(98, 'black_okay','../static/media/faces/black_okay.jpg','black_okay.jpg');
-- INSERT INTO Meme VALUES(99, 'black_omgrun','../static/media/faces/black_omgrun.jpg','black_omgrun.jpg');
-- INSERT INTO Meme VALUES(100, 'black_pfft','../static/media/faces/black_pfft.jpg','black_pfft.jpg');
-- INSERT INTO Meme VALUES(101, 'black_quite','../static/media/faces/black_quite.jpg','black_quite.jpg');
-- INSERT INTO Meme VALUES(102, 'black_rage','../static/media/faces/black_rage.jpg','black_rage.jpg');
-- INSERT INTO Meme VALUES(103, 'black_rage2','../static/media/faces/black_rage2.jpg','black_rage2.jpg');
-- INSERT INTO Meme VALUES(104, 'black_rage_canadian','../static/media/faces/black_rage_canadian.jpg','black_rage_canadian.jpg');
-- INSERT INTO Meme VALUES(105, 'black_rage_extreme','../static/media/faces/black_rage_extreme.jpg','black_rage_extreme.jpg');
-- INSERT INTO Meme VALUES(106, 'black_rage_extreme2','../static/media/faces/black_rage_extreme2.jpg','black_rage_extreme2.jpg');
-- INSERT INTO Meme VALUES(107, 'black_rage_foaming','../static/media/faces/black_rage_foaming.jpg','black_rage_foaming.jpg');
-- INSERT INTO Meme VALUES(108, 'black_rage_getting_pissed','../static/media/faces/black_rage_getting_pissed.jpg','black_rage_getting_pissed.jpg');
-- INSERT INTO Meme VALUES(109, 'black_rage_mad','../static/media/faces/black_rage_mad.jpg','black_rage_mad.jpg');
-- INSERT INTO Meme VALUES(110, 'black_rage_mad2','../static/media/faces/black_rage_mad2.jpg','black_rage_mad2.jpg');
-- INSERT INTO Meme VALUES(111, 'black_rage_quiet','../static/media/faces/black_rage_quiet.jpg','black_rage_quiet.jpg');
-- INSERT INTO Meme VALUES(112, 'black_rage_shaking','../static/media/faces/black_rage_shaking.jpg','black_rage_shaking.jpg');
-- INSERT INTO Meme VALUES(113, 'black_rage_super','../static/media/faces/black_rage_super.jpg','black_rage_super.jpg');
-- INSERT INTO Meme VALUES(114, 'black_really_determined','../static/media/faces/black_really_determined.jpg','black_really_determined.jpg');
-- INSERT INTO Meme VALUES(115, 'black_red_tongue','../static/media/faces/black_red_tongue.jpg','black_red_tongue.jpg');
-- INSERT INTO Meme VALUES(116, 'black_schlick','../static/media/faces/black_schlick.jpg','black_schlick.jpg');
-- INSERT INTO Meme VALUES(117, 'black_smile','../static/media/faces/black_smile.jpg','black_smile.jpg');
-- INSERT INTO Meme VALUES(118, 'black_sweet_tears','../static/media/faces/black_sweet_tears.jpg','black_sweet_tears.jpg');
-- INSERT INTO Meme VALUES(119, 'black_tongue_down','../static/media/faces/black_tongue_down.jpg','black_tongue_down.jpg');
-- INSERT INTO Meme VALUES(120, 'black_troll','../static/media/faces/black_troll.jpg','black_troll.jpg');
-- INSERT INTO Meme VALUES(121, 'black_troll_sad','../static/media/faces/black_troll_sad.jpg','black_troll_sad.jpg');
-- INSERT INTO Meme VALUES(122, 'black_what','../static/media/faces/black_what.jpg','black_what.jpg');
-- INSERT INTO Meme VALUES(123, 'black_why','../static/media/faces/black_why.jpg','black_why.jpg');
-- INSERT INTO Meme VALUES(124, 'black_why_no_hands','../static/media/faces/black_why_no_hands.jpg','black_why_no_hands.jpg');
-- INSERT INTO Meme VALUES(125, 'black_wut','../static/media/faces/black_wut.jpg','black_wut.jpg');
-- INSERT INTO Meme VALUES(126, 'blackhair','../static/media/faces/blackhair.jpg','blackhair.jpg');
-- INSERT INTO Meme VALUES(127, 'blackhair2','../static/media/faces/blackhair2.jpg','blackhair2.jpg');
-- INSERT INTO Meme VALUES(128, 'blackhair3','../static/media/faces/blackhair3.jpg','blackhair3.jpg');
-- INSERT INTO Meme VALUES(129, 'blankhair','../static/media/faces/blankhair.jpg','blankhair.jpg');
-- INSERT INTO Meme VALUES(130, 'blonde_big_smile','../static/media/faces/blonde_big_smile.jpg','blonde_big_smile.jpg');
-- INSERT INTO Meme VALUES(131, 'blonde_concentrated','../static/media/faces/blonde_concentrated.jpg','blonde_concentrated.jpg');
-- INSERT INTO Meme VALUES(132, 'blonde_crying','../static/media/faces/blonde_crying.jpg','blonde_crying.jpg');
-- INSERT INTO Meme VALUES(133, 'blonde_dazed','../static/media/faces/blonde_dazed.jpg','blonde_dazed.jpg');
-- INSERT INTO Meme VALUES(134, 'blonde_determined','../static/media/faces/blonde_determined.jpg','blonde_determined.jpg');
-- INSERT INTO Meme VALUES(135, 'blonde_dude','../static/media/faces/blonde_dude.jpg','blonde_dude.jpg');
-- INSERT INTO Meme VALUES(136, 'blonde_dumbfounded','../static/media/faces/blonde_dumbfounded.jpg','blonde_dumbfounded.jpg');
-- INSERT INTO Meme VALUES(137, 'blonde_ewbte','../static/media/faces/blonde_ewbte.jpg','blonde_ewbte.jpg');
-- INSERT INTO Meme VALUES(138, 'blonde_excited','../static/media/faces/blonde_excited.jpg','blonde_excited.jpg');
-- INSERT INTO Meme VALUES(139, 'blonde_excited_bliss','../static/media/faces/blonde_excited_bliss.jpg','blonde_excited_bliss.jpg');
-- INSERT INTO Meme VALUES(140, 'blonde_excited_tears','../static/media/faces/blonde_excited_tears.jpg','blonde_excited_tears.jpg');
-- INSERT INTO Meme VALUES(141, 'blonde_facepalm','../static/media/faces/blonde_facepalm.jpg','blonde_facepalm.jpg');
-- INSERT INTO Meme VALUES(142, 'blonde_fake_smile','../static/media/faces/blonde_fake_smile.jpg','blonde_fake_smile.jpg');
-- INSERT INTO Meme VALUES(143, 'blonde_forever_alone','../static/media/faces/blonde_forever_alone.jpg','blonde_forever_alone.jpg');
-- INSERT INTO Meme VALUES(144, 'blonde_freddie','../static/media/faces/blonde_freddie.jpg','blonde_freddie.jpg');
-- INSERT INTO Meme VALUES(145, 'blonde_fuck_that_bitch','../static/media/faces/blonde_fuck_that_bitch.jpg','blonde_fuck_that_bitch.jpg');
-- INSERT INTO Meme VALUES(146, 'blonde_fuck_yeah','../static/media/faces/blonde_fuck_yeah.jpg','blonde_fuck_yeah.jpg');
-- INSERT INTO Meme VALUES(147, 'blonde_gasp','../static/media/faces/blonde_gasp.jpg','blonde_gasp.jpg');
-- INSERT INTO Meme VALUES(148, 'blonde_gasp2','../static/media/faces/blonde_gasp2.jpg','blonde_gasp2.jpg');
-- INSERT INTO Meme VALUES(149, 'blonde_genius','../static/media/faces/blonde_genius.jpg','blonde_genius.jpg');
-- INSERT INTO Meme VALUES(150, 'blonde_happy','../static/media/faces/blonde_happy.jpg','blonde_happy.jpg');
-- INSERT INTO Meme VALUES(151, 'blonde_hmmm','../static/media/faces/blonde_hmmm.jpg','blonde_hmmm.jpg');
-- INSERT INTO Meme VALUES(152, 'blonde_i_wonder','../static/media/faces/blonde_i_wonder.jpg','blonde_i_wonder.jpg');
-- INSERT INTO Meme VALUES(153, 'blonde_ladystare','../static/media/faces/blonde_ladystare.jpg','blonde_ladystare.jpg');
-- INSERT INTO Meme VALUES(154, 'blonde_ladystare2','../static/media/faces/blonde_ladystare2.jpg','blonde_ladystare2.jpg');
-- INSERT INTO Meme VALUES(155, 'blonde_lean','../static/media/faces/blonde_lean.jpg','blonde_lean.jpg');
-- INSERT INTO Meme VALUES(156, 'blonde_lol','../static/media/faces/blonde_lol.jpg','blonde_lol.jpg');
-- INSERT INTO Meme VALUES(157, 'blonde_me_gusta','../static/media/faces/blonde_me_gusta.jpg','blonde_me_gusta.jpg');
-- INSERT INTO Meme VALUES(158, 'blonde_milk','../static/media/faces/blonde_milk.jpg','blonde_milk.jpg');
-- INSERT INTO Meme VALUES(159, 'blonde_normal','../static/media/faces/blonde_normal.jpg','blonde_normal.jpg');
-- INSERT INTO Meme VALUES(160, 'blonde_normal2','../static/media/faces/blonde_normal2.jpg','blonde_normal2.jpg');
-- INSERT INTO Meme VALUES(161, 'blonde_okay','../static/media/faces/blonde_okay.jpg','blonde_okay.jpg');
-- INSERT INTO Meme VALUES(162, 'blonde_omgrun','../static/media/faces/blonde_omgrun.jpg','blonde_omgrun.jpg');
-- INSERT INTO Meme VALUES(163, 'blonde_pfft','../static/media/faces/blonde_pfft.jpg','blonde_pfft.jpg');
-- INSERT INTO Meme VALUES(164, 'blonde_quite','../static/media/faces/blonde_quite.jpg','blonde_quite.jpg');
-- INSERT INTO Meme VALUES(165, 'blonde_rage','../static/media/faces/blonde_rage.jpg','blonde_rage.jpg');
-- INSERT INTO Meme VALUES(166, 'blonde_rage2','../static/media/faces/blonde_rage2.jpg','blonde_rage2.jpg');
-- INSERT INTO Meme VALUES(167, 'blonde_rage_canadian','../static/media/faces/blonde_rage_canadian.jpg','blonde_rage_canadian.jpg');
-- INSERT INTO Meme VALUES(168, 'blonde_rage_extreme','../static/media/faces/blonde_rage_extreme.jpg','blonde_rage_extreme.jpg');
-- INSERT INTO Meme VALUES(169, 'blonde_rage_extreme2','../static/media/faces/blonde_rage_extreme2.jpg','blonde_rage_extreme2.jpg');
-- INSERT INTO Meme VALUES(170, 'blonde_rage_foaming','../static/media/faces/blonde_rage_foaming.jpg','blonde_rage_foaming.jpg');
-- INSERT INTO Meme VALUES(171, 'blonde_rage_getting_pissed','../static/media/faces/blonde_rage_getting_pissed.jpg','blonde_rage_getting_pissed.jpg');
-- INSERT INTO Meme VALUES(172, 'blonde_rage_mad','../static/media/faces/blonde_rage_mad.jpg','blonde_rage_mad.jpg');
-- INSERT INTO Meme VALUES(173, 'blonde_rage_mad2','../static/media/faces/blonde_rage_mad2.jpg','blonde_rage_mad2.jpg');
-- INSERT INTO Meme VALUES(174, 'blonde_rage_quiet','../static/media/faces/blonde_rage_quiet.jpg','blonde_rage_quiet.jpg');
-- INSERT INTO Meme VALUES(175, 'blonde_rage_shaking','../static/media/faces/blonde_rage_shaking.jpg','blonde_rage_shaking.jpg');
-- INSERT INTO Meme VALUES(176, 'blonde_rage_super','../static/media/faces/blonde_rage_super.jpg','blonde_rage_super.jpg');
-- INSERT INTO Meme VALUES(177, 'blonde_really_determined','../static/media/faces/blonde_really_determined.jpg','blonde_really_determined.jpg');
-- INSERT INTO Meme VALUES(178, 'blonde_red_tongue','../static/media/faces/blonde_red_tongue.jpg','blonde_red_tongue.jpg');
-- INSERT INTO Meme VALUES(179, 'blonde_schlick','../static/media/faces/blonde_schlick.jpg','blonde_schlick.jpg');
-- INSERT INTO Meme VALUES(180, 'blonde_smile','../static/media/faces/blonde_smile.jpg','blonde_smile.jpg');
-- INSERT INTO Meme VALUES(181, 'blonde_sweet_tears','../static/media/faces/blonde_sweet_tears.jpg','blonde_sweet_tears.jpg');
-- INSERT INTO Meme VALUES(182, 'blonde_tongue_down','../static/media/faces/blonde_tongue_down.jpg','blonde_tongue_down.jpg');
-- INSERT INTO Meme VALUES(183, 'blonde_troll','../static/media/faces/blonde_troll.jpg','blonde_troll.jpg');
-- INSERT INTO Meme VALUES(184, 'blonde_troll_sad','../static/media/faces/blonde_troll_sad.jpg','blonde_troll_sad.jpg');
-- INSERT INTO Meme VALUES(185, 'blonde_what','../static/media/faces/blonde_what.jpg','blonde_what.jpg');
-- INSERT INTO Meme VALUES(186, 'blonde_why','../static/media/faces/blonde_why.jpg','blonde_why.jpg');
-- INSERT INTO Meme VALUES(187, 'blonde_why_no_hands','../static/media/faces/blonde_why_no_hands.jpg','blonde_why_no_hands.jpg');
-- INSERT INTO Meme VALUES(188, 'blonde_wut','../static/media/faces/blonde_wut.jpg','blonde_wut.jpg');
-- INSERT INTO Meme VALUES(189, 'blondehair','../static/media/faces/blondehair.jpg','blondehair.jpg');
-- INSERT INTO Meme VALUES(190, 'blue_y_u_no','../static/media/faces/blue_y_u_no.jpg','blue_y_u_no.jpg');
-- INSERT INTO Meme VALUES(191, 'blushing','../static/media/faces/blushing.jpg','blushing.jpg');
-- INSERT INTO Meme VALUES(192, 'boobs','../static/media/faces/boobs.jpg','boobs.jpg');
-- INSERT INTO Meme VALUES(193, 'brace_yourselves_x_is_coming','../static/media/faces/brace_yourselves_x_is_coming.jpg','brace_yourselves_x_is_coming.jpg');
-- INSERT INTO Meme VALUES(194, 'brad_pitt','../static/media/faces/brad_pitt.jpg','brad_pitt.jpg');
-- INSERT INTO Meme VALUES(195, 'brant_rules','../static/media/faces/brant_rules.jpg','brant_rules.jpg');
-- INSERT INTO Meme VALUES(196, 'broken_heart','../static/media/faces/broken_heart.jpg','broken_heart.jpg');
-- INSERT INTO Meme VALUES(197, 'brunette_big_smile','../static/media/faces/brunette_big_smile.jpg','brunette_big_smile.jpg');
-- INSERT INTO Meme VALUES(198, 'brunette_concentrated','../static/media/faces/brunette_concentrated.jpg','brunette_concentrated.jpg');
-- INSERT INTO Meme VALUES(199, 'brunette_crying','../static/media/faces/brunette_crying.jpg','brunette_crying.jpg');
-- INSERT INTO Meme VALUES(200, 'brunette_dazed','../static/media/faces/brunette_dazed.jpg','brunette_dazed.jpg');
-- INSERT INTO Meme VALUES(201, 'brunette_determined','../static/media/faces/brunette_determined.jpg','brunette_determined.jpg');
-- INSERT INTO Meme VALUES(202, 'brunette_dude','../static/media/faces/brunette_dude.jpg','brunette_dude.jpg');
-- INSERT INTO Meme VALUES(203, 'brunette_dumbfounded','../static/media/faces/brunette_dumbfounded.jpg','brunette_dumbfounded.jpg');
-- INSERT INTO Meme VALUES(204, 'brunette_ewbte','../static/media/faces/brunette_ewbte.jpg','brunette_ewbte.jpg');
-- INSERT INTO Meme VALUES(205, 'brunette_excited','../static/media/faces/brunette_excited.jpg','brunette_excited.jpg');
-- INSERT INTO Meme VALUES(206, 'brunette_excited_bliss','../static/media/faces/brunette_excited_bliss.jpg','brunette_excited_bliss.jpg');
-- INSERT INTO Meme VALUES(207, 'brunette_excited_tears','../static/media/faces/brunette_excited_tears.jpg','brunette_excited_tears.jpg');
-- INSERT INTO Meme VALUES(208, 'brunette_facepalm','../static/media/faces/brunette_facepalm.jpg','brunette_facepalm.jpg');
-- INSERT INTO Meme VALUES(209, 'brunette_fake_smile','../static/media/faces/brunette_fake_smile.jpg','brunette_fake_smile.jpg');
-- INSERT INTO Meme VALUES(210, 'brunette_forever_alone','../static/media/faces/brunette_forever_alone.jpg','brunette_forever_alone.jpg');
-- INSERT INTO Meme VALUES(211, 'brunette_freddie','../static/media/faces/brunette_freddie.jpg','brunette_freddie.jpg');
-- INSERT INTO Meme VALUES(212, 'brunette_fuck_that_bitch','../static/media/faces/brunette_fuck_that_bitch.jpg','brunette_fuck_that_bitch.jpg');
-- INSERT INTO Meme VALUES(213, 'brunette_fuck_yeah','../static/media/faces/brunette_fuck_yeah.jpg','brunette_fuck_yeah.jpg');
-- INSERT INTO Meme VALUES(214, 'brunette_gasp','../static/media/faces/brunette_gasp.jpg','brunette_gasp.jpg');
-- INSERT INTO Meme VALUES(215, 'brunette_gasp2','../static/media/faces/brunette_gasp2.jpg','brunette_gasp2.jpg');
-- INSERT INTO Meme VALUES(216, 'brunette_happy','../static/media/faces/brunette_happy.jpg','brunette_happy.jpg');
-- INSERT INTO Meme VALUES(217, 'brunette_hmmm','../static/media/faces/brunette_hmmm.jpg','brunette_hmmm.jpg');
-- INSERT INTO Meme VALUES(218, 'brunette_i_wonder','../static/media/faces/brunette_i_wonder.jpg','brunette_i_wonder.jpg');
-- INSERT INTO Meme VALUES(219, 'brunette_ladystare','../static/media/faces/brunette_ladystare.jpg','brunette_ladystare.jpg');
-- INSERT INTO Meme VALUES(220, 'brunette_ladystare2','../static/media/faces/brunette_ladystare2.jpg','brunette_ladystare2.jpg');
-- INSERT INTO Meme VALUES(221, 'brunette_lean','../static/media/faces/brunette_lean.jpg','brunette_lean.jpg');
-- INSERT INTO Meme VALUES(222, 'brunette_lol','../static/media/faces/brunette_lol.jpg','brunette_lol.jpg');
-- INSERT INTO Meme VALUES(223, 'brunette_me_gusta','../static/media/faces/brunette_me_gusta.jpg','brunette_me_gusta.jpg');
-- INSERT INTO Meme VALUES(224, 'brunette_milk','../static/media/faces/brunette_milk.jpg','brunette_milk.jpg');
-- INSERT INTO Meme VALUES(225, 'brunette_normal','../static/media/faces/brunette_normal.jpg','brunette_normal.jpg');
-- INSERT INTO Meme VALUES(226, 'brunette_normal2','../static/media/faces/brunette_normal2.jpg','brunette_normal2.jpg');
-- INSERT INTO Meme VALUES(227, 'brunette_okay','../static/media/faces/brunette_okay.jpg','brunette_okay.jpg');
-- INSERT INTO Meme VALUES(228, 'brunette_omgrun','../static/media/faces/brunette_omgrun.jpg','brunette_omgrun.jpg');
-- INSERT INTO Meme VALUES(229, 'brunette_pfft','../static/media/faces/brunette_pfft.jpg','brunette_pfft.jpg');
-- INSERT INTO Meme VALUES(230, 'brunette_quite','../static/media/faces/brunette_quite.jpg','brunette_quite.jpg');
-- INSERT INTO Meme VALUES(231, 'brunette_rage','../static/media/faces/brunette_rage.jpg','brunette_rage.jpg');
-- INSERT INTO Meme VALUES(232, 'brunette_rage2','../static/media/faces/brunette_rage2.jpg','brunette_rage2.jpg');
-- INSERT INTO Meme VALUES(233, 'brunette_rage_canadian','../static/media/faces/brunette_rage_canadian.jpg','brunette_rage_canadian.jpg');
-- INSERT INTO Meme VALUES(234, 'brunette_rage_extreme','../static/media/faces/brunette_rage_extreme.jpg','brunette_rage_extreme.jpg');
-- INSERT INTO Meme VALUES(235, 'brunette_rage_extreme2','../static/media/faces/brunette_rage_extreme2.jpg','brunette_rage_extreme2.jpg');
-- INSERT INTO Meme VALUES(236, 'brunette_rage_foaming','../static/media/faces/brunette_rage_foaming.jpg','brunette_rage_foaming.jpg');
-- INSERT INTO Meme VALUES(237, 'brunette_rage_getting_pissed','../static/media/faces/brunette_rage_getting_pissed.jpg','brunette_rage_getting_pissed.jpg');
-- INSERT INTO Meme VALUES(238, 'brunette_rage_mad','../static/media/faces/brunette_rage_mad.jpg','brunette_rage_mad.jpg');
-- INSERT INTO Meme VALUES(239, 'brunette_rage_mad2','../static/media/faces/brunette_rage_mad2.jpg','brunette_rage_mad2.jpg');
-- INSERT INTO Meme VALUES(240, 'brunette_rage_quiet','../static/media/faces/brunette_rage_quiet.jpg','brunette_rage_quiet.jpg');
-- INSERT INTO Meme VALUES(241, 'brunette_rage_shaking','../static/media/faces/brunette_rage_shaking.jpg','brunette_rage_shaking.jpg');
-- INSERT INTO Meme VALUES(242, 'brunette_really_determined','../static/media/faces/brunette_really_determined.jpg','brunette_really_determined.jpg');
-- INSERT INTO Meme VALUES(243, 'brunette_red_tongue','../static/media/faces/brunette_red_tongue.jpg','brunette_red_tongue.jpg');
-- INSERT INTO Meme VALUES(244, 'brunette_schlick','../static/media/faces/brunette_schlick.jpg','brunette_schlick.jpg');
-- INSERT INTO Meme VALUES(245, 'brunette_smile','../static/media/faces/brunette_smile.jpg','brunette_smile.jpg');
-- INSERT INTO Meme VALUES(246, 'brunette_sweet_tears','../static/media/faces/brunette_sweet_tears.jpg','brunette_sweet_tears.jpg');
-- INSERT INTO Meme VALUES(247, 'brunette_tongue_down','../static/media/faces/brunette_tongue_down.jpg','brunette_tongue_down.jpg');
-- INSERT INTO Meme VALUES(248, 'brunette_troll','../static/media/faces/brunette_troll.jpg','brunette_troll.jpg');
-- INSERT INTO Meme VALUES(249, 'brunette_troll_sad','../static/media/faces/brunette_troll_sad.jpg','brunette_troll_sad.jpg');
-- INSERT INTO Meme VALUES(250, 'brunette_what','../static/media/faces/brunette_what.jpg','brunette_what.jpg');
-- INSERT INTO Meme VALUES(251, 'brunette_why','../static/media/faces/brunette_why.jpg','brunette_why.jpg');
-- INSERT INTO Meme VALUES(252, 'brunette_why_no_hands','../static/media/faces/brunette_why_no_hands.jpg','brunette_why_no_hands.jpg');
-- INSERT INTO Meme VALUES(253, 'brunette_wut','../static/media/faces/brunette_wut.jpg','brunette_wut.jpg');
-- INSERT INTO Meme VALUES(254, 'brunettehair','../static/media/faces/brunettehair.jpg','brunettehair.jpg');
-- INSERT INTO Meme VALUES(255, 'business_cat','../static/media/faces/business_cat.jpg','business_cat.jpg');
-- INSERT INTO Meme VALUES(256, 'butthurt_dweller','../static/media/faces/butthurt_dweller.jpg','butthurt_dweller.jpg');
-- INSERT INTO Meme VALUES(257, 'canadian_rage','../static/media/faces/canadian_rage.jpg','canadian_rage.jpg');
-- INSERT INTO Meme VALUES(258, 'cat_chin','../static/media/faces/cat_chin.jpg','cat_chin.jpg');
-- INSERT INTO Meme VALUES(259, 'cat_cuteness_overload','../static/media/faces/cat_cuteness_overload.jpg','cat_cuteness_overload.jpg');
-- INSERT INTO Meme VALUES(260, 'cat_gasp','../static/media/faces/cat_gasp.jpg','cat_gasp.jpg');
-- INSERT INTO Meme VALUES(261, 'cereal_guy','../static/media/faces/cereal_guy.jpg','cereal_guy.jpg');
-- INSERT INTO Meme VALUES(262, 'cereal_guy_angry','../static/media/faces/cereal_guy_angry.jpg','cereal_guy_angry.jpg');
-- INSERT INTO Meme VALUES(263, 'cereal_guy_big_squint','../static/media/faces/cereal_guy_big_squint.jpg','cereal_guy_big_squint.jpg');
-- INSERT INTO Meme VALUES(264, 'cereal_guy_drink_sip','../static/media/faces/cereal_guy_drink_sip.jpg','cereal_guy_drink_sip.jpg');
-- INSERT INTO Meme VALUES(265, 'cereal_guy_original','../static/media/faces/cereal_guy_original.jpg','cereal_guy_original.jpg');
-- INSERT INTO Meme VALUES(266, 'cereal_guy_spitting','../static/media/faces/cereal_guy_spitting.jpg','cereal_guy_spitting.jpg');
-- INSERT INTO Meme VALUES(267, 'cereal_guy_squint','../static/media/faces/cereal_guy_squint.jpg','cereal_guy_squint.jpg');
-- INSERT INTO Meme VALUES(268, 'challenge_accepted','../static/media/faces/challenge_accepted.jpg','challenge_accepted.jpg');
-- INSERT INTO Meme VALUES(269, 'challenge_accepted_drunk','../static/media/faces/challenge_accepted_drunk.jpg','challenge_accepted_drunk.jpg');
-- INSERT INTO Meme VALUES(270, 'challenge_considered','../static/media/faces/challenge_considered.jpg','challenge_considered.jpg');
-- INSERT INTO Meme VALUES(271, 'challenge_denied','../static/media/faces/challenge_denied.jpg','challenge_denied.jpg');
-- INSERT INTO Meme VALUES(272, 'challenge_failed','../static/media/faces/challenge_failed.jpg','challenge_failed.jpg');
-- INSERT INTO Meme VALUES(273, 'chef_hat','../static/media/faces/chef_hat.jpg','chef_hat.jpg');
-- INSERT INTO Meme VALUES(274, 'chemistry_cat','../static/media/faces/chemistry_cat.jpg','chemistry_cat.jpg');
-- INSERT INTO Meme VALUES(275, 'chin_strapping','../static/media/faces/chin_strapping.jpg','chin_strapping.jpg');
-- INSERT INTO Meme VALUES(276, 'classic_rage','../static/media/faces/classic_rage.jpg','classic_rage.jpg');
-- INSERT INTO Meme VALUES(277, 'clean_everything','../static/media/faces/clean_everything.jpg','clean_everything.jpg');
-- INSERT INTO Meme VALUES(278, 'clever_girl','../static/media/faces/clever_girl.jpg','clever_girl.jpg');
-- INSERT INTO Meme VALUES(279, 'college_liberal','../static/media/faces/college_liberal.jpg','college_liberal.jpg');
-- INSERT INTO Meme VALUES(280, 'computer_slice','../static/media/faces/computer_slice.jpg','computer_slice.jpg');
-- INSERT INTO Meme VALUES(281, 'computer_stare','../static/media/faces/computer_stare.jpg','computer_stare.jpg');
-- INSERT INTO Meme VALUES(282, 'concentrate','../static/media/faces/concentrate.jpg','concentrate.jpg');
-- INSERT INTO Meme VALUES(283, 'concentrated','../static/media/faces/concentrated.jpg','concentrated.jpg');
-- INSERT INTO Meme VALUES(284, 'concentrated_teeth','../static/media/faces/concentrated_teeth.jpg','concentrated_teeth.jpg');
-- INSERT INTO Meme VALUES(285, 'conflicting_emotions','../static/media/faces/conflicting_emotions.jpg','conflicting_emotions.jpg');
-- INSERT INTO Meme VALUES(286, 'conspiracy_keanu','../static/media/faces/conspiracy_keanu.jpg','conspiracy_keanu.jpg');
-- INSERT INTO Meme VALUES(287, 'cook_fap','../static/media/faces/cook_fap.jpg','cook_fap.jpg');
-- INSERT INTO Meme VALUES(288, 'courage_wolf','../static/media/faces/courage_wolf.jpg','courage_wolf.jpg');
-- INSERT INTO Meme VALUES(289, 'crazy_rage','../static/media/faces/crazy_rage.jpg','crazy_rage.jpg');
-- INSERT INTO Meme VALUES(290, 'creepy_dark','../static/media/faces/creepy_dark.jpg','creepy_dark.jpg');
-- INSERT INTO Meme VALUES(291, 'creepy_glasses_guy','../static/media/faces/creepy_glasses_guy.jpg','creepy_glasses_guy.jpg');
-- INSERT INTO Meme VALUES(292, 'creepy_troll','../static/media/faces/creepy_troll.jpg','creepy_troll.jpg');
-- INSERT INTO Meme VALUES(293, 'cry_pc','../static/media/faces/cry_pc.jpg','cry_pc.jpg');
-- INSERT INTO Meme VALUES(294, 'crying','../static/media/faces/crying.jpg','crying.jpg');
-- INSERT INTO Meme VALUES(295, 'cute_kid','../static/media/faces/cute_kid.jpg','cute_kid.jpg');
-- INSERT INTO Meme VALUES(296, 'cute_little_kid','../static/media/faces/cute_little_kid.jpg','cute_little_kid.jpg');
-- INSERT INTO Meme VALUES(297, 'cuteness_overload','../static/media/faces/cuteness_overload.jpg','cuteness_overload.jpg');
-- INSERT INTO Meme VALUES(298, 'cuteness_overload_2','../static/media/faces/cuteness_overload_2.jpg','cuteness_overload_2.jpg');
-- INSERT INTO Meme VALUES(299, 'daily_lie','../static/media/faces/daily_lie.jpg','daily_lie.jpg');
-- INSERT INTO Meme VALUES(300, 'damn','../static/media/faces/damn.jpg','damn.jpg');
-- INSERT INTO Meme VALUES(301, 'dat_ash','../static/media/faces/dat_ash.jpg','dat_ash.jpg');
-- INSERT INTO Meme VALUES(302, 'dat_ass','../static/media/faces/dat_ass.jpg','dat_ass.jpg');
-- INSERT INTO Meme VALUES(303, 'dating_site_murderer','../static/media/faces/dating_site_murderer.jpg','dating_site_murderer.jpg');
-- INSERT INTO Meme VALUES(304, 'day_four','../static/media/faces/day_four.jpg','day_four.jpg');
-- INSERT INTO Meme VALUES(305, 'day_three','../static/media/faces/day_three.jpg','day_three.jpg');
-- INSERT INTO Meme VALUES(306, 'day_two','../static/media/faces/day_two.jpg','day_two.jpg');
-- INSERT INTO Meme VALUES(307, 'depression_dog','../static/media/faces/depression_dog.jpg','depression_dog.jpg');
-- INSERT INTO Meme VALUES(308, 'derp_gusta','../static/media/faces/derp_gusta.jpg','derp_gusta.jpg');
-- INSERT INTO Meme VALUES(309, 'Derp_Hitler','../static/media/faces/Derp_Hitler.jpg','Derp_Hitler.jpg');
-- INSERT INTO Meme VALUES(310, 'derpina','../static/media/faces/derpina.jpg','derpina.jpg');
-- INSERT INTO Meme VALUES(311, 'derpina_eyes_closed','../static/media/faces/derpina_eyes_closed.jpg','derpina_eyes_closed.jpg');
-- INSERT INTO Meme VALUES(312, 'desk_flip','../static/media/faces/desk_flip.jpg','desk_flip.jpg');
-- INSERT INTO Meme VALUES(313, 'devil','../static/media/faces/devil.jpg','devil.jpg');
-- INSERT INTO Meme VALUES(314, 'disaster_girl','../static/media/faces/disaster_girl.jpg','disaster_girl.jpg');
-- INSERT INTO Meme VALUES(315, 'dog_wetodd','../static/media/faces/dog_wetodd.jpg','dog_wetodd.jpg');
-- INSERT INTO Meme VALUES(316, 'dolan','../static/media/faces/dolan.jpg','dolan.jpg');
-- INSERT INTO Meme VALUES(317, 'double_facepalm','../static/media/faces/double_facepalm.jpg','double_facepalm.jpg');
-- INSERT INTO Meme VALUES(318, 'drinkin_coke','../static/media/faces/drinkin_coke.jpg','drinkin_coke.jpg');
-- INSERT INTO Meme VALUES(319, 'drunk_baby','../static/media/faces/drunk_baby.jpg','drunk_baby.jpg');
-- INSERT INTO Meme VALUES(320, 'duck_yeah','../static/media/faces/duck_yeah.jpg','duck_yeah.jpg');
-- INSERT INTO Meme VALUES(321, 'duckface','../static/media/faces/duckface.jpg','duckface.jpg');
-- INSERT INTO Meme VALUES(322, 'dude','../static/media/faces/dude.jpg','dude.jpg');
-- INSERT INTO Meme VALUES(323, 'dude_come_on','../static/media/faces/dude_come_on.jpg','dude_come_on.jpg');
-- INSERT INTO Meme VALUES(324, 'dwight_schrute','../static/media/faces/dwight_schrute.jpg','dwight_schrute.jpg');
-- INSERT INTO Meme VALUES(325, 'efl_troll_face','../static/media/faces/efl_troll_face.jpg','efl_troll_face.jpg');
-- INSERT INTO Meme VALUES(326, 'eight_hours_later','../static/media/faces/eight_hours_later.jpg','eight_hours_later.jpg');
-- INSERT INTO Meme VALUES(327, 'embrace_pc','../static/media/faces/embrace_pc.jpg','embrace_pc.jpg');
-- INSERT INTO Meme VALUES(328, 'epic_win','../static/media/faces/epic_win.jpg','epic_win.jpg');
-- INSERT INTO Meme VALUES(329, 'eventually','../static/media/faces/eventually.jpg','eventually.jpg');
-- INSERT INTO Meme VALUES(330, 'everything_is_beatiful','../static/media/faces/everything_is_beatiful.jpg','everything_is_beatiful.jpg');
-- INSERT INTO Meme VALUES(331, 'everything_went_better','../static/media/faces/everything_went_better.jpg','everything_went_better.jpg');
-- INSERT INTO Meme VALUES(332, 'evil_cows','../static/media/faces/evil_cows.jpg','evil_cows.jpg');
-- INSERT INTO Meme VALUES(333, 'evil_smile','../static/media/faces/evil_smile.jpg','evil_smile.jpg');
-- INSERT INTO Meme VALUES(334, 'eye_half_closed','../static/media/faces/eye_half_closed.jpg','eye_half_closed.jpg');
-- INSERT INTO Meme VALUES(335, 'eyebrow_look','../static/media/faces/eyebrow_look.jpg','eyebrow_look.jpg');
-- INSERT INTO Meme VALUES(336, 'fabulous','../static/media/faces/fabulous.jpg','fabulous.jpg');
-- INSERT INTO Meme VALUES(337, 'face_mustache','../static/media/faces/face_mustache.jpg','face_mustache.jpg');
-- INSERT INTO Meme VALUES(338, 'facepalm','../static/media/faces/facepalm.jpg','facepalm.jpg');
-- INSERT INTO Meme VALUES(339, 'facepalm_female','../static/media/faces/facepalm_female.jpg','facepalm_female.jpg');
-- INSERT INTO Meme VALUES(340, 'facepalm_picard','../static/media/faces/facepalm_picard.jpg','facepalm_picard.jpg');
-- INSERT INTO Meme VALUES(341, 'faces_together','../static/media/faces/faces_together.jpg','faces_together.jpg');
-- INSERT INTO Meme VALUES(342, 'fap','../static/media/faces/fap.jpg','fap.jpg');
-- INSERT INTO Meme VALUES(343, 'fap_accepted','../static/media/faces/fap_accepted.jpg','fap_accepted.jpg');
-- INSERT INTO Meme VALUES(344, 'fap_gentleman','../static/media/faces/fap_gentleman.jpg','fap_gentleman.jpg');
-- INSERT INTO Meme VALUES(345, 'fap_schlick_female','../static/media/faces/fap_schlick_female.jpg','fap_schlick_female.jpg');
-- INSERT INTO Meme VALUES(346, 'fap_scream','../static/media/faces/fap_scream.jpg','fap_scream.jpg');
-- INSERT INTO Meme VALUES(347, 'feel_like_a_ninja','../static/media/faces/feel_like_a_ninja.jpg','feel_like_a_ninja.jpg');
-- INSERT INTO Meme VALUES(348, 'feels_good_man','../static/media/faces/feels_good_man.jpg','feels_good_man.jpg');
-- INSERT INTO Meme VALUES(349, 'female_aww_yeah','../static/media/faces/female_aww_yeah.jpg','female_aww_yeah.jpg');
-- INSERT INTO Meme VALUES(350, 'female_rage','../static/media/faces/female_rage.jpg','female_rage.jpg');
-- INSERT INTO Meme VALUES(351, 'female_seriously_glasses','../static/media/faces/female_seriously_glasses.jpg','female_seriously_glasses.jpg');
-- INSERT INTO Meme VALUES(352, 'fffffffuuuuuuuuuuuu','../static/media/faces/fffffffuuuuuuuuuuuu.jpg','fffffffuuuuuuuuuuuu.jpg');
-- INSERT INTO Meme VALUES(353, 'first_world_problems','../static/media/faces/first_world_problems.jpg','first_world_problems.jpg');
-- INSERT INTO Meme VALUES(354, 'forever_a_gamer','../static/media/faces/forever_a_gamer.jpg','forever_a_gamer.jpg');
-- INSERT INTO Meme VALUES(355, 'forever_alone','../static/media/faces/forever_alone.jpg','forever_alone.jpg');
-- INSERT INTO Meme VALUES(356, 'forever_alone_clean','../static/media/faces/forever_alone_clean.jpg','forever_alone_clean.jpg');
-- INSERT INTO Meme VALUES(357, 'forever_alone_computer','../static/media/faces/forever_alone_computer.jpg','forever_alone_computer.jpg');
-- INSERT INTO Meme VALUES(358, 'forever_alone_face_only','../static/media/faces/forever_alone_face_only.jpg','forever_alone_face_only.jpg');
-- INSERT INTO Meme VALUES(359, 'forever_alone_happy','../static/media/faces/forever_alone_happy.jpg','forever_alone_happy.jpg');
-- INSERT INTO Meme VALUES(360, 'forever_alone_pirate','../static/media/faces/forever_alone_pirate.jpg','forever_alone_pirate.jpg');
-- INSERT INTO Meme VALUES(361, 'forever_alone_sad','../static/media/faces/forever_alone_sad.jpg','forever_alone_sad.jpg');
-- INSERT INTO Meme VALUES(362, 'forever_alone_together','../static/media/faces/forever_alone_together.jpg','forever_alone_together.jpg');
-- INSERT INTO Meme VALUES(363, 'foul_bachelor_frog','../static/media/faces/foul_bachelor_frog.jpg','foul_bachelor_frog.jpg');
-- INSERT INTO Meme VALUES(364, 'foul_bachelorette_frog','../static/media/faces/foul_bachelorette_frog.jpg','foul_bachelorette_frog.jpg');
-- INSERT INTO Meme VALUES(365, 'freddie_girl','../static/media/faces/freddie_girl.jpg','freddie_girl.jpg');
-- INSERT INTO Meme VALUES(366, 'freddie_mercury','../static/media/faces/freddie_mercury.jpg','freddie_mercury.jpg');
-- INSERT INTO Meme VALUES(367, 'french','../static/media/faces/french.jpg','french.jpg');
-- INSERT INTO Meme VALUES(368, 'frogman','../static/media/faces/frogman.jpg','frogman.jpg');
-- INSERT INTO Meme VALUES(369, 'frogman_happy','../static/media/faces/frogman_happy.jpg','frogman_happy.jpg');
-- INSERT INTO Meme VALUES(370, 'frogman_sad','../static/media/faces/frogman_sad.jpg','frogman_sad.jpg');
-- INSERT INTO Meme VALUES(371, 'frown','../static/media/faces/frown.jpg','frown.jpg');
-- INSERT INTO Meme VALUES(372, 'fsjal','../static/media/faces/fsjal.jpg','fsjal.jpg');
-- INSERT INTO Meme VALUES(373, 'fuck_that','../static/media/faces/fuck_that.jpg','fuck_that.jpg');
-- INSERT INTO Meme VALUES(374, 'fuck_that_bitch_yao_pff','../static/media/faces/fuck_that_bitch_yao_pff.jpg','fuck_that_bitch_yao_pff.jpg');
-- INSERT INTO Meme VALUES(375, 'fuck_that_shit_female','../static/media/faces/fuck_that_shit_female.jpg','fuck_that_shit_female.jpg');
-- INSERT INTO Meme VALUES(376, 'fuck_that_yao_ming','../static/media/faces/fuck_that_yao_ming.jpg','fuck_that_yao_ming.jpg');
-- INSERT INTO Meme VALUES(377, 'fuck_yeah','../static/media/faces/fuck_yeah.jpg','fuck_yeah.jpg');
-- INSERT INTO Meme VALUES(378, 'fuck_yeah_clean','../static/media/faces/fuck_yeah_clean.jpg','fuck_yeah_clean.jpg');
-- INSERT INTO Meme VALUES(379, 'fuck_yeah_close_enough','../static/media/faces/fuck_yeah_close_enough.jpg','fuck_yeah_close_enough.jpg');
-- INSERT INTO Meme VALUES(380, 'fuck_yeah_danny_trejo','../static/media/faces/fuck_yeah_danny_trejo.jpg','fuck_yeah_danny_trejo.jpg');
-- INSERT INTO Meme VALUES(381, 'fuck_yeah_melvin','../static/media/faces/fuck_yeah_melvin.jpg','fuck_yeah_melvin.jpg');
-- INSERT INTO Meme VALUES(382, 'fuck_yeah_smile','../static/media/faces/fuck_yeah_smile.jpg','fuck_yeah_smile.jpg');
-- INSERT INTO Meme VALUES(383, 'fuck_you','../static/media/faces/fuck_you.jpg','fuck_you.jpg');
-- INSERT INTO Meme VALUES(384, 'fus_ro_dah','../static/media/faces/fus_ro_dah.jpg','fus_ro_dah.jpg');
-- INSERT INTO Meme VALUES(385, 'futurama_fry','../static/media/faces/futurama_fry.jpg','futurama_fry.jpg');
-- INSERT INTO Meme VALUES(386, 'futurama_zoidberg','../static/media/faces/futurama_zoidberg.jpg','futurama_zoidberg.jpg');
-- INSERT INTO Meme VALUES(387, 'fuuu','../static/media/faces/fuuu.jpg','fuuu.jpg');
-- INSERT INTO Meme VALUES(388, 'fuuu_karma','../static/media/faces/fuuu_karma.jpg','fuuu_karma.jpg');
-- INSERT INTO Meme VALUES(389, 'gasp','../static/media/faces/gasp.jpg','gasp.jpg');
-- INSERT INTO Meme VALUES(390, 'gaspcat_with_glasses','../static/media/faces/gaspcat_with_glasses.jpg','gaspcat_with_glasses.jpg');
-- INSERT INTO Meme VALUES(391, 'gay','../static/media/faces/gay.jpg','gay.jpg');
-- INSERT INTO Meme VALUES(392, 'genius','../static/media/faces/genius.jpg','genius.jpg');
-- INSERT INTO Meme VALUES(393, 'gentleman_troll','../static/media/faces/gentleman_troll.jpg','gentleman_troll.jpg');
-- INSERT INTO Meme VALUES(394, 'gentlemen','../static/media/faces/gentlemen.jpg','gentlemen.jpg');
-- INSERT INTO Meme VALUES(395, 'glory_pc','../static/media/faces/glory_pc.jpg','glory_pc.jpg');
-- INSERT INTO Meme VALUES(396, 'go_fuck_yourself','../static/media/faces/go_fuck_yourself.jpg','go_fuck_yourself.jpg');
-- INSERT INTO Meme VALUES(397, 'good_guy_greg','../static/media/faces/good_guy_greg.jpg','good_guy_greg.jpg');
-- INSERT INTO Meme VALUES(398, 'good_troll','../static/media/faces/good_troll.jpg','good_troll.jpg');
-- INSERT INTO Meme VALUES(399, 'got_a_badass','../static/media/faces/got_a_badass.jpg','got_a_badass.jpg');
-- INSERT INTO Meme VALUES(400, 'got_a_badass_full','../static/media/faces/got_a_badass_full.jpg','got_a_badass_full.jpg');
-- INSERT INTO Meme VALUES(401, 'grandma','../static/media/faces/grandma.jpg','grandma.jpg');
-- INSERT INTO Meme VALUES(402, 'grandma_finds_the_internet','../static/media/faces/grandma_finds_the_internet.jpg','grandma_finds_the_internet.jpg');
-- INSERT INTO Meme VALUES(403, 'grin','../static/media/faces/grin.jpg','grin.jpg');
-- INSERT INTO Meme VALUES(404, 'grinch','../static/media/faces/grinch.jpg','grinch.jpg');
-- INSERT INTO Meme VALUES(405, 'gtfo','../static/media/faces/gtfo.jpg','gtfo.jpg');
-- INSERT INTO Meme VALUES(406, 'gtfo_clean','../static/media/faces/gtfo_clean.jpg','gtfo_clean.jpg');
-- INSERT INTO Meme VALUES(407, 'gtfo_smile','../static/media/faces/gtfo_smile.jpg','gtfo_smile.jpg');
-- INSERT INTO Meme VALUES(408, 'ha','../static/media/faces/ha.jpg','ha.jpg');
-- INSERT INTO Meme VALUES(409, 'hah_gay','../static/media/faces/hah_gay.jpg','hah_gay.jpg');
-- INSERT INTO Meme VALUES(410, 'happy_female','../static/media/faces/happy_female.jpg','happy_female.jpg');
-- INSERT INTO Meme VALUES(411, 'happy_smile','../static/media/faces/happy_smile.jpg','happy_smile.jpg');
-- INSERT INTO Meme VALUES(412, 'happy_smoking','../static/media/faces/happy_smoking.jpg','happy_smoking.jpg');
-- INSERT INTO Meme VALUES(413, 'happy_winter','../static/media/faces/happy_winter.jpg','happy_winter.jpg');
-- INSERT INTO Meme VALUES(414, 'happy_yes','../static/media/faces/happy_yes.jpg','happy_yes.jpg');
-- INSERT INTO Meme VALUES(415, 'hat_and_monocle','../static/media/faces/hat_and_monocle.jpg','hat_and_monocle.jpg');
-- INSERT INTO Meme VALUES(416, 'haters_gonna_hate','../static/media/faces/haters_gonna_hate.jpg','haters_gonna_hate.jpg');
-- INSERT INTO Meme VALUES(417, 'hawkward','../static/media/faces/hawkward.jpg','hawkward.jpg');
-- INSERT INTO Meme VALUES(418, 'he_he','../static/media/faces/he_he.jpg','he_he.jpg');
-- INSERT INTO Meme VALUES(419, 'headphones','../static/media/faces/headphones.jpg','headphones.jpg');
-- INSERT INTO Meme VALUES(420, 'helpful_tyler_durden','../static/media/faces/helpful_tyler_durden.jpg','helpful_tyler_durden.jpg');
-- INSERT INTO Meme VALUES(421, 'herp','../static/media/faces/herp.jpg','herp.jpg');
-- INSERT INTO Meme VALUES(422, 'herp_derp','../static/media/faces/herp_derp.jpg','herp_derp.jpg');
-- INSERT INTO Meme VALUES(423, 'hey','../static/media/faces/hey.jpg','hey.jpg');
-- INSERT INTO Meme VALUES(424, 'high','../static/media/faces/high.jpg','high.jpg');
-- INSERT INTO Meme VALUES(425, 'high_expectations_asian_father','../static/media/faces/high_expectations_asian_father.jpg','high_expectations_asian_father.jpg');
-- INSERT INTO Meme VALUES(426, 'hipster_glasses','../static/media/faces/hipster_glasses.jpg','hipster_glasses.jpg');
-- INSERT INTO Meme VALUES(427, 'hipster_kitty','../static/media/faces/hipster_kitty.jpg','hipster_kitty.jpg');
-- INSERT INTO Meme VALUES(428, 'hipsterglasses','../static/media/faces/hipsterglasses.jpg','hipsterglasses.jpg');
-- INSERT INTO Meme VALUES(429, 'hitler','../static/media/faces/hitler.jpg','hitler.jpg');
-- INSERT INTO Meme VALUES(430, 'hmmm','../static/media/faces/hmmm.jpg','hmmm.jpg');
-- INSERT INTO Meme VALUES(431, 'horror','../static/media/faces/horror.jpg','horror.jpg');
-- INSERT INTO Meme VALUES(432, 'hot_chick','../static/media/faces/hot_chick.jpg','hot_chick.jpg');
-- INSERT INTO Meme VALUES(433, 'huh','../static/media/faces/huh.jpg','huh.jpg');
-- INSERT INTO Meme VALUES(434, 'huhm','../static/media/faces/huhm.jpg','huhm.jpg');
-- INSERT INTO Meme VALUES(435, 'hurrr','../static/media/faces/hurrr.jpg','hurrr.jpg');
-- INSERT INTO Meme VALUES(436, 'hyper_troll','../static/media/faces/hyper_troll.jpg','hyper_troll.jpg');
-- INSERT INTO Meme VALUES(437, 'i_am_determined','../static/media/faces/i_am_determined.jpg','i_am_determined.jpg');
-- INSERT INTO Meme VALUES(438, 'i_feels_yah','../static/media/faces/i_feels_yah.jpg','i_feels_yah.jpg');
-- INSERT INTO Meme VALUES(439, 'i_know_what_you_did_there_clean','../static/media/faces/i_know_what_you_did_there_clean.jpg','i_know_what_you_did_there_clean.jpg');
-- INSERT INTO Meme VALUES(440, 'i_lied','../static/media/faces/i_lied.jpg','i_lied.jpg');
-- INSERT INTO Meme VALUES(441, 'i_lied_black','../static/media/faces/i_lied_black.jpg','i_lied_black.jpg');
-- INSERT INTO Meme VALUES(442, 'i_lied_light','../static/media/faces/i_lied_light.jpg','i_lied_light.jpg');
-- INSERT INTO Meme VALUES(443, 'i_regret_nothing','../static/media/faces/i_regret_nothing.jpg','i_regret_nothing.jpg');
-- INSERT INTO Meme VALUES(444, 'i_see_what_you_did_there','../static/media/faces/i_see_what_you_did_there.jpg','i_see_what_you_did_there.jpg');
-- INSERT INTO Meme VALUES(445, 'i_truthed','../static/media/faces/i_truthed.jpg','i_truthed.jpg');
-- INSERT INTO Meme VALUES(446, 'ich_mag_gusta','../static/media/faces/ich_mag_gusta.jpg','ich_mag_gusta.jpg');
-- INSERT INTO Meme VALUES(447, 'if_you_know_what_i_mean_mr_bean','../static/media/faces/if_you_know_what_i_mean_mr_bean.jpg','if_you_know_what_i_mean_mr_bean.jpg');
-- INSERT INTO Meme VALUES(448, 'if_you_know_what_i_mean_mr_bean_blank','../static/media/faces/if_you_know_what_i_mean_mr_bean_blank.jpg','if_you_know_what_i_mean_mr_bean_blank.jpg');
-- INSERT INTO Meme VALUES(449, 'im_watching_u','../static/media/faces/im_watching_u.jpg','im_watching_u.jpg');
-- INSERT INTO Meme VALUES(450, 'impossibru','../static/media/faces/impossibru.jpg','impossibru.jpg');
-- INSERT INTO Meme VALUES(451, 'indeed','../static/media/faces/indeed.jpg','indeed.jpg');
-- INSERT INTO Meme VALUES(452, 'inglip','../static/media/faces/inglip.jpg','inglip.jpg');
-- INSERT INTO Meme VALUES(453, 'inglip_full_body','../static/media/faces/inglip_full_body.jpg','inglip_full_body.jpg');
-- INSERT INTO Meme VALUES(454, 'inglip_full_body2','../static/media/faces/inglip_full_body2.jpg','inglip_full_body2.jpg');
-- INSERT INTO Meme VALUES(455, 'inglip_gropaga1','../static/media/faces/inglip_gropaga1.jpg','inglip_gropaga1.jpg');
-- INSERT INTO Meme VALUES(456, 'inglip_gropaga2','../static/media/faces/inglip_gropaga2.jpg','inglip_gropaga2.jpg');
-- INSERT INTO Meme VALUES(457, 'inglip_gropaga3','../static/media/faces/inglip_gropaga3.jpg','inglip_gropaga3.jpg');
-- INSERT INTO Meme VALUES(458, 'inglip_gropaga4','../static/media/faces/inglip_gropaga4.jpg','inglip_gropaga4.jpg');
-- INSERT INTO Meme VALUES(459, 'inglip_gropaga5','../static/media/faces/inglip_gropaga5.jpg','inglip_gropaga5.jpg');
-- INSERT INTO Meme VALUES(460, 'inglip_gropaga6','../static/media/faces/inglip_gropaga6.jpg','inglip_gropaga6.jpg');
-- INSERT INTO Meme VALUES(461, 'inglip_gropaga7','../static/media/faces/inglip_gropaga7.jpg','inglip_gropaga7.jpg');
-- INSERT INTO Meme VALUES(462, 'inglip_gropaga_amazed','../static/media/faces/inglip_gropaga_amazed.jpg','inglip_gropaga_amazed.jpg');
-- INSERT INTO Meme VALUES(463, 'inglip_gropaga_blank','../static/media/faces/inglip_gropaga_blank.jpg','inglip_gropaga_blank.jpg');
-- INSERT INTO Meme VALUES(464, 'inglip_gropaga_front','../static/media/faces/inglip_gropaga_front.jpg','inglip_gropaga_front.jpg');
-- INSERT INTO Meme VALUES(465, 'inglip_gropaga_okay','../static/media/faces/inglip_gropaga_okay.jpg','inglip_gropaga_okay.jpg');
-- INSERT INTO Meme VALUES(466, 'inglip_gropaga_why','../static/media/faces/inglip_gropaga_why.jpg','inglip_gropaga_why.jpg');
-- INSERT INTO Meme VALUES(467, 'inglip_hail_inglip','../static/media/faces/inglip_hail_inglip.jpg','inglip_hail_inglip.jpg');
-- INSERT INTO Meme VALUES(468, 'inglip_hood1','../static/media/faces/inglip_hood1.jpg','inglip_hood1.jpg');
-- INSERT INTO Meme VALUES(469, 'inglip_hood2','../static/media/faces/inglip_hood2.jpg','inglip_hood2.jpg');
-- INSERT INTO Meme VALUES(470, 'inglip_ircip','../static/media/faces/inglip_ircip.jpg','inglip_ircip.jpg');
-- INSERT INTO Meme VALUES(471, 'inglip_ready_to_battle','../static/media/faces/inglip_ready_to_battle.jpg','inglip_ready_to_battle.jpg');
-- INSERT INTO Meme VALUES(472, 'insanity_wolf','../static/media/faces/insanity_wolf.jpg','insanity_wolf.jpg');
-- INSERT INTO Meme VALUES(473, 'its_free','../static/media/faces/its_free.jpg','its_free.jpg');
-- INSERT INTO Meme VALUES(474, 'its_not_okay','../static/media/faces/its_not_okay.jpg','its_not_okay.jpg');
-- INSERT INTO Meme VALUES(475, 'its_something','../static/media/faces/its_something.jpg','its_something.jpg');
-- INSERT INTO Meme VALUES(476, 'jackie_chan','../static/media/faces/jackie_chan.jpg','jackie_chan.jpg');
-- INSERT INTO Meme VALUES(477, 'jealous_girl','../static/media/faces/jealous_girl.jpg','jealous_girl.jpg');
-- INSERT INTO Meme VALUES(478, 'jesus','../static/media/faces/jesus.jpg','jesus.jpg');
-- INSERT INTO Meme VALUES(479, 'jesus_dog','../static/media/faces/jesus_dog.jpg','jesus_dog.jpg');
-- INSERT INTO Meme VALUES(480, 'john_cena','../static/media/faces/john_cena.jpg','john_cena.jpg');
-- INSERT INTO Meme VALUES(481, 'joseph_ducreux','../static/media/faces/joseph_ducreux.jpg','joseph_ducreux.jpg');
-- INSERT INTO Meme VALUES(482, 'keyboard_break','../static/media/faces/keyboard_break.jpg','keyboard_break.jpg');
-- INSERT INTO Meme VALUES(483, 'killed_a_man','../static/media/faces/killed_a_man.jpg','killed_a_man.jpg');
-- INSERT INTO Meme VALUES(484, 'kitteh_smile','../static/media/faces/kitteh_smile.jpg','kitteh_smile.jpg');
-- INSERT INTO Meme VALUES(485, 'knife_self','../static/media/faces/knife_self.jpg','knife_self.jpg');
-- INSERT INTO Meme VALUES(486, 'knowthatfeel','../static/media/faces/knowthatfeel.jpg','knowthatfeel.jpg');
-- INSERT INTO Meme VALUES(487, 'koala_cant_believe','../static/media/faces/koala_cant_believe.jpg','koala_cant_believe.jpg');
-- INSERT INTO Meme VALUES(488, 'la_di_da','../static/media/faces/la_di_da.jpg','la_di_da.jpg');
-- INSERT INTO Meme VALUES(489, 'lame_pun_coon','../static/media/faces/lame_pun_coon.jpg','lame_pun_coon.jpg');
-- INSERT INTO Meme VALUES(490, 'later_1','../static/media/faces/later_1.jpg','later_1.jpg');
-- INSERT INTO Meme VALUES(491, 'later_2','../static/media/faces/later_2.jpg','later_2.jpg');
-- INSERT INTO Meme VALUES(492, 'later_that_evening','../static/media/faces/later_that_evening.jpg','later_that_evening.jpg');
-- INSERT INTO Meme VALUES(493, 'lazy_college_senior','../static/media/faces/lazy_college_senior.jpg','lazy_college_senior.jpg');
-- INSERT INTO Meme VALUES(494, 'le_fu','../static/media/faces/le_fu.jpg','le_fu.jpg');
-- INSERT INTO Meme VALUES(495, 'lesquee','../static/media/faces/lesquee.jpg','lesquee.jpg');
-- INSERT INTO Meme VALUES(496, 'like_a_liege','../static/media/faces/like_a_liege.jpg','like_a_liege.jpg');
-- INSERT INTO Meme VALUES(497, 'like_a_sir','../static/media/faces/like_a_sir.jpg','like_a_sir.jpg');
-- INSERT INTO Meme VALUES(498, 'little_kid','../static/media/faces/little_kid.jpg','little_kid.jpg');
-- INSERT INTO Meme VALUES(499, 'little_longer_than_a_few','../static/media/faces/little_longer_than_a_few.jpg','little_longer_than_a_few.jpg');
-- INSERT INTO Meme VALUES(500, 'lol','../static/media/faces/lol.jpg','lol.jpg');
-- INSERT INTO Meme VALUES(501, 'lol_crazy','../static/media/faces/lol_crazy.jpg','lol_crazy.jpg');
-- INSERT INTO Meme VALUES(502, 'long_long_neck_surprise','../static/media/faces/long_long_neck_surprise.jpg','long_long_neck_surprise.jpg');
-- INSERT INTO Meme VALUES(503, 'look_from_bottom','../static/media/faces/look_from_bottom.jpg','look_from_bottom.jpg');
-- INSERT INTO Meme VALUES(504, 'lovely_face','../static/media/faces/lovely_face.jpg','lovely_face.jpg');
-- INSERT INTO Meme VALUES(505, 'man_crying','../static/media/faces/man_crying.jpg','man_crying.jpg');
-- INSERT INTO Meme VALUES(506, 'me_culpa','../static/media/faces/me_culpa.jpg','me_culpa.jpg');
-- INSERT INTO Meme VALUES(507, 'me_gangsta','../static/media/faces/me_gangsta.jpg','me_gangsta.jpg');
-- INSERT INTO Meme VALUES(508, 'me_gusta','../static/media/faces/me_gusta.jpg','me_gusta.jpg');
-- INSERT INTO Meme VALUES(509, 'me_gusta_creepy','../static/media/faces/me_gusta_creepy.jpg','me_gusta_creepy.jpg');
-- INSERT INTO Meme VALUES(510, 'me_gusta_makeup','../static/media/faces/me_gusta_makeup.jpg','me_gusta_makeup.jpg');
-- INSERT INTO Meme VALUES(511, 'me_gusta_problemo','../static/media/faces/me_gusta_problemo.jpg','me_gusta_problemo.jpg');
-- INSERT INTO Meme VALUES(512, 'mega_rage','../static/media/faces/mega_rage.jpg','mega_rage.jpg');
-- INSERT INTO Meme VALUES(513, 'meh_cat','../static/media/faces/meh_cat.jpg','meh_cat.jpg');
-- INSERT INTO Meme VALUES(514, 'melvin','../static/media/faces/melvin.jpg','melvin.jpg');
-- INSERT INTO Meme VALUES(515, 'midnight','../static/media/faces/midnight.jpg','midnight.jpg');
-- INSERT INTO Meme VALUES(516, 'milk','../static/media/faces/milk.jpg','milk.jpg');
-- INSERT INTO Meme VALUES(517, 'monocle','../static/media/faces/monocle.jpg','monocle.jpg');
-- INSERT INTO Meme VALUES(518, 'mother_of_god','../static/media/faces/mother_of_god.jpg','mother_of_god.jpg');
-- INSERT INTO Meme VALUES(519, 'mother_of_god_annoyed','../static/media/faces/mother_of_god_annoyed.jpg','mother_of_god_annoyed.jpg');
-- INSERT INTO Meme VALUES(520, 'mother_of_gusta','../static/media/faces/mother_of_gusta.jpg','mother_of_gusta.jpg');
-- INSERT INTO Meme VALUES(521, 'mouth_wide_open','../static/media/faces/mouth_wide_open.jpg','mouth_wide_open.jpg');
-- INSERT INTO Meme VALUES(522, 'much_later','../static/media/faces/much_later.jpg','much_later.jpg');
-- INSERT INTO Meme VALUES(523, 'much_much_later','../static/media/faces/much_much_later.jpg','much_much_later.jpg');
-- INSERT INTO Meme VALUES(524, 'much_much_later_2','../static/media/faces/much_much_later_2.jpg','much_much_later_2.jpg');
-- INSERT INTO Meme VALUES(525, 'much_much_much_later','../static/media/faces/much_much_much_later.jpg','much_much_much_later.jpg');
-- INSERT INTO Meme VALUES(526, 'music_shit','../static/media/faces/music_shit.jpg','music_shit.jpg');
-- INSERT INTO Meme VALUES(527, 'musically_oblivious_8th_grader','../static/media/faces/musically_oblivious_8th_grader.jpg','musically_oblivious_8th_grader.jpg');
-- INSERT INTO Meme VALUES(528, 'must_resist','../static/media/faces/must_resist.jpg','must_resist.jpg');
-- INSERT INTO Meme VALUES(529, 'nerd','../static/media/faces/nerd.jpg','nerd.jpg');
-- INSERT INTO Meme VALUES(530, 'nerd_rainbow_puke','../static/media/faces/nerd_rainbow_puke.jpg','nerd_rainbow_puke.jpg');
-- INSERT INTO Meme VALUES(531, 'net_noob','../static/media/faces/net_noob.jpg','net_noob.jpg');
-- INSERT INTO Meme VALUES(532, 'never_alone','../static/media/faces/never_alone.jpg','never_alone.jpg');
-- INSERT INTO Meme VALUES(533, 'newspaper_guy','../static/media/faces/newspaper_guy.jpg','newspaper_guy.jpg');
-- INSERT INTO Meme VALUES(534, 'newspaper_guy_tear','../static/media/faces/newspaper_guy_tear.jpg','newspaper_guy_tear.jpg');
-- INSERT INTO Meme VALUES(535, 'next_day','../static/media/faces/next_day.jpg','next_day.jpg');
-- INSERT INTO Meme VALUES(536, 'next_day_2','../static/media/faces/next_day_2.jpg','next_day_2.jpg');
-- INSERT INTO Meme VALUES(537, 'no','../static/media/faces/no.jpg','no.jpg');
-- INSERT INTO Meme VALUES(538, 'no_me_gusta','../static/media/faces/no_me_gusta.jpg','no_me_gusta.jpg');
-- INSERT INTO Meme VALUES(539, 'nokia','../static/media/faces/nokia.jpg','nokia.jpg');
-- INSERT INTO Meme VALUES(540, 'NOPE','../static/media/faces/NOPE.jpg','NOPE.jpg');
-- INSERT INTO Meme VALUES(541, 'not_giving_a_fuck','../static/media/faces/not_giving_a_fuck.jpg','not_giving_a_fuck.jpg');
-- INSERT INTO Meme VALUES(542, 'not_okay_smile','../static/media/faces/not_okay_smile.jpg','not_okay_smile.jpg');
-- INSERT INTO Meme VALUES(543, 'not_sure_if_gusta','../static/media/faces/not_sure_if_gusta.jpg','not_sure_if_gusta.jpg');
-- INSERT INTO Meme VALUES(544, 'nothing_to_do_here','../static/media/faces/nothing_to_do_here.jpg','nothing_to_do_here.jpg');
-- INSERT INTO Meme VALUES(545, 'now_kiss','../static/media/faces/now_kiss.jpg','now_kiss.jpg');
-- INSERT INTO Meme VALUES(546, 'nuclear_rage','../static/media/faces/nuclear_rage.jpg','nuclear_rage.jpg');
-- INSERT INTO Meme VALUES(547, 'numb','../static/media/faces/numb.jpg','numb.jpg');
-- INSERT INTO Meme VALUES(548, 'obama_michelle_not_bad','../static/media/faces/obama_michelle_not_bad.jpg','obama_michelle_not_bad.jpg');
-- INSERT INTO Meme VALUES(549, 'obama_not_bad','../static/media/faces/obama_not_bad.jpg','obama_not_bad.jpg');
-- INSERT INTO Meme VALUES(550, 'objection','../static/media/faces/objection.jpg','objection.jpg');
-- INSERT INTO Meme VALUES(551, 'oh','../static/media/faces/oh.jpg','oh.jpg');
-- INSERT INTO Meme VALUES(552, 'oh_god','../static/media/faces/oh_god.jpg','oh_god.jpg');
-- INSERT INTO Meme VALUES(553, 'oh_god_why','../static/media/faces/oh_god_why.jpg','oh_god_why.jpg');
-- INSERT INTO Meme VALUES(554, 'oh_my_goodness','../static/media/faces/oh_my_goodness.jpg','oh_my_goodness.jpg');
-- INSERT INTO Meme VALUES(555, 'oh_no','../static/media/faces/oh_no.jpg','oh_no.jpg');
-- INSERT INTO Meme VALUES(556, 'oh_shit','../static/media/faces/oh_shit.jpg','oh_shit.jpg');
-- INSERT INTO Meme VALUES(557, 'oh_you','../static/media/faces/oh_you.jpg','oh_you.jpg');
-- INSERT INTO Meme VALUES(558, 'oh_you_so_cute','../static/media/faces/oh_you_so_cute.jpg','oh_you_so_cute.jpg');
-- INSERT INTO Meme VALUES(559, 'ohhh_yes','../static/media/faces/ohhh_yes.jpg','ohhh_yes.jpg');
-- INSERT INTO Meme VALUES(560, 'ohhh_yes_front','../static/media/faces/ohhh_yes_front.jpg','ohhh_yes_front.jpg');
-- INSERT INTO Meme VALUES(561, 'ohhhla','../static/media/faces/ohhhla.jpg','ohhhla.jpg');
-- INSERT INTO Meme VALUES(562, 'okay_clean','../static/media/faces/okay_clean.jpg','okay_clean.jpg');
-- INSERT INTO Meme VALUES(563, 'okay_gusta','../static/media/faces/okay_gusta.jpg','okay_gusta.jpg');
-- INSERT INTO Meme VALUES(564, 'okay_guy','../static/media/faces/okay_guy.jpg','okay_guy.jpg');
-- INSERT INTO Meme VALUES(565, 'okay_guy_backgrounded','../static/media/faces/okay_guy_backgrounded.jpg','okay_guy_backgrounded.jpg');
-- INSERT INTO Meme VALUES(566, 'okay_guy_no','../static/media/faces/okay_guy_no.jpg','okay_guy_no.jpg');
-- INSERT INTO Meme VALUES(567, 'okay_pfftch','../static/media/faces/okay_pfftch.jpg','okay_pfftch.jpg');
-- INSERT INTO Meme VALUES(568, 'omega_rage','../static/media/faces/omega_rage.jpg','omega_rage.jpg');
-- INSERT INTO Meme VALUES(569, 'omega_troll','../static/media/faces/omega_troll.jpg','omega_troll.jpg');
-- INSERT INTO Meme VALUES(570, 'omg_run','../static/media/faces/omg_run.jpg','omg_run.jpg');
-- INSERT INTO Meme VALUES(571, 'one_does_not_simply','../static/media/faces/one_does_not_simply.jpg','one_does_not_simply.jpg');
-- INSERT INTO Meme VALUES(572, 'one_eternity_later','../static/media/faces/one_eternity_later.jpg','one_eternity_later.jpg');
-- INSERT INTO Meme VALUES(573, 'one_hour_later','../static/media/faces/one_hour_later.jpg','one_hour_later.jpg');
-- INSERT INTO Meme VALUES(574, 'one_week_later','../static/media/faces/one_week_later.jpg','one_week_later.jpg');
-- INSERT INTO Meme VALUES(575, 'OperaHat','../static/media/faces/OperaHat.jpg','OperaHat.jpg');
-- INSERT INTO Meme VALUES(576, 'ordinary_muslim_man','../static/media/faces/ordinary_muslim_man.jpg','ordinary_muslim_man.jpg');
-- INSERT INTO Meme VALUES(577, 'original_rage','../static/media/faces/original_rage.jpg','original_rage.jpg');
-- INSERT INTO Meme VALUES(578, 'paranoid_parrot','../static/media/faces/paranoid_parrot.jpg','paranoid_parrot.jpg');
-- INSERT INTO Meme VALUES(579, 'pedobear','../static/media/faces/pedobear.jpg','pedobear.jpg');
-- INSERT INTO Meme VALUES(580, 'pedobear_backgrounded','../static/media/faces/pedobear_backgrounded.jpg','pedobear_backgrounded.jpg');
-- INSERT INTO Meme VALUES(581, 'pedobear_coming','../static/media/faces/pedobear_coming.jpg','pedobear_coming.jpg');
-- INSERT INTO Meme VALUES(582, 'pfffftch_2','../static/media/faces/pfffftch_2.jpg','pfffftch_2.jpg');
-- INSERT INTO Meme VALUES(583, 'pfffftch_3','../static/media/faces/pfffftch_3.jpg','pfffftch_3.jpg');
-- INSERT INTO Meme VALUES(584, 'pfffrrr','../static/media/faces/pfffrrr.jpg','pfffrrr.jpg');
-- INSERT INTO Meme VALUES(585, 'pfftch','../static/media/faces/pfftch.jpg','pfftch.jpg');
-- INSERT INTO Meme VALUES(586, 'pfftttch','../static/media/faces/pfftttch.jpg','pfftttch.jpg');
-- INSERT INTO Meme VALUES(587, 'philosoraptor','../static/media/faces/philosoraptor.jpg','philosoraptor.jpg');
-- INSERT INTO Meme VALUES(588, 'photogenic_guy','../static/media/faces/photogenic_guy.jpg','photogenic_guy.jpg');
-- INSERT INTO Meme VALUES(589, 'pick_up_boy','../static/media/faces/pick_up_boy.jpg','pick_up_boy.jpg');
-- INSERT INTO Meme VALUES(590, 'pick_up_boy_2','../static/media/faces/pick_up_boy_2.jpg','pick_up_boy_2.jpg');
-- INSERT INTO Meme VALUES(591, 'pick_up_boy_strikes','../static/media/faces/pick_up_boy_strikes.jpg','pick_up_boy_strikes.jpg');
-- INSERT INTO Meme VALUES(592, 'pick_up_boy_with_girl','../static/media/faces/pick_up_boy_with_girl.jpg','pick_up_boy_with_girl.jpg');
-- INSERT INTO Meme VALUES(593, 'pickup_line_panda','../static/media/faces/pickup_line_panda.jpg','pickup_line_panda.jpg');
-- INSERT INTO Meme VALUES(594, 'pig_rage','../static/media/faces/pig_rage.jpg','pig_rage.jpg');
-- INSERT INTO Meme VALUES(595, 'pirate','../static/media/faces/pirate.jpg','pirate.jpg');
-- INSERT INTO Meme VALUES(596, 'pleaseguy','../static/media/faces/pleaseguy.jpg','pleaseguy.jpg');
-- INSERT INTO Meme VALUES(597, 'poker_face_3','../static/media/faces/poker_face_3.jpg','poker_face_3.jpg');
-- INSERT INTO Meme VALUES(598, 'pokerface','../static/media/faces/pokerface.jpg','pokerface.jpg');
-- INSERT INTO Meme VALUES(599, 'pokerface_2','../static/media/faces/pokerface_2.jpg','pokerface_2.jpg');
-- INSERT INTO Meme VALUES(600, 'pokerface_2_clean','../static/media/faces/pokerface_2_clean.jpg','pokerface_2_clean.jpg');
-- INSERT INTO Meme VALUES(601, 'pokerface_clean','../static/media/faces/pokerface_clean.jpg','pokerface_clean.jpg');
-- INSERT INTO Meme VALUES(602, 'portal_rainbows','../static/media/faces/portal_rainbows.jpg','portal_rainbows.jpg');
-- INSERT INTO Meme VALUES(603, 'possibru','../static/media/faces/possibru.jpg','possibru.jpg');
-- INSERT INTO Meme VALUES(604, 'pretty_badass','../static/media/faces/pretty_badass.jpg','pretty_badass.jpg');
-- INSERT INTO Meme VALUES(605, 'problem_guy','../static/media/faces/problem_guy.jpg','problem_guy.jpg');
-- INSERT INTO Meme VALUES(606, 'problemo','../static/media/faces/problemo.jpg','problemo.jpg');
-- INSERT INTO Meme VALUES(607, 'provincial_man','../static/media/faces/provincial_man.jpg','provincial_man.jpg');
-- INSERT INTO Meme VALUES(608, 'psssyeah','../static/media/faces/psssyeah.jpg','psssyeah.jpg');
-- INSERT INTO Meme VALUES(609, 'questioning','../static/media/faces/questioning.jpg','questioning.jpg');
-- INSERT INTO Meme VALUES(610, 'quiet_rage','../static/media/faces/quiet_rage.jpg','quiet_rage.jpg');
-- INSERT INTO Meme VALUES(611, 'rage_cat','../static/media/faces/rage_cat.jpg','rage_cat.jpg');
-- INSERT INTO Meme VALUES(612, 'rage_eyes','../static/media/faces/rage_eyes.jpg','rage_eyes.jpg');
-- INSERT INTO Meme VALUES(613, 'rage_fu','../static/media/faces/rage_fu.jpg','rage_fu.jpg');
-- INSERT INTO Meme VALUES(614, 'rainbow_out_the_eyes','../static/media/faces/rainbow_out_the_eyes.jpg','rainbow_out_the_eyes.jpg');
-- INSERT INTO Meme VALUES(615, 'rainbow_puke','../static/media/faces/rainbow_puke.jpg','rainbow_puke.jpg');
-- INSERT INTO Meme VALUES(616, 'reaction_guy','../static/media/faces/reaction_guy.jpg','reaction_guy.jpg');
-- INSERT INTO Meme VALUES(617, 'real_life','../static/media/faces/real_life.jpg','real_life.jpg');
-- INSERT INTO Meme VALUES(618, 'realism_troll','../static/media/faces/realism_troll.jpg','realism_troll.jpg');
-- INSERT INTO Meme VALUES(619, 'red_big_smile','../static/media/faces/red_big_smile.jpg','red_big_smile.jpg');
-- INSERT INTO Meme VALUES(620, 'red_concentrated','../static/media/faces/red_concentrated.jpg','red_concentrated.jpg');
-- INSERT INTO Meme VALUES(621, 'red_crying','../static/media/faces/red_crying.jpg','red_crying.jpg');
-- INSERT INTO Meme VALUES(622, 'red_dazed','../static/media/faces/red_dazed.jpg','red_dazed.jpg');
-- INSERT INTO Meme VALUES(623, 'red_determined','../static/media/faces/red_determined.jpg','red_determined.jpg');
-- INSERT INTO Meme VALUES(624, 'red_dude','../static/media/faces/red_dude.jpg','red_dude.jpg');
-- INSERT INTO Meme VALUES(625, 'red_dumbfounded','../static/media/faces/red_dumbfounded.jpg','red_dumbfounded.jpg');
-- INSERT INTO Meme VALUES(626, 'red_ewbte','../static/media/faces/red_ewbte.jpg','red_ewbte.jpg');
-- INSERT INTO Meme VALUES(627, 'red_excited','../static/media/faces/red_excited.jpg','red_excited.jpg');
-- INSERT INTO Meme VALUES(628, 'red_excited_bliss','../static/media/faces/red_excited_bliss.jpg','red_excited_bliss.jpg');
-- INSERT INTO Meme VALUES(629, 'red_excited_tears','../static/media/faces/red_excited_tears.jpg','red_excited_tears.jpg');
-- INSERT INTO Meme VALUES(630, 'red_facepalm','../static/media/faces/red_facepalm.jpg','red_facepalm.jpg');
-- INSERT INTO Meme VALUES(631, 'red_fake_smile','../static/media/faces/red_fake_smile.jpg','red_fake_smile.jpg');
-- INSERT INTO Meme VALUES(632, 'red_forever_alone','../static/media/faces/red_forever_alone.jpg','red_forever_alone.jpg');
-- INSERT INTO Meme VALUES(633, 'red_freddie','../static/media/faces/red_freddie.jpg','red_freddie.jpg');
-- INSERT INTO Meme VALUES(634, 'red_fuck_that_bitch','../static/media/faces/red_fuck_that_bitch.jpg','red_fuck_that_bitch.jpg');
-- INSERT INTO Meme VALUES(635, 'red_fuck_yeah','../static/media/faces/red_fuck_yeah.jpg','red_fuck_yeah.jpg');
-- INSERT INTO Meme VALUES(636, 'red_gasp','../static/media/faces/red_gasp.jpg','red_gasp.jpg');
-- INSERT INTO Meme VALUES(637, 'red_gasp2','../static/media/faces/red_gasp2.jpg','red_gasp2.jpg');
-- INSERT INTO Meme VALUES(638, 'red_happy','../static/media/faces/red_happy.jpg','red_happy.jpg');
-- INSERT INTO Meme VALUES(639, 'red_hmmm','../static/media/faces/red_hmmm.jpg','red_hmmm.jpg');
-- INSERT INTO Meme VALUES(640, 'red_i_wonder','../static/media/faces/red_i_wonder.jpg','red_i_wonder.jpg');
-- INSERT INTO Meme VALUES(641, 'red_ladystare','../static/media/faces/red_ladystare.jpg','red_ladystare.jpg');
-- INSERT INTO Meme VALUES(642, 'red_ladystare2','../static/media/faces/red_ladystare2.jpg','red_ladystare2.jpg');
-- INSERT INTO Meme VALUES(643, 'red_lean','../static/media/faces/red_lean.jpg','red_lean.jpg');
-- INSERT INTO Meme VALUES(644, 'red_lol','../static/media/faces/red_lol.jpg','red_lol.jpg');
-- INSERT INTO Meme VALUES(645, 'red_me_gusta','../static/media/faces/red_me_gusta.jpg','red_me_gusta.jpg');
-- INSERT INTO Meme VALUES(646, 'red_milk','../static/media/faces/red_milk.jpg','red_milk.jpg');
-- INSERT INTO Meme VALUES(647, 'red_normal','../static/media/faces/red_normal.jpg','red_normal.jpg');
-- INSERT INTO Meme VALUES(648, 'red_normal2','../static/media/faces/red_normal2.jpg','red_normal2.jpg');
-- INSERT INTO Meme VALUES(649, 'red_okay','../static/media/faces/red_okay.jpg','red_okay.jpg');
-- INSERT INTO Meme VALUES(650, 'red_omgrun','../static/media/faces/red_omgrun.jpg','red_omgrun.jpg');
-- INSERT INTO Meme VALUES(651, 'red_pfft','../static/media/faces/red_pfft.jpg','red_pfft.jpg');
-- INSERT INTO Meme VALUES(652, 'red_quite','../static/media/faces/red_quite.jpg','red_quite.jpg');
-- INSERT INTO Meme VALUES(653, 'red_rage','../static/media/faces/red_rage.jpg','red_rage.jpg');
-- INSERT INTO Meme VALUES(654, 'red_rage2','../static/media/faces/red_rage2.jpg','red_rage2.jpg');
-- INSERT INTO Meme VALUES(655, 'red_rage_canadian','../static/media/faces/red_rage_canadian.jpg','red_rage_canadian.jpg');
-- INSERT INTO Meme VALUES(656, 'red_rage_extreme','../static/media/faces/red_rage_extreme.jpg','red_rage_extreme.jpg');
-- INSERT INTO Meme VALUES(657, 'red_rage_extreme2','../static/media/faces/red_rage_extreme2.jpg','red_rage_extreme2.jpg');
-- INSERT INTO Meme VALUES(658, 'red_rage_foaming','../static/media/faces/red_rage_foaming.jpg','red_rage_foaming.jpg');
-- INSERT INTO Meme VALUES(659, 'red_rage_getting_pissed','../static/media/faces/red_rage_getting_pissed.jpg','red_rage_getting_pissed.jpg');
-- INSERT INTO Meme VALUES(660, 'red_rage_mad','../static/media/faces/red_rage_mad.jpg','red_rage_mad.jpg');
-- INSERT INTO Meme VALUES(661, 'red_rage_mad2','../static/media/faces/red_rage_mad2.jpg','red_rage_mad2.jpg');
-- INSERT INTO Meme VALUES(662, 'red_rage_quiet','../static/media/faces/red_rage_quiet.jpg','red_rage_quiet.jpg');
-- INSERT INTO Meme VALUES(663, 'red_rage_shaking','../static/media/faces/red_rage_shaking.jpg','red_rage_shaking.jpg');
-- INSERT INTO Meme VALUES(664, 'red_rage_super','../static/media/faces/red_rage_super.jpg','red_rage_super.jpg');
-- INSERT INTO Meme VALUES(665, 'red_really_determined','../static/media/faces/red_really_determined.jpg','red_really_determined.jpg');
-- INSERT INTO Meme VALUES(666, 'red_red_tongue','../static/media/faces/red_red_tongue.jpg','red_red_tongue.jpg');
-- INSERT INTO Meme VALUES(667, 'red_schlick','../static/media/faces/red_schlick.jpg','red_schlick.jpg');
-- INSERT INTO Meme VALUES(668, 'red_smile','../static/media/faces/red_smile.jpg','red_smile.jpg');
-- INSERT INTO Meme VALUES(669, 'red_sweet_tears','../static/media/faces/red_sweet_tears.jpg','red_sweet_tears.jpg');
-- INSERT INTO Meme VALUES(670, 'red_tongue','../static/media/faces/red_tongue.jpg','red_tongue.jpg');
-- INSERT INTO Meme VALUES(671, 'red_tongue_down','../static/media/faces/red_tongue_down.jpg','red_tongue_down.jpg');
-- INSERT INTO Meme VALUES(672, 'red_troll','../static/media/faces/red_troll.jpg','red_troll.jpg');
-- INSERT INTO Meme VALUES(673, 'red_troll_sad','../static/media/faces/red_troll_sad.jpg','red_troll_sad.jpg');
-- INSERT INTO Meme VALUES(674, 'red_what','../static/media/faces/red_what.jpg','red_what.jpg');
-- INSERT INTO Meme VALUES(675, 'red_why','../static/media/faces/red_why.jpg','red_why.jpg');
-- INSERT INTO Meme VALUES(676, 'red_why_no_hands','../static/media/faces/red_why_no_hands.jpg','red_why_no_hands.jpg');
-- INSERT INTO Meme VALUES(677, 'red_wut','../static/media/faces/red_wut.jpg','red_wut.jpg');
-- INSERT INTO Meme VALUES(678, 'RedditAlien','../static/media/faces/RedditAlien.jpg','RedditAlien.jpg');
-- INSERT INTO Meme VALUES(679, 'RedditAlien2','../static/media/faces/RedditAlien2.jpg','RedditAlien2.jpg');
-- INSERT INTO Meme VALUES(680, 'RedditAlien3','../static/media/faces/RedditAlien3.jpg','RedditAlien3.jpg');
-- INSERT INTO Meme VALUES(681, 'redditors_wife','../static/media/faces/redditors_wife.jpg','redditors_wife.jpg');
-- INSERT INTO Meme VALUES(682, 'redhair','../static/media/faces/redhair.jpg','redhair.jpg');
-- INSERT INTO Meme VALUES(683, 'redneck_randal','../static/media/faces/redneck_randal.jpg','redneck_randal.jpg');
-- INSERT INTO Meme VALUES(684, 'ridiciously_photogenic_metalhead','../static/media/faces/ridiciously_photogenic_metalhead.jpg','ridiciously_photogenic_metalhead.jpg');
-- INSERT INTO Meme VALUES(685, 'rly_clean_everything','../static/media/faces/rly_clean_everything.jpg','rly_clean_everything.jpg');
-- INSERT INTO Meme VALUES(686, 'royal_wedding_girl','../static/media/faces/royal_wedding_girl.jpg','royal_wedding_girl.jpg');
-- INSERT INTO Meme VALUES(687, 'sad','../static/media/faces/sad.jpg','sad.jpg');
-- INSERT INTO Meme VALUES(688, 'sad_computer','../static/media/faces/sad_computer.jpg','sad_computer.jpg');
-- INSERT INTO Meme VALUES(689, 'sad_melvin','../static/media/faces/sad_melvin.jpg','sad_melvin.jpg');
-- INSERT INTO Meme VALUES(690, 'sad_shadow','../static/media/faces/sad_shadow.jpg','sad_shadow.jpg');
-- INSERT INTO Meme VALUES(691, 'sad_sitting','../static/media/faces/sad_sitting.jpg','sad_sitting.jpg');
-- INSERT INTO Meme VALUES(692, 'sad_troll_face','../static/media/faces/sad_troll_face.jpg','sad_troll_face.jpg');
-- INSERT INTO Meme VALUES(693, 'sad_why','../static/media/faces/sad_why.jpg','sad_why.jpg');
-- INSERT INTO Meme VALUES(694, 'sarcasm','../static/media/faces/sarcasm.jpg','sarcasm.jpg');
-- INSERT INTO Meme VALUES(695, 'scared_yao','../static/media/faces/scared_yao.jpg','scared_yao.jpg');
-- INSERT INTO Meme VALUES(696, 'scroll_scroll','../static/media/faces/scroll_scroll.jpg','scroll_scroll.jpg');
-- INSERT INTO Meme VALUES(697, 'scumbag_brain','../static/media/faces/scumbag_brain.jpg','scumbag_brain.jpg');
-- INSERT INTO Meme VALUES(698, 'scumbag_cap','../static/media/faces/scumbag_cap.jpg','scumbag_cap.jpg');
-- INSERT INTO Meme VALUES(699, 'scumbag_steve','../static/media/faces/scumbag_steve.jpg','scumbag_steve.jpg');
-- INSERT INTO Meme VALUES(700, 'serious_not_okay','../static/media/faces/serious_not_okay.jpg','serious_not_okay.jpg');
-- INSERT INTO Meme VALUES(701, 'seriously','../static/media/faces/seriously.jpg','seriously.jpg');
-- INSERT INTO Meme VALUES(702, 'several_days_later','../static/media/faces/several_days_later.jpg','several_days_later.jpg');
-- INSERT INTO Meme VALUES(703, 'sexual_frustration','../static/media/faces/sexual_frustration.jpg','sexual_frustration.jpg');
-- INSERT INTO Meme VALUES(704, 'sexually_oblivious_rhino','../static/media/faces/sexually_oblivious_rhino.jpg','sexually_oblivious_rhino.jpg');
-- INSERT INTO Meme VALUES(705, 'sheltering_suburban_mom','../static/media/faces/sheltering_suburban_mom.jpg','sheltering_suburban_mom.jpg');
-- INSERT INTO Meme VALUES(706, 'shocked','../static/media/faces/shocked.jpg','shocked.jpg');
-- INSERT INTO Meme VALUES(707, 'shrug','../static/media/faces/shrug.jpg','shrug.jpg');
-- INSERT INTO Meme VALUES(708, 'side_mouth','../static/media/faces/side_mouth.jpg','side_mouth.jpg');
-- INSERT INTO Meme VALUES(709, 'sincere_troll','../static/media/faces/sincere_troll.jpg','sincere_troll.jpg');
-- INSERT INTO Meme VALUES(710, 'six_hours_later','../static/media/faces/six_hours_later.jpg','six_hours_later.jpg');
-- INSERT INTO Meme VALUES(711, 'six_hours_later_2','../static/media/faces/six_hours_later_2.jpg','six_hours_later_2.jpg');
-- INSERT INTO Meme VALUES(712, 'slowpoke','../static/media/faces/slowpoke.jpg','slowpoke.jpg');
-- INSERT INTO Meme VALUES(713, 'smashing','../static/media/faces/smashing.jpg','smashing.jpg');
-- INSERT INTO Meme VALUES(714, 'so_close_freddie_mercury','../static/media/faces/so_close_freddie_mercury.jpg','so_close_freddie_mercury.jpg');
-- INSERT INTO Meme VALUES(715, 'so_hardcore','../static/media/faces/so_hardcore.jpg','so_hardcore.jpg');
-- INSERT INTO Meme VALUES(716, 'so_much_win','../static/media/faces/so_much_win.jpg','so_much_win.jpg');
-- INSERT INTO Meme VALUES(717, 'so_there','../static/media/faces/so_there.jpg','so_there.jpg');
-- INSERT INTO Meme VALUES(718, 'so_there_close','../static/media/faces/so_there_close.jpg','so_there_close.jpg');
-- INSERT INTO Meme VALUES(719, 'socially_awesome_penguin','../static/media/faces/socially_awesome_penguin.jpg','socially_awesome_penguin.jpg');
-- INSERT INTO Meme VALUES(720, 'socially_awkward_penguin','../static/media/faces/socially_awkward_penguin.jpg','socially_awkward_penguin.jpg');
-- INSERT INTO Meme VALUES(721, 'something_to_do_here','../static/media/faces/something_to_do_here.jpg','something_to_do_here.jpg');
-- INSERT INTO Meme VALUES(722, 'son_i_am_disappoint','../static/media/faces/son_i_am_disappoint.jpg','son_i_am_disappoint.jpg');
-- INSERT INTO Meme VALUES(723, 'speech','../static/media/faces/speech.jpg','speech.jpg');
-- INSERT INTO Meme VALUES(724, 'speech2','../static/media/faces/speech2.jpg','speech2.jpg');
-- INSERT INTO Meme VALUES(725, 'speech3','../static/media/faces/speech3.jpg','speech3.jpg');
-- INSERT INTO Meme VALUES(726, 'speech4','../static/media/faces/speech4.jpg','speech4.jpg');
-- INSERT INTO Meme VALUES(727, 'speech5','../static/media/faces/speech5.jpg','speech5.jpg');
-- INSERT INTO Meme VALUES(728, 'speech6','../static/media/faces/speech6.jpg','speech6.jpg');
-- INSERT INTO Meme VALUES(729, 'spiderpman','../static/media/faces/spiderpman.jpg','spiderpman.jpg');
-- INSERT INTO Meme VALUES(730, 'steamboat_troll','../static/media/faces/steamboat_troll.jpg','steamboat_troll.jpg');
-- INSERT INTO Meme VALUES(731, 'stoned_what','../static/media/faces/stoned_what.jpg','stoned_what.jpg');
-- INSERT INTO Meme VALUES(732, 'stoner_dog','../static/media/faces/stoner_dog.jpg','stoner_dog.jpg');
-- INSERT INTO Meme VALUES(733, 'stop_it','../static/media/faces/stop_it.jpg','stop_it.jpg');
-- INSERT INTO Meme VALUES(734, 'stop_it_angry','../static/media/faces/stop_it_angry.jpg','stop_it_angry.jpg');
-- INSERT INTO Meme VALUES(735, 'success','../static/media/faces/success.jpg','success.jpg');
-- INSERT INTO Meme VALUES(736, 'success_kid','../static/media/faces/success_kid.jpg','success_kid.jpg');
-- INSERT INTO Meme VALUES(737, 'successful_black_man','../static/media/faces/successful_black_man.jpg','successful_black_man.jpg');
-- INSERT INTO Meme VALUES(738, 'sunny_student','../static/media/faces/sunny_student.jpg','sunny_student.jpg');
-- INSERT INTO Meme VALUES(739, 'super_rage','../static/media/faces/super_rage.jpg','super_rage.jpg');
-- INSERT INTO Meme VALUES(740, 'surprised_Commissar','../static/media/faces/surprised_Commissar.jpg','surprised_Commissar.jpg');
-- INSERT INTO Meme VALUES(741, 'surprised_gasp','../static/media/faces/surprised_gasp.jpg','surprised_gasp.jpg');
-- INSERT INTO Meme VALUES(742, 'surprised_great_scott','../static/media/faces/surprised_great_scott.jpg','surprised_great_scott.jpg');
-- INSERT INTO Meme VALUES(743, 'surprised_kid','../static/media/faces/surprised_kid.jpg','surprised_kid.jpg');
-- INSERT INTO Meme VALUES(744, 'surprised_long_neck_surprise','../static/media/faces/surprised_long_neck_surprise.jpg','surprised_long_neck_surprise.jpg');
-- INSERT INTO Meme VALUES(745, 'surprised_mother_of_god','../static/media/faces/surprised_mother_of_god.jpg','surprised_mother_of_god.jpg');
-- INSERT INTO Meme VALUES(746, 'surprised_oh_fuck_no','../static/media/faces/surprised_oh_fuck_no.jpg','surprised_oh_fuck_no.jpg');
-- INSERT INTO Meme VALUES(747, 'surprised_open_mouth','../static/media/faces/surprised_open_mouth.jpg','surprised_open_mouth.jpg');
-- INSERT INTO Meme VALUES(748, 'surprised_rage_clean','../static/media/faces/surprised_rage_clean.jpg','surprised_rage_clean.jpg');
-- INSERT INTO Meme VALUES(749, 'surprised_wait','../static/media/faces/surprised_wait.jpg','surprised_wait.jpg');
-- INSERT INTO Meme VALUES(750, 'surprised_wide_open','../static/media/faces/surprised_wide_open.jpg','surprised_wide_open.jpg');
-- INSERT INTO Meme VALUES(751, 'suspicious','../static/media/faces/suspicious.jpg','suspicious.jpg');
-- INSERT INTO Meme VALUES(752, 'sweaty_concentrated','../static/media/faces/sweaty_concentrated.jpg','sweaty_concentrated.jpg');
-- INSERT INTO Meme VALUES(753, 'sweet_jesus_eyes_hanging_out','../static/media/faces/sweet_jesus_eyes_hanging_out.jpg','sweet_jesus_eyes_hanging_out.jpg');
-- INSERT INTO Meme VALUES(754, 'sweet_jesus_face','../static/media/faces/sweet_jesus_face.jpg','sweet_jesus_face.jpg');
-- INSERT INTO Meme VALUES(755, 'tears_in_the_eyes','../static/media/faces/tears_in_the_eyes.jpg','tears_in_the_eyes.jpg');
-- INSERT INTO Meme VALUES(756, 'tech_impaired_duck','../static/media/faces/tech_impaired_duck.jpg','tech_impaired_duck.jpg');
-- INSERT INTO Meme VALUES(757, 'thanks','../static/media/faces/thanks.jpg','thanks.jpg');
-- INSERT INTO Meme VALUES(758, 'that_is_suspicious','../static/media/faces/that_is_suspicious.jpg','that_is_suspicious.jpg');
-- INSERT INTO Meme VALUES(759, 'the_most_interesting_cat_in_the_world','../static/media/faces/the_most_interesting_cat_in_the_world.jpg','the_most_interesting_cat_in_the_world.jpg');
-- INSERT INTO Meme VALUES(760, 'the_most_interesting_man_in_the_world','../static/media/faces/the_most_interesting_man_in_the_world.jpg','the_most_interesting_man_in_the_world.jpg');
-- INSERT INTO Meme VALUES(761, 'things_went_okay','../static/media/faces/things_went_okay.jpg','things_went_okay.jpg');
-- INSERT INTO Meme VALUES(762, 'third_world_success','../static/media/faces/third_world_success.jpg','third_world_success.jpg');
-- INSERT INTO Meme VALUES(763, 'this_is_awkward','../static/media/faces/this_is_awkward.jpg','this_is_awkward.jpg');
-- INSERT INTO Meme VALUES(764, 'thousands_of_tears_later','../static/media/faces/thousands_of_tears_later.jpg','thousands_of_tears_later.jpg');
-- INSERT INTO Meme VALUES(765, 'three_hours_later','../static/media/faces/three_hours_later.jpg','three_hours_later.jpg');
-- INSERT INTO Meme VALUES(766, 'three_hours_later_2','../static/media/faces/three_hours_later_2.jpg','three_hours_later_2.jpg');
-- INSERT INTO Meme VALUES(767, 'three_weeks_later','../static/media/faces/three_weeks_later.jpg','three_weeks_later.jpg');
-- INSERT INTO Meme VALUES(768, 'three_weeks_later_2','../static/media/faces/three_weeks_later_2.jpg','three_weeks_later_2.jpg');
-- INSERT INTO Meme VALUES(769, 'thumbs_up','../static/media/faces/thumbs_up.jpg','thumbs_up.jpg');
-- INSERT INTO Meme VALUES(770, 'today_is_monday','../static/media/faces/today_is_monday.jpg','today_is_monday.jpg');
-- INSERT INTO Meme VALUES(771, 'toker_face','../static/media/faces/toker_face.jpg','toker_face.jpg');
-- INSERT INTO Meme VALUES(772, 'tomorrow','../static/media/faces/tomorrow.jpg','tomorrow.jpg');
-- INSERT INTO Meme VALUES(773, 'tomorrow_for_sure','../static/media/faces/tomorrow_for_sure.jpg','tomorrow_for_sure.jpg');
-- INSERT INTO Meme VALUES(774, 'trees','../static/media/faces/trees.jpg','trees.jpg');
-- INSERT INTO Meme VALUES(775, 'trees_angry','../static/media/faces/trees_angry.jpg','trees_angry.jpg');
-- INSERT INTO Meme VALUES(776, 'trees_big_mouth','../static/media/faces/trees_big_mouth.jpg','trees_big_mouth.jpg');
-- INSERT INTO Meme VALUES(777, 'trees_confused','../static/media/faces/trees_confused.jpg','trees_confused.jpg');
-- INSERT INTO Meme VALUES(778, 'trees_happy','../static/media/faces/trees_happy.jpg','trees_happy.jpg');
-- INSERT INTO Meme VALUES(779, 'trees_small_mouth','../static/media/faces/trees_small_mouth.jpg','trees_small_mouth.jpg');
-- INSERT INTO Meme VALUES(780, 'trees_smile','../static/media/faces/trees_smile.jpg','trees_smile.jpg');
-- INSERT INTO Meme VALUES(781, 'trees_stoned','../static/media/faces/trees_stoned.jpg','trees_stoned.jpg');
-- INSERT INTO Meme VALUES(782, 'trees_stoned_exhale','../static/media/faces/trees_stoned_exhale.jpg','trees_stoned_exhale.jpg');
-- INSERT INTO Meme VALUES(783, 'trees_stoned_inhale','../static/media/faces/trees_stoned_inhale.jpg','trees_stoned_inhale.jpg');
-- INSERT INTO Meme VALUES(784, 'trex_rage','../static/media/faces/trex_rage.jpg','trex_rage.jpg');
-- INSERT INTO Meme VALUES(785, 'troll_2','../static/media/faces/troll_2.jpg','troll_2.jpg');
-- INSERT INTO Meme VALUES(786, 'troll_badumts','../static/media/faces/troll_badumts.jpg','troll_badumts.jpg');
-- INSERT INTO Meme VALUES(787, 'troll_ballon','../static/media/faces/troll_ballon.jpg','troll_ballon.jpg');
-- INSERT INTO Meme VALUES(788, 'troll_black','../static/media/faces/troll_black.jpg','troll_black.jpg');
-- INSERT INTO Meme VALUES(789, 'troll_black_beaten','../static/media/faces/troll_black_beaten.jpg','troll_black_beaten.jpg');
-- INSERT INTO Meme VALUES(790, 'troll_crazy','../static/media/faces/troll_crazy.jpg','troll_crazy.jpg');
-- INSERT INTO Meme VALUES(791, 'troll_dad','../static/media/faces/troll_dad.jpg','troll_dad.jpg');
-- INSERT INTO Meme VALUES(792, 'troll_dad_dance','../static/media/faces/troll_dad_dance.jpg','troll_dad_dance.jpg');
-- INSERT INTO Meme VALUES(793, 'troll_dad_full','../static/media/faces/troll_dad_full.jpg','troll_dad_full.jpg');
-- INSERT INTO Meme VALUES(794, 'troll_dad_monocle','../static/media/faces/troll_dad_monocle.jpg','troll_dad_monocle.jpg');
-- INSERT INTO Meme VALUES(795, 'troll_face','../static/media/faces/troll_face.jpg','troll_face.jpg');
-- INSERT INTO Meme VALUES(796, 'troll_face_backgrounded','../static/media/faces/troll_face_backgrounded.jpg','troll_face_backgrounded.jpg');
-- INSERT INTO Meme VALUES(797, 'troll_full','../static/media/faces/troll_full.jpg','troll_full.jpg');
-- INSERT INTO Meme VALUES(798, 'troll_granny','../static/media/faces/troll_granny.jpg','troll_granny.jpg');
-- INSERT INTO Meme VALUES(799, 'troll_gusta','../static/media/faces/troll_gusta.jpg','troll_gusta.jpg');
-- INSERT INTO Meme VALUES(800, 'troll_mickey','../static/media/faces/troll_mickey.jpg','troll_mickey.jpg');
-- INSERT INTO Meme VALUES(801, 'troll_problem','../static/media/faces/troll_problem.jpg','troll_problem.jpg');
-- INSERT INTO Meme VALUES(802, 'troll_typing','../static/media/faces/troll_typing.jpg','troll_typing.jpg');
-- INSERT INTO Meme VALUES(803, 'trollol','../static/media/faces/trollol.jpg','trollol.jpg');
-- INSERT INTO Meme VALUES(804, 'trologirl','../static/media/faces/trologirl.jpg','trologirl.jpg');
-- INSERT INTO Meme VALUES(805, 'true_fucking_story','../static/media/faces/true_fucking_story.jpg','true_fucking_story.jpg');
-- INSERT INTO Meme VALUES(806, 'true_story','../static/media/faces/true_story.jpg','true_story.jpg');
-- INSERT INTO Meme VALUES(807, 'trumpet','../static/media/faces/trumpet.jpg','trumpet.jpg');
-- INSERT INTO Meme VALUES(808, 'twenty_minutes_later','../static/media/faces/twenty_minutes_later.jpg','twenty_minutes_later.jpg');
-- INSERT INTO Meme VALUES(809, 'two_boring_minutes','../static/media/faces/two_boring_minutes.jpg','two_boring_minutes.jpg');
-- INSERT INTO Meme VALUES(810, 'two_hours_later','../static/media/faces/two_hours_later.jpg','two_hours_later.jpg');
-- INSERT INTO Meme VALUES(811, 'two_hours_later_2','../static/media/faces/two_hours_later_2.jpg','two_hours_later_2.jpg');
-- INSERT INTO Meme VALUES(812, 'two_hours_later_3','../static/media/faces/two_hours_later_3.jpg','two_hours_later_3.jpg');
-- INSERT INTO Meme VALUES(813, 'two_hours_later_4','../static/media/faces/two_hours_later_4.jpg','two_hours_later_4.jpg');
-- INSERT INTO Meme VALUES(814, 'two_hours_later_5','../static/media/faces/two_hours_later_5.jpg','two_hours_later_5.jpg');
-- INSERT INTO Meme VALUES(815, 'u_jelly','../static/media/faces/u_jelly.jpg','u_jelly.jpg');
-- INSERT INTO Meme VALUES(816, 'ultra_gay','../static/media/faces/ultra_gay.jpg','ultra_gay.jpg');
-- INSERT INTO Meme VALUES(817, 'unhappy','../static/media/faces/unhappy.jpg','unhappy.jpg');
-- INSERT INTO Meme VALUES(818, 'wait','../static/media/faces/wait.jpg','wait.jpg');
-- INSERT INTO Meme VALUES(819, 'wait_no','../static/media/faces/wait_no.jpg','wait_no.jpg');
-- INSERT INTO Meme VALUES(820, 'wat','../static/media/faces/wat.jpg','wat.jpg');
-- INSERT INTO Meme VALUES(821, 'wha','../static/media/faces/wha.jpg','wha.jpg');
-- INSERT INTO Meme VALUES(822, 'what','../static/media/faces/what.jpg','what.jpg');
-- INSERT INTO Meme VALUES(823, 'what_have_you_done','../static/media/faces/what_have_you_done.jpg','what_have_you_done.jpg');
-- INSERT INTO Meme VALUES(824, 'what_this_badass_shit_means','../static/media/faces/what_this_badass_shit_means.jpg','what_this_badass_shit_means.jpg');
-- INSERT INTO Meme VALUES(825, 'why_boy','../static/media/faces/why_boy.jpg','why_boy.jpg');
-- INSERT INTO Meme VALUES(826, 'whyyy','../static/media/faces/whyyy.jpg','whyyy.jpg');
-- INSERT INTO Meme VALUES(827, 'whyyy_backgrounded','../static/media/faces/whyyy_backgrounded.jpg','whyyy_backgrounded.jpg');
-- INSERT INTO Meme VALUES(828, 'will_smith','../static/media/faces/will_smith.jpg','will_smith.jpg');
-- INSERT INTO Meme VALUES(829, 'will_smith___tada','../static/media/faces/will_smith___tada.jpg','will_smith___tada.jpg');
-- INSERT INTO Meme VALUES(830, 'wonka','../static/media/faces/wonka.jpg','wonka.jpg');
-- INSERT INTO Meme VALUES(831, 'wonka_yao','../static/media/faces/wonka_yao.jpg','wonka_yao.jpg');
-- INSERT INTO Meme VALUES(832, 'wow','../static/media/faces/wow.jpg','wow.jpg');
-- INSERT INTO Meme VALUES(833, 'wut','../static/media/faces/wut.jpg','wut.jpg');
-- INSERT INTO Meme VALUES(834, 'x_all_the_y','../static/media/faces/x_all_the_y.jpg','x_all_the_y.jpg');
-- INSERT INTO Meme VALUES(835, 'y_u_no','../static/media/faces/y_u_no.jpg','y_u_no.jpg');
-- INSERT INTO Meme VALUES(836, 'y_u_no_crying','../static/media/faces/y_u_no_crying.jpg','y_u_no_crying.jpg');
-- INSERT INTO Meme VALUES(837, 'yao_ming_forever_alone','../static/media/faces/yao_ming_forever_alone.jpg','yao_ming_forever_alone.jpg');
-- INSERT INTO Meme VALUES(838, 'yao_ming_pirate','../static/media/faces/yao_ming_pirate.jpg','yao_ming_pirate.jpg');
-- INSERT INTO Meme VALUES(839, 'yay','../static/media/faces/yay.jpg','yay.jpg');
-- INSERT INTO Meme VALUES(840, 'yea_science','../static/media/faces/yea_science.jpg','yea_science.jpg');
-- INSERT INTO Meme VALUES(841, 'yes_i_do_say','../static/media/faces/yes_i_do_say.jpg','yes_i_do_say.jpg');
-- INSERT INTO Meme VALUES(842, 'yes_this_is_dog','../static/media/faces/yes_this_is_dog.jpg','yes_this_is_dog.jpg');
-- INSERT INTO Meme VALUES(843, 'yesterday','../static/media/faces/yesterday.jpg','yesterday.jpg');
-- INSERT INTO Meme VALUES(844, 'yo_dawg','../static/media/faces/yo_dawg.jpg','yo_dawg.jpg');
-- INSERT INTO Meme VALUES(845, 'you_are_the_man','../static/media/faces/you_are_the_man.jpg','you_are_the_man.jpg');
-- INSERT INTO Meme VALUES(846, 'you_dont_say','../static/media/faces/you_dont_say.jpg','you_dont_say.jpg');
-- INSERT INTO Meme VALUES(847, 'you_fucking_kidding_me_son','../static/media/faces/you_fucking_kidding_me_son.jpg','you_fucking_kidding_me_son.jpg');
-- INSERT INTO Meme VALUES(848, 'you_got_it','../static/media/faces/you_got_it.jpg','you_got_it.jpg');
-- INSERT INTO Meme VALUES(849, 'you_seem_upset','../static/media/faces/you_seem_upset.jpg','you_seem_upset.jpg');
-- INSERT INTO Meme VALUES(850, 'you_win_this_time','../static/media/faces/you_win_this_time.jpg','you_win_this_time.jpg');
-- INSERT INTO Meme VALUES(851, 'your_pain_amuses_me','../static/media/faces/your_pain_amuses_me.jpg','your_pain_amuses_me.jpg');
-- INSERT INTO Meme VALUES(852, 'youre_the_man','../static/media/faces/youre_the_man.jpg','youre_the_man.jpg');

Select * from Users; 
Select * from Meme; 
Select * from Tag;
Select * from IsFriend;
Select * from PotentialPartner; 
Select * from Opinion; 
Select * from HasTag; 
Select * from TagCount;
