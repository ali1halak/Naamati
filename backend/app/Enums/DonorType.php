<?php

namespace App\Enums;

enum DonorType: string
{
    case Individual = 'individual';
    case Restaurant = 'restaurant';
    case Hotel = 'hotel';
    case Company = 'company';
}