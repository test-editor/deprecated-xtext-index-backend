package org.testeditor.web.xtext.index.resources

import java.util.List
import javax.ws.rs.Consumes
import javax.ws.rs.POST
import javax.ws.rs.Produces
import javax.ws.rs.QueryParam
import org.eclipse.xtext.resource.IEObjectDescription

interface IGlobalScopeResource {

	/**
	 * Gets all elements in the scope for a given reference, viewed from the
	 * provided context resource.
	 * 
	 * This method exposes a REST endpoint for Xtext's global scope provision
	 * mechanism, to be invoked via HTTP POST. Implementations may delegate the
	 * request to Xtext standard global scope provider implementations, such as 
	 * @link{org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider DefaultGlobalScopeProvider}.
	 * The result is returned as a list of 
	 * @link{org.eclipse.xtext.resource.IEObjectDescription IEObjectDescription};
	 * the caller is responsible for wrapping them into an 
	 * @link{org.eclipse.xtext.scoping.IScope IScope} object, if required.
	 * Individual IEObjectDescription objects are transmitted serialized to JSON
	 * in the following format (example description of an instance of class
	 * @link{org.eclipse.xtext.Grammar Grammar}):
	 *
	 *   {
 	 *     "eObjectURI" : "#//",
	 *     "uri" : "http://www.eclipse.org/2008/Xtext#//Grammar",
	 *     "fullyQualifiedName" : "sampleEObject"
	 *   }
	 * 
	 * @param context The complete content of the resource (file) from where the
	 * scope is looked at. Transmitted as plain-text in the body of the request.
	 * @param eReferenceURIString The URI of the EReference for which all
	 * potential targets in the scope are to be retrieved. Transmitted as query
	 * parameter "reference".
	 * @returns a list of all IEObjectDescription elements that are in the scope
	 * viewed from the specified context, and are target candidates for the
	 * given reference. Transmitted as JSON in the body of the response.
	 */
	@POST
	@Consumes("text/plain")
	@Produces("application/json")
	def List<IEObjectDescription> getScope(String context, @QueryParam("reference") String eReferenceURIString)
}