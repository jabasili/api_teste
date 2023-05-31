*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections

*** Keywords ***
Criar um usuário novo
    ${PALAVRA_ALEATORIA}    Generate Random String    
    ...    length=4    
    ...    chars=[LETTERS]
    ${PALAVRA_ALEATORIA}    Convert To Lower Case    ${PALAVRA_ALEATORIA}
    Set Test Variable    ${EMAIL_TESTE}    ${PALAVRA_ALEATORIA}@emailteste.com
    log  ${EMAIL_TESTE}

Criar sessão na ServeRest
    ${HEADERS}    Create Dictionary
    ...    Content-Type=application/json
    ...    accept=application/json
    Create Session    
    ...    alias=ServerRest    
    ...    url=https://serverest.dev    
    ...    headers=${HEADERS}
    
Cadastrar um usuário na ServeRest
    [Arguments]    ${EMAIL}    ${STATUS_CODE_DESEJADO}
    ${BODY}    Create Dictionary    
    ...    nome=Jader Basili    
    ...    email=${EMAIL}    
    ...    password=1234    
    ...    administrador=true
    
    Log    ${BODY}
    Criar sessão na ServeRest
    ${RESPOSTA}    POST On Session    
    ...    alias=ServerRest
    ...    url=/usuarios
    ...    json=${BODY}
    ...    expected_status=${STATUS_CODE_DESEJADO}
    
    Log    ${RESPOSTA.json()}
    IF  ${RESPOSTA.status_code} == 201
        Set Test Variable    ${ID_USUARIO}    ${RESPOSTA.json()["_id"]}            
    END
    
    Set Test Variable    ${RESPOSTA}    ${RESPOSTA.json()}

Validar que o usuário foi cadastrado corretamente
    Dictionary Should Contain Item    ${RESPOSTA}    message    Cadastro realizado com sucesso
    Dictionary Should Contain Key    ${RESPOSTA}     _id

Cadastrar novamente o usuário    
    Cadastrar um usuário na ServeRest  ${EMAIL_TESTE}    STATUS_CODE_DESEJADO=400

Validar que não é permitido cadastrar usuário repetido
    Dictionary Should Contain Item    ${RESPOSTA}    message    Este email já está sendo usado

Consultar os dados do usuário
    ${RESPOSTA_CONSULTA}    GET On Session    
    ...    alias=ServerRest
    ...    url=/usuarios/${ID_USUARIO}    
    Set Test Variable    ${RESP_CONSULTA}    ${RESPOSTA_CONSULTA.json()}
Confirmar dados retornados
    Log    ${RESP_CONSULTA}
    Dictionary Should Contain Item    ${RESP_CONSULTA}    nome            Jader Basili
    Dictionary Should Contain Item    ${RESP_CONSULTA}    email           ${EMAIL_TESTE}
    Dictionary Should Contain Item    ${RESP_CONSULTA}    password        1234
    Dictionary Should Contain Item    ${RESP_CONSULTA}    administrador   true
    Dictionary Should Contain Item    ${RESP_CONSULTA}    _id             ${ID_USUARIO}

Realizar Login com o usuário
    ${BODY_LOGIN}    Create Dictionary       
    ...    email=${EMAIL_TESTE}    
    ...    password=1234    

    ${LOGIN}    POST On Session    
    ...    alias=ServerRest
    ...    url=/login
    ...    json=${BODY_LOGIN}
    
    Log    ${LOGIN.json()}
    Set Test Variable    ${RESP_LOGIN}    ${LOGIN.json()}
Conferir se o Login ocorreu com sucesso
    Log    ${RESP_LOGIN}
    Dictionary Should Contain Item    ${RESP_LOGIN}    message    Login realizado com sucesso
    Dictionary Should Contain Key    ${RESP_LOGIN}    authorization