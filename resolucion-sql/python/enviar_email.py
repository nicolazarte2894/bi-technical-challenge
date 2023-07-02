import os
from dotenv import load_dotenv #pip install python-dotenv
import smtplib
from email.message import EmailMessage
from email.utils import formataddr
    
# Variables de entorno
load_dotenv()
sender_email = os.getenv('EMAIL')
password_email = os.getenv("PASSWORD")
receiver_email = os.getenv("RECEIVER_EMAIL")

# Función para enviar mail
def send_email(subject, receiver_email, name, filename, date):
    
    # Configuración del mensaje
    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = formataddr(("Nicolas Lazarte Python App",f"{sender_email}"))
    msg['To'] = receiver_email
    # msg['BCC'] = sender_email Para enviar copia oculta
    msg.add_alternative(
        f"""
        <html>
            <body>
                <p>Hola {name}!,</p>
                <p>Envío el reporte de venta actualizado al <strong> {date}</strong>
                <p>Saludos!</p>
                <p>Nicolás</p>
            </body>
        </html>
        """,
        subtype='html'
    )
    ## Archivo adjunto
    with open(f"../report/{filename}.csv", "rb") as f:
        msg.add_attachment(
            f.read(),
            filename=f"{filename}.csv",
            maintype="text",
            subtype="csv"
        )
    
    # Instanciar el servidor, loguearse y enviar el mail
    with smtplib.SMTP("smtp-mail.outlook.com",587) as server:
        server.starttls()
        server.login(sender_email, password_email)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        
    return print("Email enviado")

if __name__=='__main__':
    send_email(
        subject= 'Prueba',
        receiver_email=receiver_email,
        name = 'Nico'
    )