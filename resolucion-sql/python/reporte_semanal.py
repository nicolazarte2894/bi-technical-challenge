import os
from dotenv import load_dotenv
import pyodbc
import pandas as pd
from enviar_email import send_email

# Variables de entorno
load_dotenv()
DRIVER = os.getenv('DRIVER')
SERVER = os.getenv('SERVER')
receiver_email = os.getenv("RECEIVER_EMAIL")
# Si trabaja con UID Y PWD colocarlos en las variables de entorno. Si trabaja con Windows Authentication colocar TRUSTED_CONNECTION = yes

def main():
    try:
        connection = pyodbc.connect(F"""
                                    DRIVER={DRIVER};
                                    SERVER={SERVER};
                                    DATABASE=AdventureWorks;
                                    TRUSTED_CONNECTION=yes;
                                    """)
        print("Conexión exitosa")
        
        query = """
                        -- Variable Fecha maxima
                        DECLARE @MaxDate AS date;
                        SELECT @MaxDate = MAX([Fecha de venta]) FROM reporte_ventas;
                        -- Common Table Exprassion para manejo de datos duplicados, condicion de fecha y tipo de tarjeta
                        WITH reporte_venta_semanal AS (
                            SELECT *,
                                ROW_NUMBER() OVER (PARTITION BY [ID de Venta] ORDER BY [ID de Venta]) AS RowNum
                            FROM reporte_ventas
                            WHERE [Fecha de venta] >= DATEADD(DAY,-7,@MaxDate) AND [Tipo de tarjeta] != 'ColonialVoice'
                        )
                        SELECT FORMAT([Fecha de venta], 'dd-MM-yyyy') AS 'Fecha de venta', 
                                -- ISNULL('Sin vendedor',[Nombre de Vendedor]) as 'Nombre de Vendedor',
                                [Nombre de Vendedor],
                                [Nombre de Cliente], 
                                [ID de Venta], 
                                [Cantidad productos vendidos], 
                                [Cantidad de distintos productos vendidos], 
                                [Monto total de la venta], 
                                [Tipo de tarjeta], 
                                [Tipo de Oferta]
                        FROM reporte_venta_semanal 
                        WHERE RowNum = 1
                        ORDER BY [Fecha de venta] DESC;
                    """
        df = pd.read_sql(query, connection)
        max_date = pd.to_datetime(df['Fecha de venta']).dt.date.max().strftime("%d-%m-%Y")
        filename = f"Reporte-ventas-al-{max_date}"
        df.to_csv(f"../report/{filename}.csv",index=False)
        print("Reporte exportado")
        send_email(
                    subject = f"Reporte de ventas al {max_date}",
                    receiver_email = receiver_email,
                    name = 'Nico',
                    filename = filename,
                    date = max_date
                )
    except Exception as ex:
        print(ex)
    finally:
        connection.close()
        print("Conexión finalizada")
        
if __name__ == "__main__":
    main()