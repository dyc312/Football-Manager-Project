SET NAMES utf8mb4;
START TRANSACTION;

-- 比分不手工写入 Match，而由 MatchEvent + MatchScoreView 自动计算。

INSERT INTO Season (season_id, season_name, start_date, end_date) VALUES
(1, '2025-2026 英超赛季', '2025-08-10', '2026-05-22');

INSERT INTO Tournament (tournament_id, tournament_name, organizer) VALUES
(1, '英格兰足球超级联赛', 'The Football Association');



INSERT INTO Team (team_id, team_name, city, coach_name) VALUES
(1, 'Manchester United', 'Manchester', 'Rúben Amorim'),
(2, 'Liverpool', 'Liverpool', 'Arne Slot'),
(3, 'Arsenal', 'London', 'Mikel Arteta'),
(4, 'Chelsea', 'London', 'Enzo Maresca'),
(5, 'Manchester City', 'Manchester', 'Pep Guardiola'),
(6, 'Tottenham Hotspur', 'London', 'Ange Postecoglou'),
(7, 'Bournemouth', 'Bournemouth', 'Andoni Iraola'),
(8, 'Aston Villa', 'Birmingham', 'Unai Emery'),
(9, 'Newcastle United', 'Newcastle', 'Eddie Howe'),
(10, 'Brighton & Hove Albion', 'Brighton', 'Fabian Hürzeler'),
(11, 'Fulham', 'London', 'Marco Silva'),
(12, 'Burnley', 'Burnley', 'Vincent Kompany'),
(13, 'Sunderland', 'Sunderland', 'Régis Le Bris'),
(14, 'West Ham United', 'London', 'Julen Lopetegui'),
(15, 'Wolves', 'Wolverhampton', 'Gary O''Neil'),
(16, 'Crystal Palace', 'London', 'Oliver Glasner'),
(17, 'Nottingham Forest', 'Nottingham', 'Nuno Espírito Santo'),
(18, 'Brentford', 'London', 'Thomas Frank'),
(19, 'Leeds United', 'Leeds', 'Daniel Farke'),
(20, 'Everton', 'Liverpool', 'Sean Dyche');








INSERT INTO `Match` (match_id, season_id, tournament_id, home_team_id, away_team_id, round_no, match_date, `status`) VALUES
(1, 1, 1, 2, 7, 1, '2025-08-15 20:00:00', 'finished'),   -- Liverpool 4-2 Bournemouth[reference:5]
(2, 1, 1, 8, 9, 1, '2025-08-16 12:30:00', 'finished'),   -- Aston Villa 0-0 Newcastle[reference:6]
(3, 1, 1, 10, 11, 1, '2025-08-16 15:00:00', 'finished'), -- Brighton 1-1 Fulham[reference:7]
(4, 1, 1, 6, 12, 1, '2025-08-16 15:00:00', 'finished'),  -- Tottenham 3-0 Burnley[reference:8]
(5, 1, 1, 13, 14, 1, '2025-08-16 15:00:00', 'finished'), -- Sunderland 3-0 West Ham[reference:9]
(6, 1, 1, 15, 5, 1, '2025-08-16 17:30:00', 'finished'),  -- Wolves 0-4 Man City[reference:10]
(7, 1, 1, 4, 16, 1, '2025-08-17 14:00:00', 'finished'),  -- Chelsea 0-0 Crystal Palace[reference:11]
(8, 1, 1, 17, 18, 1, '2025-08-17 14:00:00', 'finished'), -- Nott'm Forest 3-1 Brentford[reference:12]
(9, 1, 1, 1, 3, 1, '2025-08-17 16:30:00', 'finished'),   -- Man Utd 0-1 Arsenal[reference:13][reference:14]
(10, 1, 1, 19, 20, 1, '2025-08-19 03:00:00', 'finished'), -- Leeds United 1-0 Everton[reference:15]

(11, 1, 1, 14, 4, 2, '2025-08-22 20:00:00', 'finished'),  -- West Ham 1-5 Chelsea[reference:16][reference:17]
(12, 1, 1, 5, 6, 2, '2025-08-23 12:30:00', 'finished'),   -- Man City 0-2 Tottenham[reference:18]
(13, 1, 1, 7, 15, 2, '2025-08-23 15:00:00', 'finished'),  -- Bournemouth 1-0 Wolves[reference:19]
(14, 1, 1, 18, 8, 2, '2025-08-23 15:00:00', 'finished'),  -- Brentford 1-0 Aston Villa[reference:20]
(15, 1, 1, 12, 13, 2, '2025-08-23 15:00:00', 'finished'), -- Burnley 2-0 Sunderland[reference:21]
(16, 1, 1, 3, 19, 2, '2025-08-23 17:30:00', 'finished'),  -- Arsenal 5-0 Leeds United[reference:22][reference:23]
(17, 1, 1, 20, 10, 2, '2025-08-24 14:00:00', 'finished'), -- Everton 2-0 Brighton[reference:24]
(18, 1, 1, 16, 17, 2, '2025-08-24 14:00:00', 'finished'), -- Crystal Palace 1-1 Nott'm Forest[reference:25]
(19, 1, 1, 11, 1, 2, '2025-08-24 16:30:00', 'finished'),  -- Fulham 1-1 Man Utd[reference:26]
(20, 1, 1, 9, 2, 2, '2025-08-25 20:00:00', 'finished');   -- Newcastle United 2-3 Liverpool[reference:27]



INSERT INTO Player (player_id, team_id, player_name, number, `position`) VALUES
-- Manchester United (1) 2025-26 修正版，共23人
(1, 1, 'Altay Bayındır', 1, 'Goalkeeper'),
(2, 1, 'Senne Lammens', 31, 'Goalkeeper'),
(3, 1, 'Tom Heaton', 22, 'Goalkeeper'),
(4, 1, 'Diogo Dalot', 20, 'Defender'),
(5, 1, 'Noussair Mazraoui', 3, 'Defender'),
(6, 1, 'Matthijs de Ligt', 4, 'Defender'),
(7, 1, 'Harry Maguire', 5, 'Defender'),
(8, 1, 'Lisandro Martínez', 6, 'Defender'),
(9, 1, 'Leny Yoro', 15, 'Defender'),
(10, 1, 'Luke Shaw', 23, 'Defender'),
(11, 1, 'Patrick Dorgu', 13, 'Defender'),
(221, 1, 'Diego León', 30, 'Defender'),
(222, 1, 'Bruno Fernandes', 8, 'Midfielder'),
(223, 1, 'Casemiro', 18, 'Midfielder'),
(224, 1, 'Manuel Ugarte', 25, 'Midfielder'),
(225, 1, 'Kobbie Mainoo', 37, 'Midfielder'),
(226, 1, 'Mason Mount', 7, 'Midfielder'),
(227, 1, 'Amad Diallo', 16, 'Forward'),
(228, 1, 'Matheus Cunha', 10, 'Forward'),
(229, 1, 'Bryan Mbeumo', 19, 'Forward'),
(230, 1, 'Benjamin Šeško', 9, 'Forward'),
(231, 1, 'Joshua Zirkzee', 11, 'Forward'),
(232, 1, 'Chido Obi', 32, 'Forward'),
-- Liverpool (2) 2025-26 修正版，共23人
(12, 2, 'Alisson Becker', 1, 'Goalkeeper'),
(13, 2, 'Giorgi Mamardashvili', 25, 'Goalkeeper'),
(14, 2, 'Freddie Woodman', 28, 'Goalkeeper'),
(15, 2, 'Jeremie Frimpong', 30, 'Defender'),
(16, 2, 'Conor Bradley', 84, 'Defender'),
(17, 2, 'Joe Gomez', 2, 'Defender'),
(18, 2, 'Virgil van Dijk', 4, 'Defender'),
(19, 2, 'Ibrahima Konaté', 5, 'Defender'),
(20, 2, 'Giovanni Leoni', 15, 'Defender'),
(21, 2, 'Milos Kerkez', 6, 'Defender'),
(22, 2, 'Andy Robertson', 26, 'Defender'),
(233, 2, 'Wataru Endo', 3, 'Midfielder'),
(234, 2, 'Alexis Mac Allister', 10, 'Midfielder'),
(235, 2, 'Dominik Szoboszlai', 8, 'Midfielder'),
(236, 2, 'Florian Wirtz', 7, 'Midfielder'),
(237, 2, 'Ryan Gravenberch', 38, 'Midfielder'),
(238, 2, 'Curtis Jones', 17, 'Midfielder'),
(239, 2, 'Mohamed Salah', 11, 'Forward'),
(240, 2, 'Cody Gakpo', 18, 'Forward'),
(241, 2, 'Federico Chiesa', 14, 'Forward'),
(242, 2, 'Alexander Isak', 9, 'Forward'),
(243, 2, 'Hugo Ekitike', 22, 'Forward'),
(244, 2, 'Rio Ngumoha', 73, 'Forward'),
-- Arsenal (3) 2025-26 修正版，共23人
(23, 3, 'David Raya', 1, 'Goalkeeper'),
(24, 3, 'Kepa Arrizabalaga', 13, 'Goalkeeper'),
(25, 3, 'Tommy Setford', 35, 'Goalkeeper'),
(26, 3, 'Jurrien Timber', 12, 'Defender'),
(27, 3, 'William Saliba', 2, 'Defender'),
(28, 3, 'Gabriel Magalhães', 6, 'Defender'),
(29, 3, 'Ben White', 4, 'Defender'),
(30, 3, 'Riccardo Calafiori', 33, 'Defender'),
(31, 3, 'Cristhian Mosquera', 3, 'Defender'),
(32, 3, 'Piero Hincapié', 5, 'Defender'),
(33, 3, 'Myles Lewis-Skelly', 49, 'Defender'),
(245, 3, 'Declan Rice', 41, 'Midfielder'),
(246, 3, 'Martin Ødegaard', 8, 'Midfielder'),
(247, 3, 'Martín Zubimendi', 36, 'Midfielder'),
(248, 3, 'Mikel Merino', 23, 'Midfielder'),
(249, 3, 'Ethan Nwaneri', 22, 'Midfielder'),
(250, 3, 'Bukayo Saka', 7, 'Forward'),
(251, 3, 'Gabriel Martinelli', 11, 'Forward'),
(252, 3, 'Noni Madueke', 20, 'Forward'),
(253, 3, 'Eberechi Eze', 10, 'Forward'),
(254, 3, 'Viktor Gyökeres', 14, 'Forward'),
(255, 3, 'Gabriel Jesus', 9, 'Forward'),
(256, 3, 'Kai Havertz', 29, 'Forward'),
-- Chelsea (4) 2025-26 修正版，共23人
(34, 4, 'Robert Sánchez', 1, 'Goalkeeper'),
(35, 4, 'Filip Jørgensen', 12, 'Goalkeeper'),
(36, 4, 'Mike Penders', 21, 'Goalkeeper'),
(37, 4, 'Reece James', 24, 'Defender'),
(38, 4, 'Malo Gusto', 27, 'Defender'),
(39, 4, 'Marc Cucurella', 3, 'Defender'),
(40, 4, 'Levi Colwill', 6, 'Defender'),
(41, 4, 'Wesley Fofana', 29, 'Defender'),
(42, 4, 'Tosin Adarabioyo', 4, 'Defender'),
(43, 4, 'Benoît Badiashile', 5, 'Defender'),
(44, 4, 'Trevoh Chalobah', 23, 'Defender'),
(257, 4, 'Josh Acheampong', 34, 'Defender'),
(258, 4, 'Moisés Caicedo', 25, 'Midfielder'),
(259, 4, 'Enzo Fernández', 8, 'Midfielder'),
(260, 4, 'Roméo Lavia', 45, 'Midfielder'),
(261, 4, 'Andrey Santos', 17, 'Midfielder'),
(262, 4, 'Cole Palmer', 10, 'Midfielder'),
(263, 4, 'Estêvão Willian', 41, 'Forward'),
(264, 4, 'Pedro Neto', 7, 'Forward'),
(265, 4, 'João Pedro', 20, 'Forward'),
(266, 4, 'Liam Delap', 9, 'Forward'),
(267, 4, 'Jamie Gittens', 11, 'Forward'),
(268, 4, 'Alejandro Garnacho', 49, 'Forward'),
-- Manchester City (5) 2025-26 修正版，共23人
(45, 5, 'Gianluigi Donnarumma', 99, 'Goalkeeper'),
(46, 5, 'Stefan Ortega', 18, 'Goalkeeper'),
(47, 5, 'James Trafford', 1, 'Goalkeeper'),
(48, 5, 'Rúben Dias', 3, 'Defender'),
(49, 5, 'John Stones', 5, 'Defender'),
(50, 5, 'Nathan Aké', 6, 'Defender'),
(51, 5, 'Joško Gvardiol', 24, 'Defender'),
(52, 5, 'Rico Lewis', 82, 'Defender'),
(53, 5, 'Matheus Nunes', 27, 'Defender'),
(54, 5, 'Abdukodir Khusanov', 45, 'Defender'),
(55, 5, 'Rodri', 16, 'Midfielder'),
(269, 5, 'Mateo Kovačić', 8, 'Midfielder'),
(270, 5, 'Bernardo Silva', 20, 'Midfielder'),
(271, 5, 'Phil Foden', 47, 'Midfielder'),
(272, 5, 'Tijjani Reijnders', 4, 'Midfielder'),
(273, 5, 'Rayan Cherki', 29, 'Midfielder'),
(274, 5, 'Nico González', 14, 'Midfielder'),
(275, 5, 'Erling Haaland', 9, 'Forward'),
(276, 5, 'Omar Marmoush', 7, 'Forward'),
(277, 5, 'Jérémy Doku', 11, 'Forward'),
(278, 5, 'Savinho', 26, 'Forward'),
(279, 5, 'Oscar Bobb', 52, 'Forward'),
(280, 5, 'Divine Mukasa', 66, 'Midfielder'),
-- Tottenham Hotspur (6) 2025-26 修正版，共24人
(56, 6, 'Guglielmo Vicario', 1, 'Goalkeeper'),
(57, 6, 'Antonín Kinský', 31, 'Goalkeeper'),
(58, 6, 'Brandon Austin', 40, 'Goalkeeper'),
(59, 6, 'Pedro Porro', 23, 'Defender'),
(60, 6, 'Cristian Romero', 17, 'Defender'),
(61, 6, 'Micky van de Ven', 37, 'Defender'),
(62, 6, 'Destiny Udogie', 13, 'Defender'),
(63, 6, 'Djed Spence', 24, 'Defender'),
(64, 6, 'Kevin Danso', 4, 'Defender'),
(65, 6, 'Radu Drăgușin', 6, 'Defender'),
(66, 6, 'Ben Davies', 33, 'Defender'),
(281, 6, 'Rodrigo Bentancur', 30, 'Midfielder'),
(282, 6, 'Pape Matar Sarr', 29, 'Midfielder'),
(283, 6, 'Yves Bissouma', 8, 'Midfielder'),
(284, 6, 'James Maddison', 10, 'Midfielder'),
(285, 6, 'Lucas Bergvall', 15, 'Midfielder'),
(286, 6, 'Archie Gray', 14, 'Midfielder'),
(287, 6, 'João Palhinha', 5, 'Midfielder'),
(288, 6, 'Xavi Simons', 7, 'Midfielder'),
(289, 6, 'Mohammed Kudus', 20, 'Forward'),
(290, 6, 'Dominic Solanke', 19, 'Forward'),
(291, 6, 'Richarlison', 9, 'Forward'),
(292, 6, 'Brennan Johnson', 22, 'Forward'),
(293, 6, 'Mathys Tel', 11, 'Forward'),
-- Bournemouth (7) 2025-26 修正版，共23人
(67, 7, 'Đorđe Petrović', 1, 'Goalkeeper'),
(68, 7, 'Mark Travers', 42, 'Goalkeeper'),
(69, 7, 'Will Dennis', 40, 'Goalkeeper'),
(70, 7, 'Adam Smith', 15, 'Defender'),
(71, 7, 'Marcos Senesi', 5, 'Defender'),
(72, 7, 'James Hill', 23, 'Defender'),
(73, 7, 'Julio Soler', 20, 'Defender'),
(74, 7, 'Bafodé Diakité', 2, 'Defender'),
(75, 7, 'Adrien Truffert', 3, 'Defender'),
(76, 7, 'Alex Jiménez', 22, 'Defender'),
(77, 7, 'Lewis Cook', 4, 'Midfielder'),
(294, 7, 'Tyler Adams', 12, 'Midfielder'),
(295, 7, 'Ryan Christie', 10, 'Midfielder'),
(296, 7, 'Alex Scott', 14, 'Midfielder'),
(297, 7, 'Marcus Tavernier', 16, 'Midfielder'),
(298, 7, 'David Brooks', 7, 'Midfielder'),
(299, 7, 'Justin Kluivert', 19, 'Midfielder'),
(300, 7, 'Antoine Semenyo', 24, 'Forward'),
(301, 7, 'Evanilson', 9, 'Forward'),
(302, 7, 'Enes Ünal', 26, 'Forward'),
(303, 7, 'Luis Sinisterra', 17, 'Forward'),
(304, 7, 'Ben Doak', 11, 'Forward'),
(305, 7, 'Daniel Jebbison', 21, 'Forward'),
-- Aston Villa (8) 2025-26 修正版，共22人
(78, 8, 'Emiliano Martínez', 23, 'Goalkeeper'),
(79, 8, 'Marco Bizot', 1, 'Goalkeeper'),
(80, 8, 'Joe Gauci', 18, 'Goalkeeper'),
(81, 8, 'Matty Cash', 2, 'Defender'),
(82, 8, 'Ezri Konsa', 4, 'Defender'),
(83, 8, 'Pau Torres', 14, 'Defender'),
(84, 8, 'Tyrone Mings', 5, 'Defender'),
(85, 8, 'Lucas Digne', 12, 'Defender'),
(86, 8, 'Ian Maatsen', 22, 'Defender'),
(87, 8, 'Lamare Bogarde', 26, 'Defender'),
(88, 8, 'Boubacar Kamara', 44, 'Midfielder'),
(306, 8, 'Amadou Onana', 24, 'Midfielder'),
(307, 8, 'Youri Tielemans', 8, 'Midfielder'),
(308, 8, 'John McGinn', 7, 'Midfielder'),
(309, 8, 'Morgan Rogers', 27, 'Midfielder'),
(310, 8, 'Emiliano Buendía', 10, 'Midfielder'),
(311, 8, 'Harvey Elliott', 29, 'Midfielder'),
(312, 8, 'Ollie Watkins', 11, 'Forward'),
(313, 8, 'Donyell Malen', 17, 'Forward'),
(314, 8, 'Evann Guessand', 9, 'Forward'),
(315, 8, 'Jadon Sancho', 19, 'Forward'),
(316, 8, 'Jacob Ramsey', 41, 'Midfielder'),
-- Newcastle United (9) 2025-26 修正版，共22人
(89, 9, 'Nick Pope', 22, 'Goalkeeper'),
(90, 9, 'Aaron Ramsdale', 1, 'Goalkeeper'),
(91, 9, 'Martin Dúbravka', 26, 'Goalkeeper'),
(92, 9, 'Kieran Trippier', 2, 'Defender'),
(93, 9, 'Tino Livramento', 21, 'Defender'),
(94, 9, 'Fabian Schär', 5, 'Defender'),
(95, 9, 'Sven Botman', 4, 'Defender'),
(96, 9, 'Dan Burn', 33, 'Defender'),
(97, 9, 'Lewis Hall', 20, 'Defender'),
(98, 9, 'Malick Thiaw', 12, 'Defender'),
(99, 9, 'Bruno Guimarães', 39, 'Midfielder'),
(317, 9, 'Sandro Tonali', 8, 'Midfielder'),
(318, 9, 'Joelinton', 7, 'Midfielder'),
(319, 9, 'Joe Willock', 28, 'Midfielder'),
(320, 9, 'Lewis Miley', 67, 'Midfielder'),
(321, 9, 'Jacob Ramsey', 41, 'Midfielder'),
(322, 9, 'Anthony Gordon', 10, 'Forward'),
(323, 9, 'Harvey Barnes', 11, 'Forward'),
(324, 9, 'Jacob Murphy', 23, 'Forward'),
(325, 9, 'Anthony Elanga', 27, 'Forward'),
(326, 9, 'Nick Woltemade', 9, 'Forward'),
(327, 9, 'Yoane Wissa', 18, 'Forward'),
-- Brighton & Hove Albion (10) 2025-26 修正版，共21人
(100, 10, 'Bart Verbruggen', 1, 'Goalkeeper'),
(101, 10, 'Jason Steele', 23, 'Goalkeeper'),
(102, 10, 'Carl Rushworth', 39, 'Goalkeeper'),
(103, 10, 'Joël Veltman', 34, 'Defender'),
(104, 10, 'Lewis Dunk', 5, 'Defender'),
(105, 10, 'Jan Paul van Hecke', 29, 'Defender'),
(106, 10, 'Adam Webster', 4, 'Defender'),
(107, 10, 'Tariq Lamptey', 2, 'Defender'),
(108, 10, 'Mats Wieffer', 27, 'Midfielder'),
(109, 10, 'Carlos Baleba', 20, 'Midfielder'),
(110, 10, 'Jack Hinshelwood', 41, 'Midfielder'),
(328, 10, 'Yasin Ayari', 26, 'Midfielder'),
(329, 10, 'Diego Gómez', 8, 'Midfielder'),
(330, 10, 'Brajan Gruda', 17, 'Midfielder'),
(331, 10, 'Matt O''Riley', 33, 'Midfielder'),
(332, 10, 'Kaoru Mitoma', 22, 'Forward'),
(333, 10, 'Yankuba Minteh', 11, 'Forward'),
(334, 10, 'Georginio Rutter', 14, 'Forward'),
(335, 10, 'Danny Welbeck', 18, 'Forward'),
(336, 10, 'Solly March', 7, 'Forward'),
(337, 10, 'Ferdi Kadıoğlu', 24, 'Defender'),
-- Fulham (11) 2025-26 修正版，共22人
(111, 11, 'Bernd Leno', 1, 'Goalkeeper'),
(112, 11, 'Steven Sessegnon', 2, 'Defender'),
(113, 11, 'Benjamin Lecomte', 23, 'Goalkeeper'),
(114, 11, 'Kenny Tete', 21, 'Defender'),
(115, 11, 'Timothy Castagne', 12, 'Defender'),
(116, 11, 'Joachim Andersen', 5, 'Defender'),
(117, 11, 'Calvin Bassey', 3, 'Defender'),
(118, 11, 'Antonee Robinson', 33, 'Defender'),
(119, 11, 'Issa Diop', 31, 'Defender'),
(120, 11, 'Jorge Cuenca', 15, 'Defender'),
(121, 11, 'Sander Berge', 16, 'Midfielder'),
(338, 11, 'Saša Lukić', 20, 'Midfielder'),
(339, 11, 'Tom Cairney', 10, 'Midfielder'),
(340, 11, 'Emile Smith Rowe', 32, 'Midfielder'),
(341, 11, 'Alex Iwobi', 17, 'Midfielder'),
(342, 11, 'Harry Wilson', 8, 'Midfielder'),
(343, 11, 'Josh King', 24, 'Midfielder'),
(344, 11, 'Raúl Jiménez', 7, 'Forward'),
(345, 11, 'Rodrigo Muniz', 9, 'Forward'),
(346, 11, 'Adama Traoré', 11, 'Forward'),
(347, 11, 'Ryan Sessegnon', 30, 'Defender'),
(348, 11, 'Samuel Chukwueze', 19, 'Forward'),
-- Burnley (12) 2025-26 修正版，共22人
(122, 12, 'Martin Dúbravka', 1, 'Goalkeeper'),
(123, 12, 'Max Weiß', 13, 'Goalkeeper'),
(124, 12, 'Václav Hladký', 32, 'Goalkeeper'),
(125, 12, 'Kyle Walker', 2, 'Defender'),
(126, 12, 'Quilindschy Hartman', 3, 'Defender'),
(127, 12, 'Axel Tuanzebe', 6, 'Defender'),
(128, 12, 'Maxime Estève', 5, 'Defender'),
(129, 12, 'Joe Worrall', 4, 'Defender'),
(130, 12, 'Hjalmar Ekdal', 18, 'Defender'),
(131, 12, 'Connor Roberts', 14, 'Defender'),
(132, 12, 'Josh Cullen', 24, 'Midfielder'),
(349, 12, 'Lesley Ugochukwu', 8, 'Midfielder'),
(350, 12, 'Hannibal Mejbri', 28, 'Midfielder'),
(351, 12, 'Josh Laurent', 29, 'Midfielder'),
(352, 12, 'Zian Flemming', 19, 'Midfielder'),
(353, 12, 'Loum Tchaouna', 21, 'Forward'),
(354, 12, 'Lyle Foster', 9, 'Forward'),
(355, 12, 'Jacob Bruun Larsen', 7, 'Forward'),
(356, 12, 'Jaidon Anthony', 11, 'Forward'),
(357, 12, 'Luca Koleosho', 30, 'Forward'),
(358, 12, 'Armando Broja', 27, 'Forward'),
(359, 12, 'Marcus Edwards', 22, 'Forward'),
-- Sunderland (13) 2025-26 修正版，共21人
(133, 13, 'Anthony Patterson', 1, 'Goalkeeper'),
(134, 13, 'Robin Roefs', 22, 'Goalkeeper'),
(135, 13, 'Simon Moore', 21, 'Goalkeeper'),
(136, 13, 'Trai Hume', 32, 'Defender'),
(137, 13, 'Dan Ballard', 5, 'Defender'),
(138, 13, 'Luke O''Nien', 13, 'Defender'),
(139, 13, 'Reinildo Mandava', 23, 'Defender'),
(140, 13, 'Aji Alese', 42, 'Defender'),
(141, 13, 'Nordi Mukiele', 2, 'Defender'),
(142, 13, 'Omar Alderete', 15, 'Defender'),
(143, 13, 'Granit Xhaka', 34, 'Midfielder'),
(360, 13, 'Habib Diarra', 6, 'Midfielder'),
(361, 13, 'Chris Rigg', 11, 'Midfielder'),
(362, 13, 'Dan Neil', 24, 'Midfielder'),
(363, 13, 'Noah Sadiki', 27, 'Midfielder'),
(364, 13, 'Enzo Le Fée', 28, 'Midfielder'),
(365, 13, 'Patrick Roberts', 10, 'Forward'),
(366, 13, 'Simon Adingra', 7, 'Forward'),
(367, 13, 'Wilson Isidor', 18, 'Forward'),
(368, 13, 'Eliezer Mayenda', 12, 'Forward'),
(369, 13, 'Chemsdine Talbi', 14, 'Forward'),
-- West Ham United (14) 2025-26 修正版，共21人
(144, 14, 'Alphonse Areola', 23, 'Goalkeeper'),
(145, 14, 'Mads Hermansen', 1, 'Goalkeeper'),
(146, 14, 'Wes Foderingham', 21, 'Goalkeeper'),
(147, 14, 'Aaron Wan-Bissaka', 29, 'Defender'),
(148, 14, 'Jean-Clair Todibo', 25, 'Defender'),
(149, 14, 'Konstantinos Mavropanos', 15, 'Defender'),
(150, 14, 'Max Kilman', 26, 'Defender'),
(151, 14, 'El Hadji Malick Diouf', 12, 'Defender'),
(152, 14, 'Emerson Palmieri', 33, 'Defender'),
(153, 14, 'Tomáš Souček', 28, 'Midfielder'),
(154, 14, 'James Ward-Prowse', 8, 'Midfielder'),
(370, 14, 'Lucas Paquetá', 10, 'Midfielder'),
(371, 14, 'Mateus Fernandes', 18, 'Midfielder'),
(372, 14, 'Andy Irving', 39, 'Midfielder'),
(373, 14, 'Freddie Potts', 17, 'Midfielder'),
(374, 14, 'Jarrod Bowen', 20, 'Forward'),
(375, 14, 'Crysencio Summerville', 7, 'Forward'),
(376, 14, 'Niclas Füllkrug', 11, 'Forward'),
(377, 14, 'Callum Wilson', 9, 'Forward'),
(378, 14, 'Luis Guilherme', 19, 'Forward'),
(379, 14, 'George Earthy', 40, 'Midfielder'),
-- Wolves (15) 2025-26 修正版，共21人
(155, 15, 'José Sá', 1, 'Goalkeeper'),
(156, 15, 'Sam Johnstone', 31, 'Goalkeeper'),
(157, 15, 'Daniel Bentley', 25, 'Goalkeeper'),
(158, 15, 'Matt Doherty', 2, 'Defender'),
(159, 15, 'Toti Gomes', 24, 'Defender'),
(160, 15, 'Santiago Bueno', 4, 'Defender'),
(161, 15, 'Emmanuel Agbadou', 12, 'Defender'),
(162, 15, 'Hugo Bueno', 17, 'Defender'),
(163, 15, 'Ladislav Krejčí', 5, 'Defender'),
(164, 15, 'Jackson Tchatchoua', 22, 'Defender'),
(165, 15, 'João Gomes', 8, 'Midfielder'),
(380, 15, 'André', 7, 'Midfielder'),
(381, 15, 'Jean-Ricner Bellegarde', 27, 'Midfielder'),
(382, 15, 'Marshall Munetsi', 6, 'Midfielder'),
(383, 15, 'Tommy Doyle', 20, 'Midfielder'),
(384, 15, 'Fer López', 21, 'Midfielder'),
(385, 15, 'Hwang Hee-chan', 11, 'Forward'),
(386, 15, 'Jørgen Strand Larsen', 9, 'Forward'),
(387, 15, 'Rodrigo Gomes', 19, 'Forward'),
(388, 15, 'Carlos Forbs', 30, 'Forward'),
(389, 15, 'Tolu Arokodare', 18, 'Forward'),
-- Crystal Palace (16) 2025-26 修正版，共21人
(166, 16, 'Dean Henderson', 1, 'Goalkeeper'),
(167, 16, 'Matt Turner', 30, 'Goalkeeper'),
(168, 16, 'Remi Matthews', 31, 'Goalkeeper'),
(169, 16, 'Daniel Muñoz', 12, 'Defender'),
(170, 16, 'Marc Guéhi', 6, 'Defender'),
(171, 16, 'Maxence Lacroix', 5, 'Defender'),
(172, 16, 'Chris Richards', 26, 'Defender'),
(173, 16, 'Tyrick Mitchell', 3, 'Defender'),
(174, 16, 'Chadi Riad', 34, 'Defender'),
(175, 16, 'Nathaniel Clyne', 17, 'Defender'),
(176, 16, 'Cheick Doucouré', 28, 'Midfielder'),
(390, 16, 'Adam Wharton', 20, 'Midfielder'),
(391, 16, 'Jefferson Lerma', 8, 'Midfielder'),
(392, 16, 'Will Hughes', 19, 'Midfielder'),
(393, 16, 'Daichi Kamada', 18, 'Midfielder'),
(394, 16, 'Romain Esse', 21, 'Midfielder'),
(395, 16, 'Ismaïla Sarr', 7, 'Forward'),
(396, 16, 'Jean-Philippe Mateta', 14, 'Forward'),
(397, 16, 'Eddie Nketiah', 9, 'Forward'),
(398, 16, 'Yeremy Pino', 10, 'Forward'),
(399, 16, 'Justin Devenny', 55, 'Midfielder'),
-- Nottingham Forest (17) 2025-26 修正版，共20人
(177, 17, 'Matz Sels', 26, 'Goalkeeper'),
(178, 17, 'Carlos Miguel', 33, 'Goalkeeper'),
(179, 17, 'Angus Gunn', 1, 'Goalkeeper'),
(180, 17, 'Ola Aina', 34, 'Defender'),
(181, 17, 'Neco Williams', 7, 'Defender'),
(182, 17, 'Murillo', 5, 'Defender'),
(183, 17, 'Nikola Milenković', 31, 'Defender'),
(184, 17, 'Morato', 4, 'Defender'),
(185, 17, 'Jair Cunha', 13, 'Defender'),
(186, 17, 'Ibrahim Sangaré', 6, 'Midfielder'),
(187, 17, 'Ryan Yates', 22, 'Midfielder'),
(400, 17, 'Morgan Gibbs-White', 10, 'Midfielder'),
(401, 17, 'Danilo', 28, 'Midfielder'),
(402, 17, 'Elliot Anderson', 8, 'Midfielder'),
(403, 17, 'Callum Hudson-Odoi', 14, 'Forward'),
(404, 17, 'Chris Wood', 11, 'Forward'),
(405, 17, 'Taiwo Awoniyi', 9, 'Forward'),
(406, 17, 'Igor Jesus', 19, 'Forward'),
(407, 17, 'Dilane Bakwa', 20, 'Forward'),
(408, 17, 'Arnaud Kalimuendo', 29, 'Forward'),
-- Brentford (18) 2025-26 修正版，共22人
(188, 18, 'Caoimhín Kelleher', 1, 'Goalkeeper'),
(189, 18, 'Hákon Valdimarsson', 12, 'Goalkeeper'),
(190, 18, 'Matthew Cox', 13, 'Goalkeeper'),
(191, 18, 'Aaron Hickey', 2, 'Defender'),
(192, 18, 'Kristoffer Ajer', 20, 'Defender'),
(193, 18, 'Nathan Collins', 22, 'Defender'),
(194, 18, 'Ethan Pinnock', 5, 'Defender'),
(195, 18, 'Rico Henry', 3, 'Defender'),
(196, 18, 'Sepp van den Berg', 4, 'Defender'),
(197, 18, 'Michael Kayode', 33, 'Defender'),
(198, 18, 'Vitaly Janelt', 27, 'Midfielder'),
(409, 18, 'Mathias Jensen', 8, 'Midfielder'),
(410, 18, 'Mikkel Damsgaard', 24, 'Midfielder'),
(411, 18, 'Yehor Yarmoliuk', 18, 'Midfielder'),
(412, 18, 'Fabio Carvalho', 14, 'Midfielder'),
(413, 18, 'Jordan Henderson', 6, 'Midfielder'),
(414, 18, 'Kevin Schade', 7, 'Forward'),
(415, 18, 'Igor Thiago', 9, 'Forward'),
(416, 18, 'Dango Ouattara', 11, 'Forward'),
(417, 18, 'Keane Lewis-Potter', 23, 'Forward'),
(418, 18, 'Gustavo Nunes', 19, 'Forward'),
(419, 18, 'Reiss Nelson', 17, 'Forward'),
-- Leeds United (19) 2025-26 修正版，共20人
(199, 19, 'Lucas Perri', 1, 'Goalkeeper'),
(200, 19, 'Karl Darlow', 26, 'Goalkeeper'),
(201, 19, 'Illan Meslier', 13, 'Goalkeeper'),
(202, 19, 'Jayden Bogle', 2, 'Defender'),
(203, 19, 'Joe Rodon', 6, 'Defender'),
(204, 19, 'Pascal Struijk', 5, 'Defender'),
(205, 19, 'Ethan Ampadu', 4, 'Defender'),
(206, 19, 'Jaka Bijol', 15, 'Defender'),
(207, 19, 'Gabriel Gudmundsson', 3, 'Defender'),
(208, 19, 'Ao Tanaka', 22, 'Midfielder'),
(209, 19, 'Ilia Gruev', 44, 'Midfielder'),
(420, 19, 'Sean Longstaff', 8, 'Midfielder'),
(421, 19, 'Anton Stach', 16, 'Midfielder'),
(422, 19, 'Brenden Aaronson', 11, 'Midfielder'),
(423, 19, 'Daniel James', 7, 'Forward'),
(424, 19, 'Wilfried Gnonto', 29, 'Forward'),
(425, 19, 'Joël Piroe', 10, 'Forward'),
(426, 19, 'Dominic Calvert-Lewin', 9, 'Forward'),
(427, 19, 'Noah Okafor', 19, 'Forward'),
(428, 19, 'Lukas Nmecha', 14, 'Forward'),
-- Everton (20) 2025-26 修正版，共21人
(210, 20, 'Jordan Pickford', 1, 'Goalkeeper'),
(211, 20, 'Asmir Begović', 31, 'Goalkeeper'),
(212, 20, 'Mark Travers', 12, 'Goalkeeper'),
(213, 20, 'Séamus Coleman', 23, 'Defender'),
(214, 20, 'James Tarkowski', 6, 'Defender'),
(215, 20, 'Jarrad Branthwaite', 32, 'Defender'),
(216, 20, 'Vitalii Mykolenko', 19, 'Defender'),
(217, 20, 'Jake O''Brien', 15, 'Defender'),
(218, 20, 'Nathan Patterson', 2, 'Defender'),
(219, 20, 'Michael Keane', 5, 'Defender'),
(220, 20, 'Idrissa Gueye', 27, 'Midfielder'),
(429, 20, 'James Garner', 37, 'Midfielder'),
(430, 20, 'Tim Iroegbunam', 42, 'Midfielder'),
(431, 20, 'Carlos Alcaraz', 24, 'Midfielder'),
(432, 20, 'Kiernan Dewsbury-Hall', 22, 'Midfielder'),
(433, 20, 'Dwight McNeil', 7, 'Forward'),
(434, 20, 'Iliman Ndiaye', 10, 'Forward'),
(435, 20, 'Jack Grealish', 18, 'Forward'),
(436, 20, 'Thierno Barry', 11, 'Forward'),
(437, 20, 'Beto', 14, 'Forward'),
(438, 20, 'Tyler Dibling', 20, 'Forward');



INSERT INTO MatchEvent (event_id, match_id, player_id, related_player_id, minute, stoppage_minute, event_type) VALUES
-- 第1轮
(1, 1, 20, 17, 23, 0, 'goal'),       -- Salah (利物浦)
(2, 1, 20, NULL, 45, 0, 'goal'),      -- Salah
(3, 1, 242, 11, 78, 0, 'goal'),       -- Gakpo (替补) 替换原 Núñez
(4, 1, 20, NULL, 90, 4, 'goal'),      -- Salah
(5, 1, 75, NULL, 56, 0, 'goal'),      -- Solanke (伯恩茅斯)
(6, 1, 76, 72, 82, 0, 'goal'),        -- Kluivert (伯恩茅斯)

-- Match 2 无进球

(7, 3, 108, 105, 34, 0, 'goal'),      -- João Pedro (布莱顿)
(8, 3, 119, NULL, 67, 0, 'goal'),     -- Jiménez (富勒姆)

(9, 4, 64, NULL, 18, 0, 'goal'),      -- Son (热刺)
(10, 4, 65, 61, 52, 0, 'goal'),       -- Richarlison
(11, 4, 292, 64, 79, 0, 'goal'),      -- Kolo Muani (替补) 替换原 Kulusevski

(12, 5, 141, NULL, 22, 0, 'goal'),    -- Clarke (桑德兰)
(13, 5, 142, 140, 45, 0, 'goal'),     -- Rusyn
(14, 5, 367, 141, 74, 0, 'goal'),     -- Talbi (替补) 替换原 Bennette

(15, 6, 54, NULL, 12, 0, 'goal'),     -- Haaland (曼城)
(16, 6, 54, 50, 31, 0, 'goal'),       -- Haaland
(17, 6, 52, 50, 58, 0, 'goal'),       -- Foden
(18, 6, 279, 52, 82, 0, 'goal'),      -- Savinho (替补) 替换原 Bernardo Silva

-- Match 7 无进球

(19, 8, 185, 182, 15, 0, 'goal'),     -- Awoniyi (诺丁汉森林)
(20, 8, 186, NULL, 38, 0, 'goal'),    -- Hudson-Odoi
(21, 8, 187, 182, 67, 0, 'goal'),     -- Elanga
(22, 8, 196, NULL, 55, 0, 'goal'),    -- Toney (布伦特福德)

(23, 9, 24, 28, 13, 0, 'goal'),       -- Saliba (阿森纳)

(24, 10, 207, NULL, 55, 0, 'goal'),   -- Summerville (利兹联)

-- 第2轮
(25, 11, 152, NULL, 10, 0, 'goal'),   -- Bowen (西汉姆)
(26, 11, 41, 39, 18, 0, 'goal'),      -- Palmer (切尔西)
(27, 11, 43, 41, 32, 0, 'goal'),      -- Jackson
(28, 11, 42, NULL, 55, 0, 'goal'),    -- Sterling
(29, 11, 41, 39, 72, 0, 'goal'),      -- Palmer
(30, 11, 266, 42, 88, 0, 'goal'),     -- Neto (替补) 替换原 Jackson

(31, 12, 64, NULL, 27, 0, 'goal'),    -- Son (热刺)
(32, 12, 66, 61, 63, 0, 'goal'),      -- Kulusevski

(33, 13, 75, 72, 44, 0, 'goal'),      -- Solanke (伯恩茅斯)

(34, 14, 196, 193, 38, 0, 'goal'),    -- Toney (布伦特福德)

(35, 15, 130, 127, 29, 0, 'goal'),    -- Foster (伯恩利)
(36, 15, 357, 129, 68, 0, 'goal'),    -- Anthony (替补) 替换原 Amdouni

(37, 16, 31, 28, 12, 0, 'goal'),      -- Saka (阿森纳)
(38, 16, 32, 31, 34, 0, 'goal'),      -- Jesus
(39, 16, 33, 28, 51, 0, 'goal'),      -- Trossard
(40, 16, 31, NULL, 73, 0, 'goal'),    -- Saka
(41, 16, 254, 29, 89, 0, 'goal'),     -- Martinelli (替补) 替换原 Havertz

(42, 17, 218, 217, 23, 0, 'goal'),    -- Calvert-Lewin (埃弗顿)
(43, 17, 437, 218, 67, 0, 'goal'),    -- Beto (替补) 替换原 Harrison

(44, 18, 174, 173, 40, 0, 'goal'),    -- Olise (水晶宫)
(45, 18, 185, 182, 78, 0, 'goal'),    -- Awoniyi (诺丁汉森林)

(46, 19, 119, 117, 33, 0, 'goal'),    -- Jiménez (富勒姆)
(47, 19, 9, 6, 70, 0, 'goal'),        -- Rashford (曼联)

(48, 20, 97, 94, 15, 0, 'goal'),      -- Isak (纽卡斯尔)
(49, 20, 98, 97, 58, 0, 'goal'),      -- Wilson
(50, 20, 20, 18, 30, 0, 'goal'),      -- Salah (利物浦)
(51, 20, 22, 20, 72, 0, 'goal'),      -- Díaz
(52, 20, 243, NULL, 85, 0, 'goal'),
(53, 1, 18, NULL, 31, 0, 'yellow_card'),
(54, 1, 294, NULL, 62, 0, 'yellow_card'),
(55, 2, 81, NULL, 37, 0, 'yellow_card'),
(56, 2, 99, NULL, 69, 0, 'yellow_card'),
(57, 3, 109, NULL, 42, 0, 'yellow_card'),
(58, 3, 117, NULL, 73, 0, 'yellow_card'),
(59, 4, 60, NULL, 28, 0, 'yellow_card'),
(60, 4, 126, NULL, 56, 0, 'yellow_card'),
(61, 5, 143, NULL, 35, 0, 'yellow_card'),
(62, 5, 147, NULL, 79, 0, 'yellow_card'),
(63, 6, 165, NULL, 44, 0, 'yellow_card'),
(64, 6, 55, NULL, 70, 0, 'yellow_card'),
(65, 6, 159, NULL, 84, 0, 'red_card'),
(66, 7, 258, NULL, 52, 0, 'yellow_card'),
(67, 7, 391, NULL, 66, 0, 'yellow_card'),
(68, 8, 187, NULL, 40, 0, 'yellow_card'),
(69, 8, 193, NULL, 78, 0, 'yellow_card'),
(70, 9, 223, NULL, 51, 0, 'yellow_card'),
(71, 9, 245, NULL, 72, 0, 'yellow_card'),
(72, 9, 7, NULL, 88, 0, 'red_card'),
(73, 10, 205, NULL, 47, 0, 'yellow_card'),
(74, 10, 220, NULL, 77, 0, 'yellow_card'),
(75, 11, 370, NULL, 36, 0, 'yellow_card'),
(76, 11, 39, NULL, 58, 0, 'yellow_card'),
(77, 12, 48, NULL, 39, 0, 'yellow_card'),
(78, 12, 281, NULL, 64, 0, 'yellow_card'),
(79, 13, 77, NULL, 29, 0, 'yellow_card'),
(80, 13, 380, NULL, 74, 0, 'yellow_card'),
(81, 14, 198, NULL, 33, 0, 'yellow_card'),
(82, 14, 88, NULL, 81, 0, 'yellow_card'),
(83, 15, 132, NULL, 45, 0, 'yellow_card'),
(84, 15, 143, NULL, 68, 0, 'yellow_card'),
(85, 16, 27, NULL, 41, 0, 'yellow_card'),
(86, 16, 203, NULL, 70, 0, 'yellow_card'),
(87, 17, 214, NULL, 50, 0, 'yellow_card'),
(88, 17, 104, NULL, 76, 0, 'yellow_card'),
(89, 18, 170, NULL, 27, 0, 'yellow_card'),
(90, 18, 186, NULL, 59, 0, 'yellow_card'),
(91, 19, 117, NULL, 48, 0, 'yellow_card'),
(92, 19, 224, NULL, 71, 0, 'yellow_card'),
(93, 20, 317, NULL, 54, 0, 'yellow_card'),
(94, 20, 19, NULL, 82, 0, 'yellow_card');   -- Jota (替补) 替换原 Núñez








-- Match 1: Liverpool 4-2 Bournemouth (2025-08-15)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(1, 12, TRUE, 0, 90), (1, 13, TRUE, 0, 90), (1, 14, TRUE, 0, 90), (1, 15, TRUE, 0, 90),
(1, 16, TRUE, 0, 72), (1, 17, TRUE, 0, 65), (1, 18, TRUE, 0, 58), (1, 19, TRUE, 0, 90),
(1, 20, TRUE, 0, 82), (1, 21, TRUE, 0, 90), (1, 22, TRUE, 0, 72),
(1, 235, FALSE, 72, 90),   -- Joe Gomez 换下 Konaté
(1, 239, FALSE, 58, 90),   -- Endo 换下 Mac Allister
(1, 244, FALSE, 65, 90),   -- Chiesa 换下 Szoboszlai
(1, 243, FALSE, 82, 90),   -- Jota 换下 Salah
(1, 242, FALSE, 72, 90),   -- Gakpo 换下 Díaz
(1, 67, TRUE, 0, 90), (1, 68, TRUE, 0, 90), (1, 69, TRUE, 0, 90), (1, 70, TRUE, 0, 45),
(1, 71, TRUE, 0, 90), (1, 72, TRUE, 0, 67), (1, 73, TRUE, 0, 90), (1, 74, TRUE, 0, 59),
(1, 75, TRUE, 0, 90), (1, 76, TRUE, 0, 90), (1, 77, TRUE, 0, 85),
(1, 296, FALSE, 45, 90),   -- James Hill 换下 Aarons
(1, 299, FALSE, 67, 90),   -- Christie 换下 Billing
(1, 301, FALSE, 59, 90),   -- Tavernier 换下 Scott
(1, 303, FALSE, 85, 90);   -- Moore 换下 Ouattara

-- Match 2: Aston Villa 0-0 Newcastle (2025-08-16)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(2, 78, TRUE, 0, 90), (2, 79, TRUE, 0, 90), (2, 80, TRUE, 0, 90), (2, 81, TRUE, 0, 90),
(2, 82, TRUE, 0, 78), (2, 83, TRUE, 0, 72), (2, 84, TRUE, 0, 90), (2, 85, TRUE, 0, 65),
(2, 86, TRUE, 0, 90), (2, 87, TRUE, 0, 80), (2, 88, TRUE, 0, 67),
(2, 308, FALSE, 78, 90),   -- Mings 换下 Digne
(2, 311, FALSE, 72, 90),   -- Barkley 换下 McGinn
(2, 313, FALSE, 65, 90),   -- Buendía 换下 Tielemans
(2, 315, FALSE, 80, 90),   -- Abraham 换下 Diaby
(2, 316, FALSE, 67, 90),   -- Durán 换下 Bailey
(2, 89, TRUE, 0, 90), (2, 90, TRUE, 0, 90), (2, 91, TRUE, 0, 90), (2, 92, TRUE, 0, 90),
(2, 93, TRUE, 0, 72), (2, 94, TRUE, 0, 90), (2, 95, TRUE, 0, 68), (2, 96, TRUE, 0, 80),
(2, 97, TRUE, 0, 90), (2, 98, TRUE, 0, 75), (2, 99, TRUE, 0, 62),
(2, 319, FALSE, 72, 90),   -- Hall 换下 Burn
(2, 323, FALSE, 68, 90),   -- Willock 换下 Longstaff
(2, 322, FALSE, 80, 90),   -- Tonali 换下 Joelinton
(2, 325, FALSE, 75, 90),   -- Barnes 换下 Wilson
(2, 327, FALSE, 62, 90);   -- Murphy 换下 Almirón

-- Match 3: Brighton 1-1 Fulham (2025-08-16)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(3, 100, TRUE, 0, 90), (3, 101, TRUE, 0, 90), (3, 102, TRUE, 0, 90), (3, 103, TRUE, 0, 85),
(3, 104, TRUE, 0, 76), (3, 105, TRUE, 0, 90), (3, 106, TRUE, 0, 70), (3, 107, TRUE, 0, 62),
(3, 108, TRUE, 0, 90), (3, 109, TRUE, 0, 78), (3, 110, TRUE, 0, 55),
(3, 330, FALSE, 85, 90),   -- Kadıoğlu 换下 Estupiñán
(3, 333, FALSE, 76, 90),   -- Wieffer 换下 Veltman
(3, 337, FALSE, 70, 90),   -- Enciso 换下 Baleba
(3, 335, FALSE, 62, 90),   -- Welbeck 换下 Adingra
(3, 336, FALSE, 55, 90),   -- Rutter 换下 Ferguson
(3, 111, TRUE, 0, 90), (3, 112, TRUE, 0, 90), (3, 113, TRUE, 0, 90), (3, 114, TRUE, 0, 90),
(3, 115, TRUE, 0, 82), (3, 116, TRUE, 0, 90), (3, 117, TRUE, 0, 68), (3, 118, TRUE, 0, 73),
(3, 119, TRUE, 0, 90), (3, 120, TRUE, 0, 78), (3, 121, TRUE, 0, 60),
(3, 340, FALSE, 82, 90),   -- Tete 换下 Castagne
(3, 344, FALSE, 68, 90),   -- Wilson 换下 Pereira
(3, 346, FALSE, 73, 90),   -- Cairney 换下 Lukic
(3, 347, FALSE, 78, 90),   -- Traoré 换下 Willian
(3, 348, FALSE, 60, 90);   -- Vinícius 换下 De Cordova-Reid

-- Match 4: Tottenham 3-0 Burnley (2025-08-16)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(4, 56, TRUE, 0, 90), (4, 57, TRUE, 0, 90), (4, 58, TRUE, 0, 90), (4, 59, TRUE, 0, 78),
(4, 60, TRUE, 0, 90), (4, 61, TRUE, 0, 70), (4, 62, TRUE, 0, 82), (4, 63, TRUE, 0, 66),
(4, 64, TRUE, 0, 90), (4, 65, TRUE, 0, 74), (4, 66, TRUE, 0, 90),
(4, 286, FALSE, 78, 90),   -- Spence 换下 Porro
(4, 288, FALSE, 70, 90),   -- Bentancur 换下 Maddison
(4, 289, FALSE, 82, 90),   -- Palhinha 换下 Bissouma
(4, 292, FALSE, 74, 90),   -- Kolo Muani 换下 Richarlison
(4, 293, FALSE, 66, 90),   -- Kudus 换下 Sarr
(4, 122, TRUE, 0, 90), (4, 123, TRUE, 0, 90), (4, 124, TRUE, 0, 76), (4, 125, TRUE, 0, 90),
(4, 126, TRUE, 0, 68), (4, 127, TRUE, 0, 90), (4, 128, TRUE, 0, 72), (4, 129, TRUE, 0, 63),
(4, 130, TRUE, 0, 90), (4, 131, TRUE, 0, 78), (4, 132, TRUE, 0, 55),
(4, 351, FALSE, 76, 90),   -- Walker-Peters 换下 Al-Dakhil
(4, 354, FALSE, 68, 90),   -- Delcroix 换下 Roberts
(4, 355, FALSE, 72, 90),   -- Berge 换下 Brownhill
(4, 357, FALSE, 63, 90),   -- Anthony 换下 Cullen
(4, 359, FALSE, 55, 90);   -- Foster 换下 Gudmundsson

-- Match 5: Sunderland 3-0 West Ham (2025-08-16)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(5, 133, TRUE, 0, 90), (5, 134, TRUE, 0, 90), (5, 135, TRUE, 0, 90), (5, 136, TRUE, 0, 82),
(5, 137, TRUE, 0, 88), (5, 138, TRUE, 0, 72), (5, 139, TRUE, 0, 65), (5, 140, TRUE, 0, 78),
(5, 141, TRUE, 0, 90), (5, 142, TRUE, 0, 70), (5, 143, TRUE, 0, 60),
(5, 362, FALSE, 82, 90),   -- Alderete 换下 O'Nien
(5, 364, FALSE, 88, 90),   -- Muslija 换下 Cirkin
(5, 366, FALSE, 72, 90),   -- Sadiqi 换下 Neil
(5, 365, FALSE, 65, 90),   -- Xhaka 换下 Ekwah
(5, 367, FALSE, 60, 90),   -- Talbi 换下 Bennette
(5, 144, TRUE, 0, 90), (5, 145, TRUE, 0, 90), (5, 146, TRUE, 0, 90), (5, 147, TRUE, 0, 78),
(5, 148, TRUE, 0, 68), (5, 149, TRUE, 0, 90), (5, 150, TRUE, 0, 72), (5, 151, TRUE, 0, 65),
(5, 152, TRUE, 0, 90), (5, 153, TRUE, 0, 80), (5, 154, TRUE, 0, 55),
(5, 376, FALSE, 78, 90),   -- Cresswell 换下 Emerson
(5, 375, FALSE, 68, 90),   -- Souček 换下 Coufal
(5, 377, FALSE, 72, 90),   -- Summerville 换下 Ward-Prowse
(5, 379, FALSE, 65, 90),   -- Antonio 换下 Paquetá
(5, 378, FALSE, 55, 90);   -- Guilherme 换下 Kudus

-- Match 6: Wolves 0-4 Man City (2025-08-16)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(6, 155, TRUE, 0, 90), (6, 156, TRUE, 0, 90), (6, 157, TRUE, 0, 82), (6, 158, TRUE, 0, 72),
(6, 159, TRUE, 0, 90), (6, 160, TRUE, 0, 68), (6, 161, TRUE, 0, 76), (6, 162, TRUE, 0, 62),
(6, 163, TRUE, 0, 90), (6, 164, TRUE, 0, 78), (6, 165, TRUE, 0, 55),
(6, 384, FALSE, 82, 90),   -- Toti 换下 Dawson
(6, 382, FALSE, 72, 90),   -- Bueno 换下 Semedo
(6, 386, FALSE, 76, 90),   -- Doyle 换下 Lemina
(6, 387, FALSE, 62, 90),   -- Bellegarde 换下 Sarabia
(6, 389, FALSE, 55, 90),   -- Kalajdzic 换下 Neto
(6, 45, TRUE, 0, 90), (6, 46, TRUE, 0, 90), (6, 47, TRUE, 0, 82), (6, 48, TRUE, 0, 75),
(6, 49, TRUE, 0, 90), (6, 50, TRUE, 0, 70), (6, 51, TRUE, 0, 78), (6, 52, TRUE, 0, 90),
(6, 53, TRUE, 0, 68), (6, 54, TRUE, 0, 90), (6, 55, TRUE, 0, 60),
(6, 271, FALSE, 82, 90),   -- Aké 换下 Stones
(6, 273, FALSE, 75, 90),   -- Khusanov 换下 Walker
(6, 275, FALSE, 70, 90),   -- Reijnders 换下 De Bruyne
(6, 276, FALSE, 78, 90),   -- Cherki 换下 Rodri
(6, 277, FALSE, 60, 90);   -- Marmoush 换下 Doku

-- Match 7: Chelsea 0-0 Crystal Palace (2025-08-17)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(7, 34, TRUE, 0, 90), (7, 35, TRUE, 0, 82), (7, 36, TRUE, 0, 90), (7, 37, TRUE, 0, 72),
(7, 38, TRUE, 0, 78), (7, 39, TRUE, 0, 90), (7, 40, TRUE, 0, 85), (7, 41, TRUE, 0, 90),
(7, 42, TRUE, 0, 68), (7, 43, TRUE, 0, 75), (7, 44, TRUE, 0, 60),
(7, 263, FALSE, 82, 90),   -- Fofana 换下 James
(7, 262, FALSE, 72, 90),   -- Chalobah 换下 Gusto
(7, 259, FALSE, 78, 90),   -- Cucurella 换下 Chilwell
(7, 268, FALSE, 85, 90),   -- Lavia 换下 Caicedo
(7, 266, FALSE, 60, 90),   -- Neto 换下 Mudryk
(7, 166, TRUE, 0, 90), (7, 167, TRUE, 0, 90), (7, 168, TRUE, 0, 90), (7, 169, TRUE, 0, 88),
(7, 170, TRUE, 0, 76), (7, 171, TRUE, 0, 90), (7, 172, TRUE, 0, 72), (7, 173, TRUE, 0, 82),
(7, 174, TRUE, 0, 90), (7, 175, TRUE, 0, 68), (7, 176, TRUE, 0, 60),
(7, 394, FALSE, 76, 90),   -- Muñoz 换下 Mitchell
(7, 395, FALSE, 72, 90),   -- Schlupp 换下 Doucouré
(7, 396, FALSE, 82, 90),   -- Wharton 换下 Eze
(7, 398, FALSE, 68, 90),   -- Édouard 换下 Mateta
(7, 399, FALSE, 60, 90);   -- França 换下 Ayew

-- Match 8: Nott'm Forest 3-1 Brentford (2025-08-17)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(8, 177, TRUE, 0, 90), (8, 178, TRUE, 0, 90), (8, 179, TRUE, 0, 90), (8, 180, TRUE, 0, 78),
(8, 181, TRUE, 0, 85), (8, 182, TRUE, 0, 90), (8, 183, TRUE, 0, 72), (8, 184, TRUE, 0, 65),
(8, 185, TRUE, 0, 90), (8, 186, TRUE, 0, 68), (8, 187, TRUE, 0, 75),
(8, 402, FALSE, 78, 90),   -- Milenković 换下 Williams
(8, 404, FALSE, 85, 90),   -- Williams 换下 Aina
(8, 406, FALSE, 72, 90),   -- Anderson 换下 Yates
(8, 407, FALSE, 65, 90),   -- Ribeiro 换下 Danilo
(8, 408, FALSE, 68, 90),   -- Wood 换下 Hudson-Odoi
(8, 188, TRUE, 0, 90), (8, 189, TRUE, 0, 82), (8, 190, TRUE, 0, 90), (8, 191, TRUE, 0, 90),
(8, 192, TRUE, 0, 72), (8, 193, TRUE, 0, 68), (8, 194, TRUE, 0, 76), (8, 195, TRUE, 0, 63),
(8, 196, TRUE, 0, 90), (8, 197, TRUE, 0, 78), (8, 198, TRUE, 0, 55),
(8, 413, FALSE, 82, 90),   -- Hickey 换下 Ajer
(8, 411, FALSE, 72, 90),   -- van den Berg 换下 Henry
(8, 415, FALSE, 76, 90),   -- Damsgaard 换下 Jensen
(8, 414, FALSE, 63, 90),   -- Schade 换下 Janelt
(8, 417, FALSE, 55, 90);   -- Thiago 换下 Wissa

-- Match 9: Man Utd 0-1 Arsenal (2025-08-17)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(9, 1, TRUE, 0, 90), (9, 2, TRUE, 0, 90), (9, 3, TRUE, 0, 90), (9, 4, TRUE, 0, 78),
(9, 5, TRUE, 0, 85), (9, 6, TRUE, 0, 90), (9, 7, TRUE, 0, 72), (9, 8, TRUE, 0, 68),
(9, 9, TRUE, 0, 82), (9, 10, TRUE, 0, 75), (9, 11, TRUE, 0, 62),
(9, 223, FALSE, 78, 90),   -- Maguire 换下 Dalot
(9, 226, FALSE, 85, 90),   -- Mazraoui 换下 Shaw
(9, 228, FALSE, 72, 90),   -- Ugarte 换下 Mainoo
(9, 227, FALSE, 68, 90),   -- Mount 换下 Casemiro
(9, 232, FALSE, 62, 90),   -- Zirkzee 换下 Garnacho
(9, 23, TRUE, 0, 90), (9, 24, TRUE, 0, 90), (9, 25, TRUE, 0, 90), (9, 26, TRUE, 0, 82),
(9, 27, TRUE, 0, 76), (9, 28, TRUE, 0, 90), (9, 29, TRUE, 0, 78), (9, 30, TRUE, 0, 68),
(9, 31, TRUE, 0, 85), (9, 32, TRUE, 0, 72), (9, 33, TRUE, 0, 62),
(9, 249, FALSE, 82, 90),   -- Timber 换下 White
(9, 250, FALSE, 76, 90),   -- Calafiori 换下 Zinchenko
(9, 252, FALSE, 78, 90),   -- Zubimendi 换下 Rice
(9, 253, FALSE, 68, 90),   -- Eze 换下 Havertz
(9, 254, FALSE, 62, 90);   -- Martinelli 换下 Trossard

-- Match 10: Leeds United 1-0 Everton (2025-08-19)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(10, 199, TRUE, 0, 90), (10, 200, TRUE, 0, 90), (10, 201, TRUE, 0, 90), (10, 202, TRUE, 0, 78),
(10, 203, TRUE, 0, 85), (10, 204, TRUE, 0, 72), (10, 205, TRUE, 0, 68), (10, 206, TRUE, 0, 76),
(10, 207, TRUE, 0, 90), (10, 208, TRUE, 0, 70), (10, 209, TRUE, 0, 60),
(10, 421, FALSE, 78, 90),   -- Rodon 换下 Ayling
(10, 423, FALSE, 85, 90),   -- Østigård 换下 Firpo
(10, 425, FALSE, 72, 90),   -- Tanaka 换下 Kamara
(10, 424, FALSE, 68, 90),   -- Aaronson 换下 Rutter
(10, 426, FALSE, 60, 90),   -- Okafor 换下 Bamford
(10, 210, TRUE, 0, 90), (10, 211, TRUE, 0, 90), (10, 212, TRUE, 0, 90), (10, 213, TRUE, 0, 82),
(10, 214, TRUE, 0, 76), (10, 215, TRUE, 0, 90), (10, 216, TRUE, 0, 68), (10, 217, TRUE, 0, 72),
(10, 218, TRUE, 0, 85), (10, 219, TRUE, 0, 65), (10, 220, TRUE, 0, 60),
(10, 430, FALSE, 82, 90),   -- Keane 换下 Coleman
(10, 431, FALSE, 76, 90),   -- O'Brien 换下 Mykolenko
(10, 433, FALSE, 68, 90),   -- Garner 换下 Gueye
(10, 434, FALSE, 72, 90),   -- Dewsbury-Hall 换下 McNeil
(10, 437, FALSE, 60, 90);   -- Beto 换下 Danjuma

-- ============================================================
-- 第2轮 MatchAppearance 详细记录
-- ============================================================

-- Match 11: West Ham 1-5 Chelsea (2025-08-22)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(11, 144, TRUE, 0, 90), (11, 145, TRUE, 0, 90), (11, 146, TRUE, 0, 78), (11, 147, TRUE, 0, 72),
(11, 148, TRUE, 0, 68), (11, 149, TRUE, 0, 90), (11, 150, TRUE, 0, 65), (11, 151, TRUE, 0, 75),
(11, 152, TRUE, 0, 90), (11, 153, TRUE, 0, 80), (11, 154, TRUE, 0, 60),
(11, 372, FALSE, 78, 90),   -- Walker-Peters 换下 Aguerd
(11, 375, FALSE, 72, 90),   -- Souček 换下 Emerson
(11, 376, FALSE, 68, 90),   -- Cresswell 换下 Coufal
(11, 379, FALSE, 65, 90),   -- Antonio 换下 Ward-Prowse
(11, 378, FALSE, 60, 90),   -- Guilherme 换下 Kudus
(11, 34, TRUE, 0, 90), (11, 35, TRUE, 0, 82), (11, 36, TRUE, 0, 90), (11, 37, TRUE, 0, 72),
(11, 38, TRUE, 0, 76), (11, 39, TRUE, 0, 90), (11, 40, TRUE, 0, 85), (11, 41, TRUE, 0, 88),
(11, 42, TRUE, 0, 70), (11, 43, TRUE, 0, 78), (11, 44, TRUE, 0, 62),
(11, 263, FALSE, 82, 90),   -- Fofana 换下 James
(11, 262, FALSE, 72, 90),   -- Chalobah 换下 Gusto
(11, 259, FALSE, 76, 90),   -- Cucurella 换下 Chilwell
(11, 268, FALSE, 85, 90),   -- Lavia 换下 Caicedo
(11, 266, FALSE, 62, 90);   -- Neto 换下 Mudryk

-- Match 12: Man City 0-2 Tottenham (2025-08-23)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(12, 45, TRUE, 0, 90), (12, 46, TRUE, 0, 90), (12, 47, TRUE, 0, 82), (12, 48, TRUE, 0, 76),
(12, 49, TRUE, 0, 90), (12, 50, TRUE, 0, 72), (12, 51, TRUE, 0, 68), (12, 52, TRUE, 0, 78),
(12, 53, TRUE, 0, 65), (12, 54, TRUE, 0, 90), (12, 55, TRUE, 0, 60),
(12, 271, FALSE, 82, 90),   -- Aké 换下 Stones
(12, 273, FALSE, 76, 90),   -- Khusanov 换下 Walker
(12, 275, FALSE, 72, 90),   -- Reijnders 换下 De Bruyne
(12, 276, FALSE, 68, 90),   -- Cherki 换下 Rodri
(12, 279, FALSE, 60, 90),   -- Savinho 换下 Doku
(12, 56, TRUE, 0, 90), (12, 57, TRUE, 0, 90), (12, 58, TRUE, 0, 90), (12, 59, TRUE, 0, 78),
(12, 60, TRUE, 0, 85), (12, 61, TRUE, 0, 72), (12, 62, TRUE, 0, 82), (12, 63, TRUE, 0, 68),
(12, 64, TRUE, 0, 90), (12, 65, TRUE, 0, 76), (12, 66, TRUE, 0, 88),
(12, 286, FALSE, 78, 90),   -- Spence 换下 Porro
(12, 288, FALSE, 72, 90),   -- Bentancur 换下 Maddison
(12, 289, FALSE, 82, 90),   -- Palhinha 换下 Bissouma
(12, 293, FALSE, 76, 90),   -- Kudus 换下 Richarlison
(12, 291, FALSE, 68, 90);   -- Simons 换下 Sarr

-- Match 13: Bournemouth 1-0 Wolves (2025-08-23)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(13, 67, TRUE, 0, 90), (13, 68, TRUE, 0, 90), (13, 69, TRUE, 0, 90), (13, 70, TRUE, 0, 78),
(13, 71, TRUE, 0, 85), (13, 72, TRUE, 0, 72), (13, 73, TRUE, 0, 68), (13, 74, TRUE, 0, 76),
(13, 75, TRUE, 0, 90), (13, 76, TRUE, 0, 80), (13, 77, TRUE, 0, 62),
(13, 296, FALSE, 78, 90),   -- Hill 换下 Aarons
(13, 299, FALSE, 72, 90),   -- Christie 换下 Billing
(13, 301, FALSE, 68, 90),   -- Tavernier 换下 Cook
(13, 302, FALSE, 80, 90),   -- Brooks 换下 Kluivert
(13, 304, FALSE, 62, 90),   -- Ünal 换下 Ouattara
(13, 155, TRUE, 0, 90), (13, 156, TRUE, 0, 90), (13, 157, TRUE, 0, 82), (13, 158, TRUE, 0, 72),
(13, 159, TRUE, 0, 90), (13, 160, TRUE, 0, 68), (13, 161, TRUE, 0, 76), (13, 162, TRUE, 0, 65),
(13, 163, TRUE, 0, 90), (13, 164, TRUE, 0, 78), (13, 165, TRUE, 0, 60),
(13, 384, FALSE, 82, 90),   -- Toti 换下 Dawson
(13, 382, FALSE, 72, 90),   -- Bueno 换下 Semedo
(13, 386, FALSE, 76, 90),   -- Doyle 换下 Lemina
(13, 387, FALSE, 65, 90),   -- Bellegarde 换下 Sarabia
(13, 389, FALSE, 60, 90);   -- Kalajdzic 换下 Neto

-- Match 14: Brentford 1-0 Aston Villa (2025-08-23)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(14, 188, TRUE, 0, 90), (14, 189, TRUE, 0, 82), (14, 190, TRUE, 0, 90), (14, 191, TRUE, 0, 90),
(14, 192, TRUE, 0, 76), (14, 193, TRUE, 0, 72), (14, 194, TRUE, 0, 68), (14, 195, TRUE, 0, 78),
(14, 196, TRUE, 0, 90), (14, 197, TRUE, 0, 75), (14, 198, TRUE, 0, 62),
(14, 413, FALSE, 82, 90),   -- Hickey 换下 Ajer
(14, 411, FALSE, 76, 90),   -- van den Berg 换下 Henry
(14, 415, FALSE, 72, 90),   -- Damsgaard 换下 Nørgaard
(14, 416, FALSE, 68, 90),   -- Konak 换下 Jensen
(14, 417, FALSE, 62, 90),   -- Thiago 换下 Wissa
(14, 78, TRUE, 0, 90), (14, 79, TRUE, 0, 90), (14, 80, TRUE, 0, 90), (14, 81, TRUE, 0, 78),
(14, 82, TRUE, 0, 85), (14, 83, TRUE, 0, 72), (14, 84, TRUE, 0, 68), (14, 85, TRUE, 0, 76),
(14, 86, TRUE, 0, 90), (14, 87, TRUE, 0, 70), (14, 88, TRUE, 0, 65),
(14, 308, FALSE, 85, 90),   -- Mings 换下 Digne
(14, 311, FALSE, 72, 90),   -- Barkley 换下 McGinn
(14, 313, FALSE, 68, 90),   -- Buendía 换下 Luiz
(14, 315, FALSE, 76, 90),   -- Abraham 换下 Tielemans
(14, 316, FALSE, 65, 90);   -- Durán 换下 Bailey

-- Match 15: Burnley 2-0 Sunderland (2025-08-23)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(15, 122, TRUE, 0, 90), (15, 123, TRUE, 0, 90), (15, 124, TRUE, 0, 82), (15, 125, TRUE, 0, 90),
(15, 126, TRUE, 0, 72), (15, 127, TRUE, 0, 68), (15, 128, TRUE, 0, 76), (15, 129, TRUE, 0, 65),
(15, 130, TRUE, 0, 90), (15, 131, TRUE, 0, 78), (15, 132, TRUE, 0, 60),
(15, 351, FALSE, 82, 90),   -- Walker-Peters 换下 Al-Dakhil
(15, 354, FALSE, 72, 90),   -- Delcroix 换下 Roberts
(15, 355, FALSE, 76, 90),   -- Berge 换下 Brownhill
(15, 356, FALSE, 65, 90),   -- Mejbri 换下 Cullen
(15, 357, FALSE, 60, 90),   -- Anthony 换下 Gudmundsson
(15, 133, TRUE, 0, 90), (15, 134, TRUE, 0, 90), (15, 135, TRUE, 0, 90), (15, 136, TRUE, 0, 82),
(15, 137, TRUE, 0, 88), (15, 138, TRUE, 0, 72), (15, 139, TRUE, 0, 68), (15, 140, TRUE, 0, 76),
(15, 141, TRUE, 0, 90), (15, 142, TRUE, 0, 70), (15, 143, TRUE, 0, 62),
(15, 362, FALSE, 82, 90),   -- Alderete 换下 O'Nien
(15, 364, FALSE, 88, 90),   -- Muslija 换下 Cirkin
(15, 366, FALSE, 72, 90),   -- Sadiqi 换下 Neil
(15, 365, FALSE, 68, 90),   -- Xhaka 换下 Ekwah
(15, 367, FALSE, 62, 90);   -- Talbi 换下 Bennette

-- Match 16: Arsenal 5-0 Leeds United (2025-08-23)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(16, 23, TRUE, 0, 90), (16, 24, TRUE, 0, 90), (16, 25, TRUE, 0, 82), (16, 26, TRUE, 0, 76),
(16, 27, TRUE, 0, 85), (16, 28, TRUE, 0, 72), (16, 29, TRUE, 0, 68), (16, 30, TRUE, 0, 78),
(16, 31, TRUE, 0, 88), (16, 32, TRUE, 0, 70), (16, 33, TRUE, 0, 75),
(16, 249, FALSE, 82, 90),   -- Timber 换下 Saliba
(16, 250, FALSE, 76, 90),   -- Calafiori 换下 White
(16, 252, FALSE, 85, 90),   -- Zubimendi 换下 Zinchenko
(16, 253, FALSE, 68, 90),   -- Eze 换下 Rice
(16, 254, FALSE, 70, 90),   -- Martinelli 换下 Jesus
(16, 199, TRUE, 0, 90), (16, 200, TRUE, 0, 90), (16, 201, TRUE, 0, 82), (16, 202, TRUE, 0, 78),
(16, 203, TRUE, 0, 85), (16, 204, TRUE, 0, 72), (16, 205, TRUE, 0, 68), (16, 206, TRUE, 0, 76),
(16, 207, TRUE, 0, 90), (16, 208, TRUE, 0, 70), (16, 209, TRUE, 0, 62),
(16, 421, FALSE, 82, 90),   -- Rodon 换下 Struijk
(16, 423, FALSE, 78, 90),   -- Østigård 换下 Ayling
(16, 425, FALSE, 85, 90),   -- Tanaka 换下 Firpo
(16, 424, FALSE, 72, 90),   -- Aaronson 换下 Kamara
(16, 426, FALSE, 62, 90);   -- Okafor 换下 Bamford

-- Match 17: Everton 2-0 Brighton (2025-08-24)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(17, 210, TRUE, 0, 90), (17, 211, TRUE, 0, 90), (17, 212, TRUE, 0, 90), (17, 213, TRUE, 0, 82),
(17, 214, TRUE, 0, 78), (17, 215, TRUE, 0, 72), (17, 216, TRUE, 0, 68), (17, 217, TRUE, 0, 76),
(17, 218, TRUE, 0, 85), (17, 219, TRUE, 0, 70), (17, 220, TRUE, 0, 62),
(17, 430, FALSE, 82, 90),   -- Keane 换下 Coleman
(17, 431, FALSE, 78, 90),   -- O'Brien 换下 Mykolenko
(17, 433, FALSE, 72, 90),   -- Garner 换下 Onana
(17, 434, FALSE, 68, 90),   -- Dewsbury-Hall 换下 Gueye
(17, 437, FALSE, 62, 90),   -- Beto 换下 Danjuma
(17, 100, TRUE, 0, 90), (17, 101, TRUE, 0, 90), (17, 102, TRUE, 0, 90), (17, 103, TRUE, 0, 82),
(17, 104, TRUE, 0, 76), (17, 105, TRUE, 0, 90), (17, 106, TRUE, 0, 70), (17, 107, TRUE, 0, 68),
(17, 108, TRUE, 0, 78), (17, 109, TRUE, 0, 72), (17, 110, TRUE, 0, 60),
(17, 330, FALSE, 82, 90),   -- Kadıoğlu 换下 Estupiñán
(17, 333, FALSE, 76, 90),   -- Wieffer 换下 Veltman
(17, 334, FALSE, 68, 90),   -- Minteh 换下 Adingra
(17, 335, FALSE, 72, 90),   -- Welbeck 换下 Mitoma
(17, 336, FALSE, 60, 90);   -- Rutter 换下 Ferguson

-- Match 18: Crystal Palace 1-1 Nott'm Forest (2025-08-24)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(18, 166, TRUE, 0, 90), (18, 167, TRUE, 0, 90), (18, 168, TRUE, 0, 90), (18, 169, TRUE, 0, 82),
(18, 170, TRUE, 0, 76), (18, 171, TRUE, 0, 90), (18, 172, TRUE, 0, 72), (18, 173, TRUE, 0, 68),
(18, 174, TRUE, 0, 88), (18, 175, TRUE, 0, 70), (18, 176, TRUE, 0, 62),
(18, 394, FALSE, 82, 90),   -- Muñoz 换下 Mitchell
(18, 395, FALSE, 76, 90),   -- Schlupp 换下 Doucouré
(18, 396, FALSE, 72, 90),   -- Wharton 换下 Eze
(18, 398, FALSE, 68, 90),   -- Édouard 换下 Schlupp
(18, 399, FALSE, 62, 90),   -- França 换下 Ayew
(18, 177, TRUE, 0, 90), (18, 178, TRUE, 0, 90), (18, 179, TRUE, 0, 90), (18, 180, TRUE, 0, 78),
(18, 181, TRUE, 0, 85), (18, 182, TRUE, 0, 90), (18, 183, TRUE, 0, 72), (18, 184, TRUE, 0, 68),
(18, 185, TRUE, 0, 90), (18, 186, TRUE, 0, 70), (18, 187, TRUE, 0, 76),
(18, 402, FALSE, 78, 90),   -- Milenković 换下 Williams
(18, 404, FALSE, 85, 90),   -- Williams 换下 Aina
(18, 406, FALSE, 72, 90),   -- Anderson 换下 Yates
(18, 407, FALSE, 68, 90),   -- Ribeiro 换下 Danilo
(18, 408, FALSE, 70, 90);   -- Wood 换下 Hudson-Odoi

-- Match 19: Fulham 1-1 Man Utd (2025-08-24)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(19, 111, TRUE, 0, 90), (19, 112, TRUE, 0, 90), (19, 113, TRUE, 0, 90), (19, 114, TRUE, 0, 82),
(19, 115, TRUE, 0, 76), (19, 116, TRUE, 0, 90), (19, 117, TRUE, 0, 72), (19, 118, TRUE, 0, 68),
(19, 119, TRUE, 0, 88), (19, 120, TRUE, 0, 70), (19, 121, TRUE, 0, 62),
(19, 340, FALSE, 82, 90),   -- Tete 换下 Castagne
(19, 344, FALSE, 76, 90),   -- Wilson 换下 Pereira
(19, 346, FALSE, 72, 90),   -- Cairney 换下 Lukic
(19, 347, FALSE, 68, 90),   -- Traoré 换下 De Cordova-Reid
(19, 348, FALSE, 62, 90),   -- Vinícius 换下 Willian
(19, 1, TRUE, 0, 90), (19, 2, TRUE, 0, 90), (19, 3, TRUE, 0, 90), (19, 4, TRUE, 0, 78),
(19, 5, TRUE, 0, 85), (19, 6, TRUE, 0, 90), (19, 7, TRUE, 0, 72), (19, 8, TRUE, 0, 68),
(19, 9, TRUE, 0, 82), (19, 10, TRUE, 0, 76), (19, 11, TRUE, 0, 62),
(19, 223, FALSE, 78, 90),   -- Maguire 换下 Dalot
(19, 226, FALSE, 85, 90),   -- Mazraoui 换下 Shaw
(19, 228, FALSE, 72, 90),   -- Ugarte 换下 Mainoo
(19, 227, FALSE, 68, 90),   -- Mount 换下 Casemiro
(19, 232, FALSE, 62, 90);   -- Zirkzee 换下 Garnacho

-- Match 20: Newcastle 2-3 Liverpool (2025-08-25)
INSERT INTO MatchAppearance (match_id, player_id, is_starting, minute_on, minute_off) VALUES
(20, 89, TRUE, 0, 90), (20, 90, TRUE, 0, 90), (20, 91, TRUE, 0, 90), (20, 92, TRUE, 0, 82),
(20, 93, TRUE, 0, 76), (20, 94, TRUE, 0, 90), (20, 95, TRUE, 0, 72), (20, 96, TRUE, 0, 68),
(20, 97, TRUE, 0, 88), (20, 98, TRUE, 0, 70), (20, 99, TRUE, 0, 62),
(20, 319, FALSE, 82, 90),   -- Hall 换下 Schär
(20, 320, FALSE, 76, 90),   -- Lascelles 换下 Burn
(20, 323, FALSE, 72, 90),   -- Willock 换下 Longstaff
(20, 322, FALSE, 68, 90),   -- Tonali 换下 Joelinton
(20, 326, FALSE, 62, 90),   -- Gordon 换下 Almirón
(20, 12, TRUE, 0, 90), (20, 13, TRUE, 0, 90), (20, 14, TRUE, 0, 90), (20, 15, TRUE, 0, 85),
(20, 16, TRUE, 0, 72), (20, 17, TRUE, 0, 68), (20, 18, TRUE, 0, 76), (20, 19, TRUE, 0, 78),
(20, 20, TRUE, 0, 82), (20, 21, TRUE, 0, 90), (20, 22, TRUE, 0, 70),
(20, 235, FALSE, 85, 90),   -- Gomez 换下 Robertson
(20, 237, FALSE, 72, 90),   -- Quansah 换下 Konaté
(20, 239, FALSE, 68, 90),   -- Endo 换下 Szoboszlai
(20, 241, FALSE, 76, 90),   -- Elliott 换下 Mac Allister
(20, 243, FALSE, 82, 90);   -- Jota 换下 Salah

COMMIT;