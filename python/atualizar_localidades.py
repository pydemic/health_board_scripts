import pandas as pd
import math
import time

file = open(
    "/home/modesto/Documentos/OPAS/consolidacao_mortalidades/dados/mortalities.csv", "r+")
file_final = open(
    "/home/modesto/Documentos/OPAS/consolidacao_mortalidades/dados/mortalities_neww.csv", "r+")

df_localidades = pd.read_csv(
    '/home/modesto/Documentos/OPAS/consolidacao_mortalidades/dados_antigos/locations.csv',
    names=["n", "pai", "id", "nome", "sigla"])
lista = df_localidades['id'][483:]
lista_mun = lista.apply(lambda x: x // 10)
lista_num_7_digitos = lista.values
cont_linha = 0


def ajustar_local(num):
    try:
        temporario = lista_mun.loc[lista_mun == num]
        df_temp = df_localidades['id'][temporario.index[0]]
        return df_temp
    except:
        return 1


def verificar_local_7_digitos(num):
    if num in lista_num_7_digitos:
        return num
    else:
        return 1


print('Inicio')

ini = time.time()
for linha in file:

    cont_linha = cont_linha + 1
    if cont_linha % 1000000 == 0:
        print('\nlinha:', cont_linha)

    valores = linha.split(',')

    if len(valores[4]) == 7:
        if valores[4][0:2] == '53':
            valores[4] = '5300108'
        else:
            valores[4] = verificar_local_7_digitos(int(valores[4]))

    elif len(valores[4]) == 6:
        if valores[4][0:2] == '53':
            valores[4] = '5300108'
        else:
            valores[4] = ajustar_local(int(valores[4]))
    else:
        valores[4] = 1

    if len(valores[5]) == 7:
        if valores[5][0:2] == '53':
            valores[5] = '5300108'
        else:
            valores[5] = verificar_local_7_digitos(int(valores[5]))

    elif len(valores[5]) == 6:
        if valores[5][0:2] == '53':
            valores[5] = '5300108'
        else:
            valores[5] = ajustar_local(int(valores[5]))
    else:
        valores[5] = 1

    conteudo = f'{valores[0]},{valores[1]},{valores[2]},{valores[3]},{valores[4]},{valores[5]},{valores[6]},{valores[7]},{valores[8]},{valores[9]}\n'
    file_final.writelines(conteudo)

fim = time.time()
print("Método de carregar linha: ", fim-ini)
print('Fim')

file.close()
file_final.close()
