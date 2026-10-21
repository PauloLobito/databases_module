CREATE TABLE unit (
    id_unit SERIAL PRIMARY KEY,
    name    TEXT NOT NULL,
    city    TEXT NOT NULL,
    country TEXT NOT NULL
);

CREATE TABLE room (
    id_room   SERIAL PRIMARY KEY,
    id_unit   INT NOT NULL REFERENCES unit(id_unit),
    name      TEXT NOT NULL,
    room_type TEXT
);

CREATE TABLE medical_unit (
    id_medical_unit SERIAL PRIMARY KEY,
    id_unit         INT NOT NULL REFERENCES unit(id_unit),
    name            TEXT NOT NULL
);

CREATE TABLE staff (
    id_staff SERIAL PRIMARY KEY,
    name     TEXT NOT NULL,
    role     TEXT NOT NULL,
    email    TEXT UNIQUE,
    phone    TEXT,
    active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE shift (
    id_shift        SERIAL PRIMARY KEY,
    id_medical_unit INT NOT NULL REFERENCES medical_unit(id_medical_unit),
    id_staff        INT NOT NULL REFERENCES staff(id_staff),
    name            TEXT NOT NULL,
    start_time      TIMESTAMPTZ NOT NULL,
    end_time        TIMESTAMPTZ NOT NULL
);

CREATE TABLE patient (
    id_patient  SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    birth_date  DATE NOT NULL,
    national_id TEXT UNIQUE,
    phone       TEXT,
    email       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE medical_case (
    id_case     SERIAL PRIMARY KEY,
    id_patient  INT NOT NULL REFERENCES patient(id_patient),
    name        TEXT NOT NULL,
    description TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'open',
    opened_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at   TIMESTAMPTZ
);

CREATE TABLE episode (
    id_episode      SERIAL PRIMARY KEY,
    id_case         INT NOT NULL REFERENCES medical_case(id_case),
    id_medical_unit INT NOT NULL REFERENCES medical_unit(id_medical_unit),
    id_room         INT REFERENCES room(id_room),
    id_staff        INT REFERENCES staff(id_staff),
    name            TEXT NOT NULL,
    description     TEXT NOT NULL,
    start_time      TIMESTAMPTZ NOT NULL DEFAULT now(),
    end_time        TIMESTAMPTZ
);

CREATE TABLE exam (
    id_exam     SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL
);

CREATE TABLE patient_exam (
    id_patient_exam SERIAL PRIMARY KEY,
    id_patient      INT NOT NULL REFERENCES patient(id_patient),
    id_exam         INT NOT NULL REFERENCES exam(id_exam),
    id_staff        INT NOT NULL REFERENCES staff(id_staff),
    id_episode      INT REFERENCES episode(id_episode),
    performed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    result          TEXT
);

CREATE TABLE insurance (
    id_insurance SERIAL PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    phone        TEXT,
    email        TEXT
);

CREATE TABLE invoice (
    id_invoice   SERIAL PRIMARY KEY,
    id_case      INT NOT NULL REFERENCES medical_case(id_case),
    issue_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(10,2) NOT NULL,
    status       TEXT NOT NULL DEFAULT 'pending'
);

CREATE TABLE insurance_invoice (
    id_invoice     INT NOT NULL REFERENCES invoice(id_invoice),
    id_insurance   INT NOT NULL REFERENCES insurance(id_insurance),
    covered_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_invoice, id_insurance)
);

CREATE TABLE report (
    id_report  SERIAL PRIMARY KEY,
    id_patient INT NOT NULL REFERENCES patient(id_patient),
    id_invoice INT REFERENCES invoice(id_invoice),
    id_episode INT REFERENCES episode(id_episode),
    name       TEXT NOT NULL,
    content    TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);