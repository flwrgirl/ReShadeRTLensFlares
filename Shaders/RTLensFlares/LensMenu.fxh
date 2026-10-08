#pragma once
namespace RTL {
int LensID(){return LensIndex;}
bool IsLegacyLens(){return LensIndex==_RTL_TESSAR_MENU || LensIndex==_RTL_MINOLTA_MENU;}
}
