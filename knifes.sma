
#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >

new dMenu [ 36 ][ 64 ], dChat [ 36 ][ 64 ], dView [ 36 ][ 64 ], dPlayer [ 36 ][ 64 ], dCost [ 36 ][ 64 ], dLines;
new knife [ 33 ];

public plugin_init ()
{
	register_plugin ( "Knives Shop", "1.2", "OverGame" );
	
	register_clcmd ( "say /knife", "open_menu" );
	register_clcmd ( "say_team /knife", "open_menu" );
	register_clcmd ( "knife", "open_menu" );
	
	RegisterHam ( Ham_Item_Deploy, "weapon_knife", "fwd_Deploy_Knife", 1 );
}

public plugin_precache ()
{
	read_data_ini ();
	for ( new index; index < dLines; index++ )
	{
		precache_model ( dView [ index ] );
		precache_model ( dPlayer [ index ] );
	}
}

public open_menu ( id )
{
	new szCaption [ 255 ], menu;
	format ( szCaption, charsmax ( szCaption ), "^n\yМеню ножей:\d" );
	menu = menu_create ( szCaption, "func_omenu" );
	
	for ( new i; i < dLines; i++ )
	{
		new szTemp [ 10 ];
		num_to_str ( i, szTemp, charsmax ( szTemp ) );
		menu_additem ( menu, dMenu [ i ], szTemp );
	}
	
	menu_setprop ( menu, MPROP_BACKNAME, "Назад" );
	menu_setprop ( menu, MPROP_NEXTNAME, "Вперёд" );
	menu_setprop ( menu, MPROP_EXITNAME, "Выход" );
	
	menu_display ( id, menu, 0 );
	return PLUGIN_HANDLED;
}

public func_omenu ( id, menu, item )     
{     
	if ( item == MENU_EXIT )
	{     
		menu_destroy ( menu );
		return PLUGIN_HANDLED;
	}
	
	new data [ 15 ], iName [ 64 ];
	new access, callback;
	menu_item_getinfo ( menu, item, access, data,15, iName, 64, callback );
	
	new key = str_to_num ( data );
	if ( str_to_num ( dCost [ key ] ) <= cs_get_user_money ( id ) )
	{
		knife [ id ] = key;
		chat_send ( id, "!g[!gUKM!g] !y%s", dChat [ key ] );
		cs_set_user_money ( id, cs_get_user_money ( id ) - str_to_num ( dCost [ key ] ) );
		
		set_user_knife ( id );
		client_cmd(id, "knife")
	} else {
		chat_send ( id, "!g[!UKM!g] !tНедостаточно средств." );
	}
	
	return PLUGIN_HANDLED;
}

public fwd_Deploy_Knife ( weapon )
{
	new id = get_pdata_cbase ( weapon, 41, 4 );
	
	if ( is_user_alive ( id ) )
	{
		set_pev ( id, pev_viewmodel2, dView [ knife [ id ] ] );
		set_pev ( id, pev_weaponmodel2, dPlayer [ knife [ id ] ] );
	}
	
	return HAM_IGNORED;
}

stock set_user_knife ( id )
{
	if ( is_user_alive ( id ) )
	{
		engclient_cmd ( id, "weapon_knife" );
		set_pev ( id, pev_viewmodel2, dView [ knife [ id ] ] );
		set_pev ( id, pev_weaponmodel2, dPlayer [ knife [ id ] ] );
	}
}

stock chat_send ( const id, const input [ ], any:... )
{
	new count = 1, players [ 32 ];
	static msg [ 188 ];
	vformat ( msg, 187, input, 3 );
	
	replace_all ( msg, 187, "!g", "^4" );
	replace_all ( msg, 187, "!y", "^1" );
	replace_all ( msg, 187, "!t", "^3" );
	
	if ( id ) players [ 0 ] = id; else get_players ( players, count, "ch" );
	{
		for ( new i = 0; i < count; i++ )
		{
			if ( is_user_connected ( players [ i ] ) )
			{
				message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "SayText" ), _, players [ i ] );
				write_byte ( players [ i ] );
				write_string ( msg );
				message_end ();
			}
		}
	}
}

stock read_data_ini ()
{
	new len, buffer [ 256 ];
	new file = fopen ( "/addons/amxmodx/configs/knifes.ini", "r" );
	
	while ( !feof ( file ) )
	{
		fgets ( file, buffer, 255 );
		trim ( buffer );
		
		if ( buffer [ 0 ] == '"' )
		{
			parse ( buffer, dMenu [ len ], 63, dChat [ len ], 63, dView [ len ], 63, dPlayer [ len ], 63, dCost [ len ], 63 );
		} else {
			continue;
		}
		len++;
	}
	dLines = len;
	fclose ( file );
}
