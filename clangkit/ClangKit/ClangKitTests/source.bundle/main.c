//
//  main.c
//  DiffieHellman
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#include "manager.h"



void doKey() {

	QI_Crypt_Manager_t manager_central;
	QI_Crypt_Manager_t manager_peripheral;
	
	QI_Crypt_Manager_Init_Value_t value = init_p_g_value();
	
	init_central_manager(value.p_key, value.g_key, &manager_central);
	init_peripheral_manager(value.p_key, value.g_key, &manager_peripheral);
	
	create_private_key(manager_central.public_key, &manager_peripheral);
	create_private_key(manager_peripheral.public_key, &manager_central);
	
	printf("\n   Central key:");
	print_hex(manager_central.private_key, 32, QI_Crypt_Print_Type_HEX_Spaced);
	printf("\nPeripheral key:");
	print_hex(manager_peripheral.private_key, 32, QI_Crypt_Print_Type_HEX_Spaced);
	printf("\n");
	
}


int main(int argc, const char * argv[]) {
	
	
	srand(time(0));
	

	for (int i = 0 ; i < 1 ; i++) {
		doKey();
	}


}
