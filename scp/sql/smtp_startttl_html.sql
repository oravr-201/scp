/* Formatted on 6/3/2021 8:49:40 AM (QP5 v5.326) */
CREATE OR REPLACE PROCEDURE POYNTUSR.MAIL_VB2 (k_recipient   VARCHAR2,
                                               k_subject     VARCHAR2,
                                               k_body        VARCHAR2)
IS
    k_host              CONSTANT VARCHAR2 (100) := 'smtp.office365.com';
    k_port              CONSTANT INTEGER := 587;
    k_wallet_path       CONSTANT VARCHAR2 (100)
        := 'file:/opt/oracle/dcs/commonstore/wallets/tde/PDWPDB1_dxb1rt' ;
    k_wallet_password   CONSTANT VARCHAR2 (100) := 'WPOra1_adm1N#T3aM';
    k_domain            CONSTANT VARCHAR2 (100) := 'outlook.com';
    k_username          CONSTANT VARCHAR2 (100) := 'vishal.p@oravr.in' ;
    k_password          CONSTANT VARCHAR2 (100) := 'pass';
    k_sender            CONSTANT VARCHAR2 (100) := 'vishal.p@oravr.in.net' ;
    --    k_recipient         CONSTANT VARCHAR2 (1000) := 'vishal.p@oravr.in.net';
    --    k_subject           CONSTANT VARCHAR2 (100) := 'Test TLS mail from DEV Poynt DB by Vishal ';
    --    k_body              CONSTANT VARCHAR2 (100) := 'Please reply back if you recived Email ';

    l_conn                       UTL_SMTP.connection;
    l_reply                      UTL_SMTP.reply;
    l_replies                    UTL_SMTP.replies;
BEGIN
    DBMS_OUTPUT.put_line ('utl_smtp.open_connection');

    l_reply :=
        UTL_SMTP.open_connection (HOST                            => k_host,
                                  port                            => k_port,
                                  c                               => l_conn,
                                  wallet_path                     => k_wallet_path,
                                  wallet_password                 => k_wallet_password,
                                  secure_connection_before_smtp   => FALSE);

    IF l_reply.code != 220
    THEN
        raise_application_error (
            -20000,
               'utl_smtp.open_connection: '
            || l_reply.code
            || ' - '
            || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.ehlo');

    l_replies := UTL_SMTP.ehlo (l_conn, k_domain);

    FOR ri IN 1 .. l_replies.COUNT
    LOOP
        DBMS_OUTPUT.put_line (
            l_replies (ri).code || ' - ' || l_replies (ri).text);
    END LOOP;

    DBMS_OUTPUT.put_line ('utl_smtp.starttls');

    l_reply := UTL_SMTP.starttls (l_conn);

    IF l_reply.code != 220
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.starttls: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.ehlo');

    l_replies := UTL_SMTP.ehlo (l_conn, k_domain);

    FOR ri IN 1 .. l_replies.COUNT
    LOOP
        DBMS_OUTPUT.put_line (
            l_replies (ri).code || ' - ' || l_replies (ri).text);
    END LOOP;

    DBMS_OUTPUT.put_line ('utl_smtp.auth');

    l_reply :=
        UTL_SMTP.auth (l_conn,
                       k_username,
                       k_password,
                       UTL_SMTP.all_schemes);

    IF l_reply.code != 235
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.auth: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.mail');

    l_reply := UTL_SMTP.mail (l_conn, k_sender);

    IF l_reply.code != 250
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.mail: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.rcpt');

    l_reply := UTL_SMTP.rcpt (l_conn, k_recipient);

    IF l_reply.code NOT IN (250, 251)
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.rcpt: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.open_data');

    l_reply := UTL_SMTP.open_data (l_conn);

    IF l_reply.code != 354
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.open_data: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.write_data');

    /* ** Sending the header information */
    UTL_SMTP.WRITE_DATA (l_conn, 'From: ' || k_sender || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn, 'To: ' || k_recipient || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn, 'Subject: ' || k_subject || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn,
                         'MIME-Version: ' || '1.0' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn, 'Content-Type: ' || 'text/html;');
    UTL_SMTP.WRITE_DATA (
        l_conn,
        'Content-Transfer-Encoding: ' || '"8Bit"' || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn, UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA (l_conn, UTL_TCP.CRLF || '');
    UTL_SMTP.WRITE_DATA (l_conn, UTL_TCP.CRLF || '');
    UTL_SMTP.WRITE_DATA (
        l_conn,
           UTL_TCP.CRLF
        || '<span style="color: red; font-family: Courier New;">'
        || k_body
        || '</span>');
    UTL_SMTP.WRITE_DATA (l_conn, UTL_TCP.CRLF || '');
    UTL_SMTP.WRITE_DATA (l_conn, UTL_TCP.CRLF || '');

    DBMS_OUTPUT.put_line ('utl_smtp.close_data');

    l_reply := UTL_SMTP.close_data (l_conn);

    IF l_reply.code != 250
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.close_data: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;

    DBMS_OUTPUT.put_line ('utl_smtp.quit');

    l_reply := UTL_SMTP.quit (l_conn);

    IF l_reply.code != 221
    THEN
        raise_application_error (
            -20000,
            'utl_smtp.quit: ' || l_reply.code || ' - ' || l_reply.text);
    END IF;
EXCEPTION
    WHEN UTL_SMTP.transient_error OR UTL_SMTP.permanent_error
    THEN
        BEGIN
            UTL_SMTP.quit (l_conn);
        EXCEPTION
            WHEN UTL_SMTP.transient_error OR UTL_SMTP.permanent_error
            THEN
                NULL;
                UTL_SMTP.quit (l_conn);
        END;

        raise_application_error (
            -20000,
            'Failed to send mail due to the following error: ' || SQLERRM);
END MAIL_VB2;
/
