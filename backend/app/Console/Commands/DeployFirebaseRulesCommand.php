<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Process;

class DeployFirebaseRulesCommand extends Command
{
    protected $signature = 'taxigo:firebase-rules {--deploy : Run firebase deploy --only database}';

    protected $description = 'Show or deploy Firebase Realtime Database security rules';

    public function handle(): int
    {
        $firebaseDir = dirname(base_path()).DIRECTORY_SEPARATOR.'firebase';
        if (! is_dir($firebaseDir)) {
            $firebaseDir = base_path('..'.DIRECTORY_SEPARATOR.'firebase');
        }

        $rules = $firebaseDir.DIRECTORY_SEPARATOR.'database.rules.json';
        $this->info('Rules file: '.$rules);

        if (! is_readable($rules)) {
            $this->error('Rules file not found.');

            return self::FAILURE;
        }

        $this->line(file_get_contents($rules) ?: '');

        $url = config('taxigo.firebase.database_url');
        $this->newLine();
        $this->line('FIREBASE_DATABASE_URL: '.($url ?: '(empty — set in .env)'));
        $this->line('Project: '.(config('taxigo.firebase.project_id') ?: '(empty)'));

        if (! $this->option('deploy')) {
            $this->newLine();
            $this->comment('Deploy manually:');
            $this->line('  cd '.$firebaseDir);
            $this->line('  firebase use '.(config('taxigo.firebase.project_id') ?: '<project-id>'));
            $this->line('  firebase deploy --only database');

            return self::SUCCESS;
        }

        if (empty(config('taxigo.firebase.project_id'))) {
            $this->error('FIREBASE_PROJECT_ID is required to deploy.');

            return self::FAILURE;
        }

        $result = Process::path($firebaseDir)
            ->timeout(120)
            ->run('firebase deploy --only database');

        $this->line($result->output());
        if ($result->failed()) {
            $this->error($result->errorOutput());

            return self::FAILURE;
        }

        $this->info('Firebase database rules deployed.');

        return self::SUCCESS;
    }
}
