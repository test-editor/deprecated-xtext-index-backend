/*******************************************************************************
 * Copyright (c) 2012 - 2017 Signal Iduna Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Signal Iduna Corporation - initial API and implementation
 * akquinet AG
 * itemis AG
 *******************************************************************************/

package org.testeditor.web.xtext.index.resources.bitbucket

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import javax.ws.rs.Consumes
import javax.ws.rs.POST
import javax.ws.rs.Path
import javax.ws.rs.core.MediaType
import org.slf4j.LoggerFactory
import org.testeditor.web.xtext.index.resources.RepoEventCallback
import org.testeditor.web.xtext.index.resources.RepoEvent
import org.eclipse.xtend.lib.annotations.Accessors

@Path("/xtext/index/webhook/bitbucket/push")
@Consumes(MediaType.APPLICATION_JSON)
class Push {
	
	static val logger = LoggerFactory.getLogger(Push);
	
	@Accessors(PUBLIC_SETTER)
	var RepoEventCallback callback
	
	@POST
	def void push(String payload) {
		val objectMapper = new ObjectMapper
		val node = objectMapper.readValue(payload, JsonNode)
		logger.info("Push.push with payload='{}'", payload)
		
		val actorNode = node.get("actor")
		val username = actorNode.get("username").asText
		
		callback?.call(new RepoEvent(username, node))
	}

}
