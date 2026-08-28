<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_donor_registration_endpoint_creates_donor_account(): void
    {
        $response = $this->postJson('/api/v1/register/donor', [
            'name' => 'Ahmad',
            'type' => 'restaurant',
            'email' => 'donor@test.com',
            'phone' => '0999999999',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.type', 'donor')
            ->assertJsonPath('data.user.email', 'donor@test.com');

        $this->assertDatabaseHas('donors', [
            'email' => 'donor@test.com',
            'type' => 'restaurant',
        ]);
    }

    public function test_charity_registration_endpoint_creates_charity_account_without_donor_type_field(): void
    {
        $response = $this->postJson('/api/v1/register/charity', [
            'name' => 'Al-Birr Charity',
            'email' => 'charity@test.com',
            'phone' => '0911111111',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'has_kitchen' => true,
            'address' => 'Aleppo - Al-Furqan',
            'work_start' => '08:00',
            'work_end' => '16:00',
            'license_document' => null,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.type', 'charity')
            ->assertJsonPath('data.user.email', 'charity@test.com');

        $this->assertDatabaseHas('charities', [
            'email' => 'charity@test.com',
            'has_kitchen' => true,
            'address' => 'Aleppo - Al-Furqan',
        ]);
    }
}
