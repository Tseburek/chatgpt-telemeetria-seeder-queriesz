
/* ——————————————————- 1. Päring: Kõige aktiivsemad kasutajad (sõnumite
arv) Eesmärk: Admin näeb, millised kasutajad on platvormil kõige
aktiivsemad. Oodatav tulemus: Tagastab kasutajanime ja tema saadetud
sõnumite koguarvu. Kasutatud: JOIN, GROUP BY, ORDER BY,
agregaatfunktsioon COUNT() ——————————————————–*/ SELECT u.username AS
kasutaja, COUNT(m.id) AS saadetud_sonumeid FROM users u JOIN messages m
ON u.id = m.userId GROUP BY u.id, u.username HAVING COUNT(m.id) > 0
ORDER BY saadetud_sonumeid DESC;

/* ——————————————————- 2. Päring: Vestlused koos viimase sõnumiga
Eesmärk: Kasutaja või admin saab kiiresti näha iga vestluse viimast
sõnumit. Oodatav tulemus: Vestluse ID, pealkiri ja kõige hilisema sõnumi
tekst. Kasutatud: WHERE, alampäring, ORDER BY ——————————————————–*/
SELECT c.id AS vestlus_id, c.title AS vestluse_pealkiri, m.message AS
viimane_sonum FROM conversations c JOIN messages m ON m.conversationId =
c.id WHERE m.sent_at = ( SELECT MAX(sent_at) FROM messages WHERE
conversationId = c.id );

/* ——————————————————- 3. Päring: Mudelite kasutusstatistika (kokku
kasutatud tokenid) Eesmärk: Admin saab jälgida, kui palju iga AI mudel
tarbib süsteemi ressursse. Oodatav tulemus: Mudeli nimi, versioon ja
kasutatud tokenite summa. Kasutatud: LEFT JOIN, SUM(), GROUP BY, ORDER
BY ——————————————————–*/ SELECT mo.name AS mudel, mo.version AS
versioon, COALESCE(SUM(mu.total_tokens), 0) AS kasutatud_tokenid FROM
models mo LEFT JOIN messages me ON mo.id = me.modelId LEFT JOIN
message_usage mu ON me.id = mu.messageId GROUP BY mo.id, mo.name,
mo.version ORDER BY kasutatud_tokenid DESC;

/* ——————————————————- 4. Päring: Kõige populaarsemad sõnumid
(reaktsioonide arv) Eesmärk: Selgitada välja sõnumid, mis on
kasutajatelt enim positiivset tagasisidet saanud. Oodatav tulemus:
Sõnumi tekst, like’id ja dislike’id. Kasutatud: LEFT JOIN, SUM(), GROUP
BY, ORDER BY ——————————————————–*/ SELECT m.message AS sonum, SUM(CASE
WHEN l.reaction = ‘like’ THEN 1 ELSE 0 END) AS likes, SUM(CASE WHEN
l.reaction = ‘dislike’ THEN 1 ELSE 0 END) AS dislikes FROM messages m
LEFT JOIN likes l ON m.id = l.messageId GROUP BY m.id, m.message ORDER
BY likes DESC, dislikes ASC LIMIT 10;

/* ——————————————————- 5. Päring: Avalikult või lingiga jagatud
vestlused Eesmärk: Admin saab vaadata, millised vestlused on nähtavad
väljaspool süsteemi. Oodatav tulemus: Vestluse nimi, nähtavuse tase ja
jagamislink. Kasutatud: JOIN, WHERE, ORDER BY ——————————————————–*/
SELECT c.title AS vestlus, cs.visibility AS nahtavus, cs.share_token AS
link FROM conversation_shares cs JOIN conversations c ON
cs.conversationId = c.id WHERE cs.visibility IN (‘public’, ‘link’) ORDER
BY cs.visibility ASC;

/* ——————————————————- 6. Päring: Kasutajad, kellel on rohkem kui 1
vestlus Eesmärk: Leida aktiivsemad kasutajad, kes kasutavad süsteemi
mitme vestluse loomiseks. Oodatav tulemus: Kasutajanimi ja tema
vestluste arv. Kasutatud: GROUP BY, HAVING, JOIN ——————————————————–*/
SELECT u.username AS kasutaja, COUNT(c.id) AS vestluste_arv FROM users u
JOIN conversations c ON u.id = c.userId GROUP BY u.id, u.username HAVING
COUNT(c.id) > 1 ORDER BY vestluste_arv DESC;
