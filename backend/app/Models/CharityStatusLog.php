<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CharityStatusLog extends Model
{
    public $timestamps = false; // only created_at, set via useCurrent() in the migration

    protected $fillable = ['charity_id', 'admin_id', 'from_status', 'to_status', 'note'];

    public function charity()
    {
        return $this->belongsTo(Charity::class);
    }

    public function admin()
    {
        return $this->belongsTo(Admin::class);
    }
}
