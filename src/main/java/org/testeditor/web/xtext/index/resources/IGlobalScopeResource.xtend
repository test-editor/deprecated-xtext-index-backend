package org.testeditor.web.xtext.index.resources

import java.util.List
import javax.ws.rs.Consumes
import javax.ws.rs.POST
import javax.ws.rs.Produces
import javax.ws.rs.QueryParam
import org.eclipse.xtext.resource.IEObjectDescription

interface IGlobalScopeResource {

	@POST
	@Consumes("text/plain")
	@Produces("application/json")
	def List<IEObjectDescription> getScope(String context, @QueryParam("reference") String eReferenceURIString)
}
