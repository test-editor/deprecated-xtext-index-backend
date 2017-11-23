package org.testeditor.web.xtext.index.resources.exceptions

class InvalidEReferenceException extends GlobalScopeResourceException {

	new(String message, Throwable cause) {
		super(message, cause)
	}

	new(String message) {
		super(message)
	}

}
