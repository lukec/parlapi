BEGIN;

CREATE TABLE parliament (
    parl_id int NOT NULL,
    parl int NOT NULL,
    "session" int NOT NULL,
    start_date timestamptz NOT NULL,
    end_date timestamptz NOT NULL
);

CREATE UNIQUE INDEX parliament__id ON parliament (parl_id);
CREATE UNIQUE INDEX parliament__parl_session ON parliament (parl, session);

CREATE TABLE member (
    member_id int NOT NULL,
    name text NOT NULL,
    url text,
    caucus text NOT NULL,
    constituency text NOT NULL,
    email text NOT NULL,
    website text NOT NULL,
    phone text NOT NULL,
    fax text NOT NULL,
    province text NOT NULL,
    profile_photo_url text NOT NULL
);

CREATE UNIQUE INDEX member__id ON member (member_id);

CREATE TABLE parliament_members (
    parl_id int NOT NULL,
    member_id int NOT NULL
);

CREATE INDEX parliament_members__parl_id ON parliament_members (parl_id);
CREATE INDEX parliament_members__member_id ON parliament_members (member_id);

CREATE TABLE bill (
    bill_id int NOT NULL,
    parl_id int NOT NULL,
    name text NOT NULL,
    summary text NOT NULL,
    sponsor text NOT NULL,
    sponsor_title text NOT NULL,
    sponsor_id int NOT NULL,
    links text[]
);

CREATE UNIQUE INDEX bill__id ON bill (bill_id);
CREATE INDEX bill__parl_id ON bill (parl_id);
CREATE INDEX bill__sponsor_id ON bill (sponsor_id);
CREATE UNIQUE INDEX bill__parl_name ON bill (parl_id, name);

CREATE TABLE bill_vote (
    bill_vote_id int NOT NULL,
    bill_id int NOT NULL,
    nays int NOT NULL,
    yays int NOT NULL,
    paired int NOT NULL,
    decision text NOT NULL,
    date timestamptz NOT NULL,
    number int NOT NULL,
    sitting int NOT NULL
);

CREATE UNIQUE INDEX bill_vote__id ON bill_vote (bill_vote_id);
CREATE INDEX bill_vote__bill_id ON bill_vote (bill_id);

CREATE TABLE member_vote (
    bill_vote_id int NOT NULL,
    member_id int NOT NULL,
    vote int NOT NULL
    -- 0 = nay
    -- 1 = yay
    -- 2 = paired
);

CREATE UNIQUE INDEX member_vote__id ON member_vote (bill_vote_id);
CREATE INDEX member_vote__member_id ON member_vote (member_id);

COMMIT;
