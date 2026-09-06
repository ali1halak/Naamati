<?php

namespace App\Console\Commands;

use App\Models\Admin;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;

/**
 * There is no public admin sign-up on purpose — the first account, and every
 * one after it, is created from the server by someone with shell access.
 */
class CreateAdmin extends Command
{
    protected $signature = 'admin:create
                            {--name= : Display name}
                            {--email= : Login email}
                            {--password= : Password, at least 8 characters}';

    protected $description = 'Create an admin account';

    public function handle(): int
    {
        $data = [
            'name'     => $this->option('name') ?: $this->ask('Name'),
            'email'    => $this->option('email') ?: $this->ask('Email'),
            'password' => $this->option('password') ?: $this->secret('Password'),
        ];

        $validator = Validator::make($data, [
            'name'     => ['required', 'string', 'max:120'],
            'email'    => ['required', 'email', 'max:150', 'unique:admins,email'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return self::FAILURE;
        }

        $admin = Admin::create($data);

        $this->info("Admin #{$admin->id} created for {$admin->email}.");

        return self::SUCCESS;
    }
}
