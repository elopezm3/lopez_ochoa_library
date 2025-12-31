# Biblioteca López Ochoa

A Rails-based library management system for tracking books, authors, and copies with loan functionality.

**🌐 Live Application:** [https://lopez-ochoa-library.onrender.com/](https://lopez-ochoa-library.onrender.com/)

## Features

- 📚 **Books Management**: CRUD operations for books with automatic copy creation
- 👤 **Authors Management**: Full author management with proper name formatting
- 📖 **Copies Management**: Track individual book copies with loan/return functionality
- 🔍 **Search**: Search books by title or author
- 📊 **Sortable Tables**: Click column headers to sort by title, author, or number of copies
- 🎨 **Modern UI**: Built with Tailwind CSS and Spanish interface
- 🔄 **Searchable Dropdowns**: Tom Select integration for better UX

## Tech Stack

- **Ruby on Rails 7.2**
- **PostgreSQL** (via Supabase)
- **Tailwind CSS** for styling
- **Stimulus** for JavaScript interactions
- **Tom Select** for enhanced dropdowns

## Setup

### Prerequisites

- Ruby 3.3.2 (or version specified in `.ruby-version`)
- PostgreSQL client libraries
- Bundler gem

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/elopezm3/lopez_ochoa_library.git
   cd lopez_ochoa_library
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   - See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for detailed Supabase configuration
   - Or use local PostgreSQL:
     ```bash
     rails db:create
     rails db:migrate
     rails db:seed
     ```

4. Start the server:
   ```bash
   rails server
   ```

   Or use the development script (runs Rails + Tailwind watcher):
   ```bash
   bin/dev
   ```

## Database Configuration

This application uses **Supabase** (PostgreSQL) as the database. See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for complete setup instructions.

### Quick Supabase Setup

1. Create a project at [supabase.com](https://app.supabase.com)
2. Get your connection string from Settings → Database (use "Direct connection")
3. Add to Rails credentials:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   ```yaml
   database:
     url: postgresql://postgres:[PASSWORD]@[PROJECT-REF].supabase.co:5432/postgres
   ```
4. Run migrations:
   ```bash
   rails db:migrate
   ```

## Deployment

This app is deployed on **Render** and is live at:

**🌐 Production URL:** [https://lopez-ochoa-library.onrender.com/](https://lopez-ochoa-library.onrender.com/)

See [RENDER_DEPLOY.md](RENDER_DEPLOY.md) for step-by-step deployment instructions.

### Quick Deploy to Render

1. Push to GitHub
2. Create a new Web Service on Render
3. Set `RAILS_MASTER_KEY` environment variable (from `config/master.key`)
4. Deploy!

## Backup

Automated database backups run weekly via GitHub Actions. See [docs/BACKUP.md](docs/BACKUP.md) for complete documentation.

- **Schedule:** Every Sunday at midnight UTC
- **Storage:** GitHub Releases (keeps last 10 backups)
- **Format:** CSV files in ZIP archives
- **Manual Trigger:** Available from GitHub Actions UI

## Usage

### Books
- View all books with search and sorting
- Create new books (automatically creates a copy)
- Edit and delete books

### Authors
- Manage authors with last name, first name format
- Books are sorted by author (last name, then first name)

### Copies
- Track individual book copies
- Loan copies to borrowers
- Return copies
- Filter by available/loaned status

## Development

### Running Tests
```bash
rails test
```

### Code Style
```bash
bundle exec rubocop
```

### Database Migrations
```bash
rails db:migrate
rails db:rollback
```

## License

This project is private and proprietary.
