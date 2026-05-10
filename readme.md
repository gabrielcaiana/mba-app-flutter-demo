# MBA App — Controle de Acesso

Trabalho prático da disciplina **Mobile Development** — Faculdade Impacta  
Prof. Dr. Uedson Reis

App Flutter de controle de acesso com autenticação JWT, gerenciamento de usuários e roles.

---

## Funcionalidades

- Login com JWT
- Listagem, cadastro, edição e exclusão de usuários
- Associação de múltiplas roles por usuário
- Listagem e cadastro de roles
- Persistência do token de sessão entre aberturas do app

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Frontend | Flutter 3.41 + Dart 3.11 |
| HTTP | `http ^1.2.2` |
| Sessão | `shared_preferences ^2.3.2` |
| Backend | NestJS (repositório do professor) |
| Auth | JWT Bearer Token |

---

## Estrutura do projeto

```
lib/
├── main.dart                      # Entrypoint — decide login ou home conforme token salvo
├── models/
│   ├── user.dart                  # Model User com serialização JSON
│   └── role.dart                  # Model Role com serialização JSON
├── services/
│   └── api_service.dart           # Singleton com todos os endpoints REST + gestão do token
└── screens/
    ├── login_screen.dart          # Tela de login
    ├── users_list_screen.dart     # Listagem e exclusão de usuários
    ├── user_form_screen.dart      # Cadastro e edição de usuário (multi-role)
    ├── roles_list_screen.dart     # Listagem e exclusão de roles
    └── role_form_screen.dart      # Cadastro de nova role
```

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x
- Android Studio com emulador configurado (ou dispositivo físico)
- Backend rodando: [authentication-nestjs](https://github.com/uedsonreis/authentication-nestjs)

---

## Configurando o Backend

Clone e suba o backend do professor:

```bash
git clone https://github.com/uedsonreis/authentication-nestjs
cd authentication-nestjs
npm install
npm run start:dev
```

### ⚠️ Problema com emulador Android — NestJS escutando só em IPv6

Por padrão no Windows, o NestJS pode iniciar escutando apenas em `::1` (IPv6 loopback), o que impede o emulador Android de alcançar o servidor, o emulador acessa o host via `10.0.2.2` (IPv4).

**Solução:** altere o `src/main.ts` do backend para escutar em todas as interfaces:

```typescript
// Antes
await app.listen(3030);

// Depois
await app.listen(3030, '0.0.0.0');
```

Verifique se o servidor está escutando corretamente:

```bash
netstat -an | findstr :3030
# Deve mostrar 0.0.0.0:3030 ou :::3030, não apenas [::1]:3030
```

---

## Rodando o App

### 1. Instalar dependências

```bash
flutter pub get
```

### 2. Configurar a URL do backend

Abra [`lib/services/api_service.dart`](lib/services/api_service.dart) e ajuste `kBaseUrl` conforme o ambiente:

```dart
// Emulador Android (após correção do NestJS para 0.0.0.0)
const String kBaseUrl = 'http://10.0.2.2:3030';

// Web ou desktop
const String kBaseUrl = 'http://localhost:3030';
```

### 3. Executar

```bash
flutter run
```

---

## Credenciais padrão

O backend inicia com um usuário em memória:

| Campo | Valor |
|-------|-------|
| Usuário | `uedsonreis` |
| Senha | `123456` |

> O backend não persiste dados — ao reiniciar, volta ao estado inicial com apenas esse usuário.

---

## Endpoints utilizados

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/login` | Autenticação |
| GET | `/users` | Listar usuários |
| POST | `/users` | Criar usuário |
| PUT | `/users/:id` | Editar usuário |
| DELETE | `/users/:id` | Excluir usuário |
| GET | `/roles` | Listar roles |
| POST | `/roles` | Criar role |
| DELETE | `/roles/:id` | Excluir role |

Todos os endpoints exceto `/auth/login` requerem header `Authorization: Bearer <token>`.

---

## Disciplina

**Mobile Development** — MBA Faculdade Impacta  
Trabalho Prático — Opção 2  
Entrega: 10/05/2026
