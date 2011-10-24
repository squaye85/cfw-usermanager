﻿/**
 * @hint Base User model.
 */
component
	extends="Model"
{
	/*
	 * @hint Constructor
	 */
	public void function init() {
		belongsTo("role");
		hasMany("tokens");

		afterSave("setSession");
		beforeSave("sanitize,securePassword");
		beforeValidation("setSalt");

		property(name="confirmed", defaultValue="0");
		property(name="roleId", defaultValue="1");

		validatesConfirmationOf("password,email");
		validatesFormatOf("email");
		validatesPresenceOf("name,email,password,roleId");
		validatesUniquenessOf("email");
	}

	// --------------------------------------------------    
    // Callbacks

	/*
	 * @hint Sanitizes the user object.
	 */
	private void function sanitize() {
		this.name = HtmlEditFormat(this.name);
	}

	/*
	 * @hint Secures the password property before saving it.
	 */
	private void function securePassword() {
		if ( StructKeyExists(this, "passwordConfirmation") ) {
			this.password = hashPassword(this.password, this.salt);	
		}
	}

	/*
	 * @hint Creates a salt string to use for hashing the password.
	 */
	private void function setSalt() {
		if ( StructKeyExists(this, "passwordConfirmation") ) {
			this.salt = CreateUUID();	
		}
	}

	// --------------------------------------------------    
    // Public

	/**
	 * @hint Authenticates a user object.
	 */
	public boolean function authenticate(required string password) {
		return ! Compare(this.password, hashPassword(arguments.password, this.salt));
	}

	/*
	 * @hint Generates an expiring security token for password resets.
	 */
	public void function generateSecurityToken() {
		this.token = this.createToken(token=CreateUUID(), expires=DateAdd("d", 1, Now()));
	}

	/*
	 * @hint Generates a temporary password when users reset their password.
	 */
	public void function generateTemporaryPassword() {
		this.password = CreateUUID();
	}

	// --------------------------------------------------    
    // Private

	/*
	 * @hint Hashes a password string.
	 */
	private string function hashPassword(required string password, required string salt) {
		for (local.i = 1; local.i <= 1024; local.i++) {
			local.password = Hash(arguments.password & arguments.salt, "SHA-512");
		}
		return local.password;
	}

	/*
	 * @hint Sets the user session.
	 */
	private void function setSession() {
		connect(this);
	}

}