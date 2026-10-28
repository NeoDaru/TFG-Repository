### **V0 Prototype Screenshots**
This prototype was created to validate the user stories and identify any missing requirements. As an early design, it also serves as a guide to define the user journey throughout the application.

<table>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/home_screen.png" alt="Pantalla de inicio" width="300"/><br>
      <sub>Home Screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/login_screen.png" alt="Pantalla de inicio de sesión" width="300"/><br>
      <sub>Login screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/register_screen.png" alt="Pantalla de registro" width="300"/><br>
      <sub>Sign up screen</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/main_screen.png" alt="Pantalla principal" width="300"/><br>
      <sub>Main screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/profile_screen.png" alt="Pantalla de perfil" width="300"/><br>
      <sub>Profile screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/change_profile_data_screen.png" alt="Pantalla de cambio de datos de perfil" width="300"/><br>
      <sub>Edit profile screen</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/excursion_code_screen.png" alt="Pantalla de código de excursión" width="300"/><br>
      <sub>Excursion code screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/excursion_creation_screen.png" alt="Pantalla de creación de excursión" width="300"/><br>
      <sub>Excursion form screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/excursion_details_screen.png" alt="Pantalla de detalles de excursión" width="300"/><br>
      <sub>Excursion details screen</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/participants_screen.png" alt="Pantalla de participantes" width="300"/><br>
      <sub>Participants screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/groups_screen.png" alt="Pantalla de grupos" width="300"/><br>
      <sub>Groups screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/map_screen.png" alt="Pantalla de mapa" width="300"/><br>
      <sub>Map screen</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/issue_creation_screen.png" alt="Pantalla formulario incidencia" width="300"/><br>
      <sub>Issue form screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/issue_screen.png" alt="Pantalla de incidencias" width="300"/><br>
      <sub>Issue screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/issue_details_screen.png" alt="Pantalla de detalles de incidencia" width="300"/><br>
      <sub>Issue details screen</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/prototype/notification_screen.png" alt="Pantalla de avisos" width="300"/><br>
      <sub>Notification screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/notification_creation_screen.png" alt="Pantalla formulario alerta" width="300"/><br>
      <sub>Notification form screen</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/prototype/statistics_screen.png" alt="Pantalla de estadísticas" width="300"/><br>
      <sub>Statistics screen</sub>
    </td>
  </tr>
</table>

### **V0 Prototype Use Cases**
These use cases define what each user role can do within the application, with each feature mapped directly to a specific user story.

The use cases are color-coded by user role:
* 🟦 **Blue:** Actions performed by a regular user.
* 🟩 **Green:** Actions performed by a coordinator.
* 🟥 **Red:** Actions performed by an administrator.

<table>
  <tr>
    <td align="center">
      <img src="docs/img/v0/use-cases/accounts_and_sessions.jpg" alt="Casos de uso relacionados con cuentas y sesión" width="450"/><br>
      <sub>Accounts and sessions related use cases</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/use-cases/excursion_participant.jpg" alt="Casos de uso relacionados con participantes en la excursión" width="450"/><br>
      <sub>Excursion participant related use cases</sub>
    </td>
  </tr>
  <tr height="20px"></tr>
  <tr>
    <td align="center">
      <img src="docs/img/v0/use-cases/excursion_management_and_planning.jpg" alt="Casos de uso relacionados con gestión y planificación de la excursión" width="450"/><br>
      <sub>Excursion management and planning related use cases</sub>
    </td>
    <td align="center">
      <img src="docs/img/v0/use-cases/supervision_and_assistance.jpg" alt="Casos de uso relacionados con supervisión y asistencia" width="450"/><br>
      <sub>Supervision and assistance related use cases</sub>
    </td>
  </tr>
</table>

## Database migrations
The database schema is versioned in [`supabase/migrations/`](supabase/migrations/). Each file is a SQL script that applies one or more changes to the database (such as creating a table, adding a column or defining a security policy). Together, they form the full history of how the schema evolved. In order to replicate the schema, migrations must be executed **in ascending numerical order**.

### Final schema snapshot
Once the project is complete, a consolidated `supabase/schema.sql` will be added. It will describe the final state of the database in a single, readable script, so it can be recreated in one step without replaying the whole history.

## Configurations

### Run configuration
1. Create a file named `env.json` inside the `app` folder.
2. Copy the contents of [`app/env.example.json`](app/env.example.json) into `app/env.json`.
3. Fill in the `env.json` file with your Supabase project URL and public key.
4. To run the app: `flutter run --dart-define-from-file=env.json`.